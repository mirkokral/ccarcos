
while true do
  term.setCursorPos(1, 1)
  term.clear()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  print("Do you agree to the privacy policy found?")
  print("(Y = yes, N = no, R = read the privacy policy)")
  local ev, c = os.pullEvent("char")
  if c == "y" or c == "Y" then
    break
  end
  if c == "n" or c == "N" then
    error("User did not agree to privacy policy.")
  end
  if c == "r" or c == "R" then
    local x = ".p" .. os.clock()*1000 .. ".txt"
    local f, e = fs.open(x, "w");
    if not f then error(e) end
    f.write([[By using arcos, you automatically agree to these
terms. Agreement to this file is also required By
the stock arcos installer.

We (the arcos development team) may:
- Collect telemetry information.
Telemetry sample data:
For an error: 
    - Message: text must not be nil
    - File: /system/krnl.lua
    - Line: 2
For a kernel panic:
    - Debug: <all info from the whole stack of 
    debug.getinfo>
    - Message: Argument invalid

If there is no file at /temporary/telemetry, no 
telemetry has been collected and no telemetry will be
collected.
(every telemetry call checks for 
/temporary/telemetry, if it's not found it skips 
telemetry else it overrides it with the new
telemetry and sends the telemetry to the server)

Turning off telemetry:
To turn off telemetry, use gconfig or (if gconfig
doesn't have telemetry stuff) modify /config/aboot,
find the "telemetry" field and disable it]])
    f.close()
    os.run({}, "/rom/programs/shell.lua", "/rom/programs/edit.lua", x)
    fs.delete(x)
  end
end
local UIthemedefs = {
}
UIthemedefs[colors.white] = { 236, 239, 244 }
UIthemedefs[colors.orange] = { 0, 0, 0 }
UIthemedefs[colors.magenta] = { 180, 142, 173 }
UIthemedefs[colors.lightBlue] = { 0, 0, 0 }
UIthemedefs[colors.yellow] = { 235, 203, 139 }
UIthemedefs[colors.lime] = { 163, 190, 140 }
UIthemedefs[colors.pink] = { 0, 0, 0 }
UIthemedefs[colors.gray] = { 76, 86, 106 }
UIthemedefs[colors.lightGray] = { 216, 222, 233 }
UIthemedefs[colors.cyan] = { 136, 192, 208 }
UIthemedefs[colors.purple] = { 0, 0, 0 }
UIthemedefs[colors.blue] = { 129, 161, 193 }
UIthemedefs[colors.brown] = { 0, 0, 0 }
UIthemedefs[colors.green] = { 163, 190, 140 }
UIthemedefs[colors.red] = { 191, 97, 106 }
UIthemedefs[colors.black] = { 59, 66, 82 }
for index, value in pairs(UIthemedefs) do
  term.setPaletteColor(index, value[1] / 255, value[2] / 255, value[3] / 255)
end
local fr, e = http.get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
    ["Authorization"] = "Bearer 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"
})
if not fr then 
    fr, e = http.get("https://api.github.com/repos/" .. getChosenRepo() .. "/commits/main", {
    })
    if not fr then
        return false
    end
end
local sourceURL = "http://raw.githubusercontent.com/mirkokral/ccarcos/main/archivedpkgs/base.arc"
local args = { ... }
local filesAlreadyDownloaded = 0
local filesToGo = 24
local currentlyDownloadingFile = ""
local wasSuccess = true

function mstrsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function check_key(options, key, ty, opt)
    local value = options[key]
    local valueTy = type(value)

    if (value ~= nil or not opt) and valueTy ~= ty then
        error(("bad field '%s' (%s expected, got %s"):format(key, ty, valueTy), 4)
    end
end

local function check_request_options(options, body)
    check_key(options, "url", "string")
    if body == false then
        check_key(options, "body", "nil")
    else
        check_key(options, "body", "string", not body)
    end
    check_key(options, "headers", "table", true)
    check_key(options, "method", "string", true)
    check_key(options, "redirect", "boolean", true)
    check_key(options, "timeout", "number", true)

    if options.method and not methods[options.method] then
        error("Unsupported HTTP method", 3)
    end
end

local function wrap_request(_url, ...)
    local ok, err = http.request(...)
    if ok then
        while true do
            local event, param1, param2, param3 = os.pullEvent()
            if event == "http_success" and param1 == _url then
                return param2
            elseif event == "http_failure" and param1 == _url then
                return nil, param2, param3
            end
        end
    end
    return nil, err
end
local function get(_url, _headers, _binary)
    if type(_url) == "table" then
        check_request_options(_url, false)
        return wrap_request(_url.url, _url)
    end

    assert(type(_url) == "string")
    assert(type(_headers) == "table" or type(_headers) == "nil")
    assert(type(_binary) == "boolean" or type(_binary) == "nil")
    return wrap_request(_url, _url, nil, _headers, _binary)
end

function redraw()
  if args[1] == "norender" then return end
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  local tw, th = term.getSize()
  term.setCursorPos(tw/2-8<0.5 and math.floor(tw/2-8) or math.ceil(tw/2-8), th/2<0.5 and math.floor(th/2) or math.ceil(th/2))
  term.setTextColor(colors.blue)
  write("[")
  term.setTextColor(colors.magenta)
  for i = 0, (filesAlreadyDownloaded/filesToGo)*14, 1 do
    write("=")
  end
  for i = 0, 14-(filesAlreadyDownloaded/filesToGo)*14, 1 do
    write(" ")
  end
  term.setTextColor(colors.blue)
  write("]")
  if not wasSuccess then
    term.setTextColor(colors.red)
  end
  term.setCursorPos(tw/2-(#currentlyDownloadingFile/2)<0.5 and math.floor(tw/2-(#currentlyDownloadingFile/2)) or math.ceil(tw/2-(#currentlyDownloadingFile/2)), th/2<0.5 and math.floor(th/2+1) or math.ceil(th/2+1))
  write(currentlyDownloadingFile)
  if not wasSuccess then sleep(0.5) end
end

redraw()

local indexFile, err = get(sourceURL)
if not indexFile then
  print("Failed to get index file. Error: " .. err)
  print("Make sure your server has HTTP on. If it doesn't, use a release zip from the releases section (when one gets released.)")
  error()
end
currentlyDownloadingFile = "Downloading archive"
redraw()
local indexFileContents = indexFile.readAll()
--if not indexFileContents then error("Error reading index file. Make sure your server has HTTP on.") end

local arkivelib = {
  ---Unachives an akv archive
  ---@param text string
  unarchive = function(text)
    local linebuf = ""
    local isReaderHeadInTable = true
    local offsetheader = {}
    local bufend = 0
    for k=0, #text,1 do
      local v = text:sub(k, k)
      if v == "\n" then
        if linebuf == "--ENDTABLE" then
          bufend = k+1
          isReaderHeadInTable=false
          break
        else
          table.insert(offsetheader, mstrsplit(linebuf, "|"))
        end
        linebuf = ""
      else
        linebuf = linebuf .. v
      end
      --print(linebuf)
    end
    local outputfiles = {}
    for k,v in ipairs(offsetheader) do
      if v[2] == "-1" then table.insert(outputfiles, {v[1], nil})
      elseif offsetheader[k+1] then
        table.insert(outputfiles, {v[1], text:sub(bufend+tonumber(v[2]), bufend+tonumber(offsetheader[k+1][2])-1)})
      else
        table.insert(outputfiles, {v[1], text:sub(bufend+tonumber(v[2]), #text)})
      end
      --print(v[1])
      currentlyDownloadingFile = "Extracting..."
      filesToGo = #offsetheader
      filesAlreadyDownloaded = k
      wasSuccess = true
      redraw()
    end
    
    --print(bufend)
    return outputfiles
  end
}
local data = arkivelib.unarchive(indexFileContents)

currentlyDownloadingFile = "Writing..."
filesToGo = #data
filesAlreadyDownloaded = 0
wasSuccess = true
redraw()

for k, v in ipairs(data) do
  if v[2] == nil then fs.makeDir("/" .. v[1]) else
    if fs.exists("/" .. v[1]) then fs.delete("/" .. v[1]) end
    local f, e = fs.open("/" .. v[1], "w")
    if f then
      f.write(v[2])
      f.close()
    else
      print(e)
      sleep(5)
    end
  end
  filesAlreadyDownloaded = k
  redraw()
end

term.clear()
term.setCursorPos(1, 2)
term.setTextColor(colors.white)
if shell then
  pcall(fs.delete, shell.getRunningProgram())
end
os.reboot()