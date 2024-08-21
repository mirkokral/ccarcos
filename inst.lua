lterm.setPaletteColor(colors.white, 236/255, 239/255, 244/255)
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

local filesAlreadyDownloaded = 7
local filesToGo = 24

function redraw()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  local tw, th = term.getSize()
  term.setCursorPos(tw/2-8, math.floor(th/2))
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
end

redraw()

