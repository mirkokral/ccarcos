term.setPaletteColor(colors.white, 236/255, 239/255, 244/255)
term.setPaletteColor(colors.orange, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.magenta, 180/255, 142/255, 173/255)
term.setPaletteColor(colors.lightBlue, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.yellow, 235/255, 203/255, 139/255)
term.setPaletteColor(colors.lime, 163/255, 190/255, 140/255)
term.setPaletteColor(colors.pink, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.gray, 174/255, 179/255, 187/255)
term.setPaletteColor(colors.lightGray, 216/255, 222/255, 233/255)
term.setPaletteColor(colors.cyan, 136/255, 192/255, 208/255)
term.setPaletteColor(colors.purple, 0/255, 0/255, 0/255)  
term.setPaletteColor(colors.blue, 129/255, 161/255, 193/255)
term.setPaletteColor(colors.brown, 0/255, 0/255, 0/255)
term.setPaletteColor(colors.green, 163/255, 190/255, 140/255)
term.setPaletteColor(colors.red, 191/255, 97/255, 106/255)
term.setPaletteColor(colors.black, 59/255, 66/255, 82/255)
local sourceURL = "http://raw.githubusercontent.com/mirkokral/ccarcos/main"

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

-- function redraw()
  -- term.setBackgroundColor(colors.black)
  -- term.setTextColor(colors.white)
  -- term.clear()
  -- local tw, th = term.getSize()
  -- term.setCursorPos(tw/2-8<0.5 and math.floor(tw/2-8) or math.ceil(tw/2-8), th/2<0.5 and math.floor(th/2) or math.ceil(th/2))
  -- term.setTextColor(colors.blue)
  -- write("[")
  -- term.setTextColor(colors.magenta)
  -- for i = 0, (filesAlreadyDownloaded/filesToGo)*14, 1 do
  --   write("=")
  -- end
  -- for i = 0, 14-(filesAlreadyDownloaded/filesToGo)*14, 1 do
  --   write(" ")
  -- end
  -- term.setTextColor(colors.blue)
  -- write("]")
  -- if not wasSuccess then
  --   term.setTextColor(colors.red)
  -- end
  -- term.setCursorPos(tw/2-(#currentlyDownloadingFile/2)<0.5 and math.floor(tw/2-(#currentlyDownloadingFile/2)) or math.ceil(tw/2-(#currentlyDownloadingFile/2)), th/2<0.5 and math.floor(th/2+1) or math.ceil(th/2+1))
  -- write(currentlyDownloadingFile)
  -- if not wasSuccess then sleep(0.5) end
-- end

print("")
local indexFile, err = get(sourceURL .. "/build/objList.txt")
if not indexFile then
  print("Failed to get index file. Error: " .. err)
  print("Make sure your server has HTTP on. If it doesn't, use a release bundle lua from the releases section (when one gets released.)")
  error()
end

local indexFileContents = indexFile.readAll()
if not indexFileContents then error("Error reading index file. Make sure your server has HTTP on.") end

local index = mstrsplit(indexFileContents, "\n")
local dirsToBeCreated = {}
local filesToBeInstalled = {}

for _, v in ipairs(index) do
  if v:sub(1, 1) == "d" and not fs.exists(v:sub(3)) then
    table.insert(dirsToBeCreated, v:sub(3))
  end

  if v:sub(1, 1) == "r" and not fs.exists(v:sub(3)) then
    table.insert(filesToBeInstalled, v:sub(3))
  end

  if v:sub(1, 1) == "f" then
    table.insert(filesToBeInstalled, v:sub(3))
  end
end

filesToGo = #filesToBeInstalled
for _, dir in ipairs(dirsToBeCreated) do 
  fs.makeDir(dir)
end
for _, file in ipairs(filesToBeInstalled) do
  sleep(1)
end
