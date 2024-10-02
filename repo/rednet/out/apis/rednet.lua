local arcos = require("arcos")
local devices = require("devices")


CHANNEL_BROADCAST = 65535
CHANNEL_REPEAT = 65535
MAX_ID_CHANNELS= 65530

local recMsgs = {}
local hostNames = {}
local pruneRecvTimer

local function idAsPort(id)
    return id % MAX_ID_CHANNELS
end
---Opens a modem
---@param modem string
local function open(modem)
    assert(type(modem) == "string", "Argument modem invalid")
    if devices.type(modem) ~= "modem" then
        error(modem .. " is not a modem!")
    end
    devices.get(modem).open(idAsPort(arcos.id))
    devices.get(modem).open(CHANNEL_BROADCAST)
end

---Closes a modem or all
---@param modem string?
local function close(modem)

    assert(type(modem) == "string" or type(modem) == "nil", "Argument modem invalid")
    if devices.type(modem) ~= "modem" then
        error(modem .. " is not a modem!")
    end
    devices.get(modem).close(idAsPort(arcos.id))
    devices.get(modem).close(CHANNEL_BROADCAST)
end

---Gets the open status on a modem.
---@param modem string?
---@return boolean
local function isOpen(modem)
    assert(type(modem) == "string" or type(modem) == "nil")
    if modem then
        if devices.type(modem) == "modem" then
            local d = devices.get(modem)
            return d.isOpen(idAsPort(arcos.id)) and d.isOpen(CHANNEL_BROADCAST)
        end
    else
        for index, value in ipairs(devices.names()) do
            if devices.type(value) == "modem" and isOpen(value) then
                return true
            end
        end
    end
    return false
end

local function send(recipient, message, protocol)
    assert(type(recipient) == "number")
    assert(type(protocol) == "string" or type(protocol) == "nil")
    local mId = math.random(2, 2147483647)
    recMsgs[mId] = arcos.clock() + 14.5
    if not pruneRecvTimer then pruneRecvTimer = arcos.startTimer(15) end

    local repPort = idAsPort(arcos.id)
    local wrapper = {
        nMessageID = mId,
        nRecipient = recipient,
        nSender = arcos.id,
        message = message,
        sProtocol = protocol
    }

    local sent = false
    if recipient == arcos.id then
        arcos.queue("rednet_message", arcos.id, message, protocol)
        sent = true
    else
        if recipient ~= CHANNEL_BROADCAST then
            recipient = idAsPort(recipient)
        end
        for key, value in ipairs(devices.names()) do
            if isOpen(value) then
                devices.get(value).transmit(recipient, repPort, wrapper)
                devices.get(value).transmit(CHANNEL_REPEAT, repPort, wrapper)
                sent = true
            end
        end
    end
    return sent
end


local function broadcast(message, protocol)
    send(CHANNEL_BROADCAST, message, protocol)
end

local function receive(protocol_filter, timeout)
    -- The parameters used to be ( nTimeout ), detect this case for backwards compatibility
    if type(protocol_filter) == "number" and timeout == nil then
        protocol_filter, timeout = nil, protocol_filter
    end
    assert(type(protocol_filter) == "string" or type(protocol_filter) == "nil")

    assert(type(timeout) == "number" or type(timeout) == "nil")

    -- Start the timer
    local timer = nil
    local event_filter = nil
    if timeout then
        timer = arcos.startTimer(timeout)
        event_filter = nil
    else
        event_filter = "rednet_message"
    end

    -- Wait for events
    while true do
        local event, p1, p2, p3 = arcos.ev()
        if event == "rednet_message" then
            -- Return the first matching rednet_message
            local sender_id, message, protocol = p1, p2, p3
            if protocol_filter == nil or protocol == protocol_filter then
                return sender_id, message, protocol
            end
        elseif event == "timer" then
            -- Return nil if we timeout
            if p1 == timer then
                return nil
            end
        end
    end
end

local function lookup(protocol, hostname)
    assert(type(protocol) ==  "string")
    assert(type(hostname) ==  "string" or type(hostname) == "nil")

    -- Build list of host IDs
    local results = nil
    if hostname == nil then
        results = {}
    end

    -- Check localhost first
    if hostNames[protocol] then
        if results then
            table.insert(results, arcos.id)
        elseif hostname == "localhost" or hostname == hostNames[protocol] then
            return arcos.id
        end
    end

    if not isOpen() then
        if results then
            return table.unpack(results)
        end
        return nil
    end

    -- Broadcast a lookup packet
    broadcast({
        sType = "lookup",
        sProtocol = protocol,
        sHostname = hostname,
    }, "dns")

    -- Start a timer
    local timer = arcos.startTimer(2)

    -- Wait for events
    while true do
        local event, p1, p2, p3 = arcos.pullEvent()
        if event == "rednet_message" then
            -- Got a rednet message, check if it's the response to our request
            local sender_id, message, message_protocol = p1, p2, p3
            if message_protocol == "dns" and type(message) == "table" and message.sType == "lookup response" then
                if message.sProtocol == protocol then
                    if results then
                        table.insert(results, sender_id)
                    elseif message.sHostname == hostname then
                        return sender_id
                    end
                end
            end
        elseif event == "timer" and p1 == timer then
            -- Got a timer event, check it's the end of our timeout
            break
        end
    end
    if results then
        return table.unpack(results)
    end
    return nil
end

local function host(protocol, hostname)
    assert(type(protocol) == "string")
    assert(type(hostname) == "string")
    if hostname == "localhost" then
        error("Reserved hostname", 2)
    end
    if hostNames[protocol] ~= hostname then
        if lookup(protocol, hostname) ~= nil then
            error("Hostname in use", 2)
        end
        hostNames[protocol] = hostname
    end
end

local function unhost(protocol)
    assert(type(protocol) == "string")
    hostNames[protocol] = nil
end

local started = false

local function run()
    if started then
        error("rednet is already running", 2)
    end
    started = true
    local pruceRecvTimer = arcos.startTimer(10)
    while true do
        local event, p1, p2, p3, p4 = arcos.ev()
        if event == "modem_message" then
            -- Got a modem message, process it and add it to the rednet event queue
            local modem, channel, reply_channel, message = p1, p2, p3, p4
            if channel == idAsPort(arcos.id) or channel == CHANNEL_BROADCAST then
                if type(message) == "table" and type(message.nMessageID) == "number"
                    and message.nMessageID == message.nMessageID and not recMsgs[message.nMessageID]
                    and (type(message.nSender) == "nil" or (type(message.nSender) == "number" and message.nSender == message.nSender))
                    and ((message.nRecipient and message.nRecipient == arcos.id) or channel == CHANNEL_BROADCAST)
                    and isOpen(modem)
                then
                    recMsgs[message.nMessageID] = arcos.clock() + 9.5
                    if not pruceRecvTimer then pruceRecvTimer = arcos.startTimer(10) end
                    arcos.queue("rednet_message", message.nSender or reply_channel, message.message, message.sProtocol)
                end
            end

        elseif event == "rednet_message" then
            -- Got a rednet message (queued from above), respond to dns lookup
            local sender, message, protocol = p1, p2, p3
            if protocol == "dns" and type(message) == "table" and message.sType == "lookup" then
                local hostname = hostNames[message.sProtocol]
                if hostname ~= nil and (message.sHostname == nil or message.sHostname == hostname) then
                    send(sender, {
                        sType = "lookup response",
                        sHostname = hostname,
                        sProtocol = message.sProtocol,
                    }, "dns")
                end
            end

        elseif event == "timer" and p1 == pruceRecvTimer then
            -- Got a timer event, use it to prune the set of received messages
            pruneRecvTimer = nil
            local now, has_more = arcos.clock(), nil
            for message_id, deadline in pairs(recMsgs) do
                if deadline <= now then recMsgs[message_id] = nil
                else has_more = true end
            end
            pruneRecvTimer = has_more and arcos.startTimer(10)
        end
    end
end

return {
    open = open,
    close = close,
    isOpen = isOpen,
    send = send,
    broadcast = broadcast,
    receive = receive,
    host = host,
    unhost = unhost,
    lookup = lookup,
    run = run
}