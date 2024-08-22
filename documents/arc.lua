

local function mstrsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function table.slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

local function numttostring(tbl)
  local outstring = ""
  for k, v in ipairs(tbl) do
    outstring = outstring .. string.char(v)
    print(v)
  end
  return outstring
end

local arkivelib = {
  ---Unachives an akv archive
  ---@param text number[]
  unarchive = function(text)
    local linebuf = ""
    local isReaderHeadInTable = true
    local offsetheader = {}
    local bufend = 0
    for k, v in ipairs(text) do
      if v == string.byte("\n") then
        if linebuf == "--ENDTABLE" then
          bufend = k+1
          isReaderHeadInTable=false
          break
        else
          table.insert(offsetheader, mstrsplit(linebuf, "|"))
        end
        linebuf = ""
      else
        linebuf = linebuf .. string.char(v)
      end
      print(linebuf)
    end
    local outputfiles = {}
    for k,v in pairs(offsetheader) do
      if offsetheader[k+1] then
        table.insert(outputfiles, {v[1], numttostring(table.slice(text, bufend+tonumber(v[2]), bufend+tonumber(offsetheader[k+1][2])-1 ))})
      else
        table.insert(outputfiles, {v[1], numttostring(table.slice(text, bufend+tonumber(v[2]), #text ))})
      end
      print(v[1])
      
    end
    
    --print(bufend)
    return outputfiles
  end
}
 

local fh = fs.open("archived.arc", "r")

local built = {}
while true
do
  local byte = fh.read(1)
  if byte == nil then break end
  table.insert(built, string.byte(byte))
end
fh.close()

local sqn = (arkivelib.unarchive(built))

for i, v in ipairs(sqn) do
  print(v[1], v[2])
end
