
local MOD = 2^32
local MODM = MOD-1

local function memoize(f)
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k)
		t[k] = v
		return v
	end
	return t
end

local function make_bitop_uncached(t, m)
	local function bitop(a, b)
		local res,p = 0,1
		while a ~= 0 and b ~= 0 do
			local am, bm = a % m, b % m
			res = res + t[am][bm] * p
			a = (a - am) / m
			b = (b - bm) / m
			p = p*m
		end
		res = res + (a + b) * p
		return res
	end
	return bitop
end

local function make_bitop(t)
	local op1 = make_bitop_uncached(t,2^1)
	local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)
	return make_bitop_uncached(op2, 2 ^ (t.n or 1))
end

local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})

local function bxor(a, b, c, ...)
	local z = nil
	if b then
		a = a % MOD
		b = b % MOD
		z = bxor1(a, b)
		if c then z = bxor(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return 0 end
end

local function band(a, b, c, ...)
	local z
	if b then
		a = a % MOD
		b = b % MOD
		z = ((a + b) - bxor1(a,b)) / 2
		if c then z = require("bit32").band(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return MODM end
end

local function bnot(x) return (-1 - x) % MOD end

local function lshift(a, disp)
---@diagnostic disable-next-line: undefined-global
	if disp < 0 then return rshift(a,-disp) end 
	return (a * 2 ^ disp) % 2 ^ 32
end

local function rshift1(a, disp)
	if disp < 0 then return lshift(a,-disp) end
	return math.floor(a % 2 ^ 32 / 2 ^ disp)
end

local function rshift(x, disp)
	if disp > 31 or disp < -31 then return 0 end
	return rshift1(x % MOD, disp)
end


local function rrotate(x, disp)
    x = x % MOD
    disp = disp % 32
    local low = band(x, 2 ^ disp - 1)
    return rshift(x, disp) + lshift(low, 32 - disp)
end

local k = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function str2hexa(s)
	return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
end

local function num2s(l, n)
	local s = ""
	for i = 1, n do
		local rem = l % 256
		s = string.char(rem) .. s
		l = (l - rem) / 256
	end
	return s
end

local function s232num(s, i)
	local n = 0
	for i = i, i + 3 do n = n*256 + string.byte(s, i) end
	return n
end

local function preproc(msg, len)
	local extra = 64 - ((len + 9) % 64)
	len = num2s(8 * len, 8)
	msg = msg .. "\128" .. string.rep("\0", extra) .. len
	assert(#msg % 64 == 0)
	return msg
end

local function initH256(H)
	H[1] = 0x6a09e667
	H[2] = 0xbb67ae85
	H[3] = 0x3c6ef372
	H[4] = 0xa54ff53a
	H[5] = 0x510e527f
	H[6] = 0x9b05688c
	H[7] = 0x1f83d9ab
	H[8] = 0x5be0cd19
	return H
end

local function digestblock(msg, i, H)
	local w = {}
	for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
	for j = 17, 64 do
		local v = w[j - 15]
		local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
		v = w[j - 2]
		w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
	end

	local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
	for i = 1, 64 do
		local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
		local maj = bxor(band(a, b), band(a, c), band(b, c))
		local t2 = s0 + maj
		local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
		local ch = bxor (band(e, f), band(bnot(e), g))
		local t1 = h + s1 + ch + k[i] + w[i]
		h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
	end

	H[1] = band(H[1] + a)
	H[2] = band(H[2] + b)
	H[3] = band(H[3] + c)
	H[4] = band(H[4] + d)
	H[5] = band(H[5] + e)
	H[6] = band(H[6] + f)
	H[7] = band(H[7] + g)
	H[8] = band(H[8] + h)
end

---Hash msg into sha256
---@param msg string
---@return string
local function sha256(msg)
	msg = preproc(msg, #msg)
	local H = initH256({})
	for i = 1, #msg, 64 do digestblock(msg, i, H) end
	return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..
		num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
end

-- arc install command ported to craftos
function getChosenRepo()
  return "mirkokral/ccarcos"
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
local ncommit = textutils.unserializeJSON(fr.readAll()).sha 
local cnURL = "http://raw.githubusercontent.com/" .. getChosenRepo() .. "/" .. ncommit
local sourceURL = cnURL .. "/archivedpkgs/"
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


--if not indexFileContents then error("Error reading index file. Make sure your server has HTTP on.") end

local arkivelib = {
  ---Unachives an akv archive
  ---@param text string
  unarchive = function(text)
    local linebuf = ""
    local isReaderHeadInTable = true
    local offsetheader = {}
    local bufend = 0
    for k = 0, #text, 1 do
      local v = text:sub(k, k)
      if v == "\n" then
        if linebuf == "--ENDTABLE" then
          bufend = k + 1
          isReaderHeadInTable = false
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
    for k, v in ipairs(offsetheader) do
      if v[2] == "-1" then
        table.insert(outputfiles, { v[1], nil })
      elseif offsetheader[k + 1] then
        table.insert(outputfiles, { v[1], text:sub(bufend + tonumber(v[2]), bufend + tonumber(offsetheader[k + 1][2]) - 1) })
      else
        table.insert(outputfiles, { v[1], text:sub(bufend + tonumber(v[2]), #text) })
      end
      --print(v[1])
      currentlyDownloadingFile = "Extracting..."
      filesToGo = #offsetheader
      filesAlreadyDownloaded = k
      wasSuccess = true
    end

    --print(bufend)
    return outputfiles
  end
}


function installPackageS1(tpkg)
  local dataFile, err = get(sourceURL .. tpkg .. ".arc")
  print(sourceURL .. "/" .. tpkg .. ".arc")
  if not dataFile then
    print("Failed to get index file. Error: " .. err)
    print(
    "Make sure your server has HTTP on. If it doesn't, use a release zip from the releases section (when one gets released.)")
    error()
  end
  local indexFileContents = dataFile.readAll()
  local uninstallIndexLines = {}
  local data = arkivelib.unarchive(indexFileContents)
  for k, v in ipairs(data) do
    if v[2] == nil then
      fs.makeDir("/" .. v[1])
      table.insert(uninstallIndexLines, "d> " .. v[1])
    else
      if fs.exists("/" .. v[1]) then fs.delete("/" .. v[1]) end
      local f, e = fs.open("/" .. v[1], "w")
      if f then
        f.write(v[2]) 
        f.close()
      else
        print(e)
        sleep(5)
      end
      table.insert(uninstallIndexLines, "f> " .. sha256(v[2]) .. " " .. v[1])
    end
  end

end

function installPackage(tpkg)
  print("Bootstrapping " .. tpkg)
  print(cnURL .. "/repo/" .. tpkg .. "/entry")
  local iFile, err = get(cnURL .. "/repo/" .. tpkg .. "/entry")
  if not iFile then error(err) end
  local ind = textutils.unserializeJSON(iFile.readAll())
  for k, v in ipairs(ind.dependencies) do
    installPackage(v)
  end
  installPackageS1(tpkg)
  if not fs.exists("/config") then fs.makeDir("/config") end
  if not fs.exists("/config/arc") then fs.makeDir("/config/arc") end
  local f, e = fs.open("/config/arc/" .. tpkg .. ".meta.json", "w")
  f.write(textutils.serializeJSON(ind))
  f.close()
  local fn, en = fs.open("/config/arc/latestCommit", "w")
  if not fn then error(en) end
  fn.write(ncommit)
  fn.close()
end

installPackage(...)
print("Bootstrapping finished")