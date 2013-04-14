loader = require("AdvTiledLoader/Loader")

function love.load()

	loader.path = "maps/"
	local files = love.filesystem.enumerate(loader.path)
	for k, file in ipairs(files) do
		if string.sub(file,-4,-1) == '.tmx' then
		  local trunc = string.sub(file,1,-5)
		  convert(trunc)
		end
	end

  print('Done')
  love.event.push("quit")
end


function convert(filetrunc)
print('Converting '..filetrunc..'.tmx')
map = loader.load(filetrunc .. '.tmx')

data = {}
for y = 1,map.height do
  data[y] = {}
		for x = 1,map.width do
    data[y][x] = 0
  end
end
  for x, y, tile in map("bg"):iterate() do
    data[y][x] = tile.id
--    print( string.format("Tile at (%d,%d) has an id of %d", x, y, tile.id) )
  end

height = #data
width = #data[1]
--print(width)
--print(height)

filename = ''
for i,v in pairs(map.tilesets) do
  filename = i .. '.png'
end


tileToCollision = { -- Tilemap information, only correct for ruin map
  1,1,1,1,1,1,
  1,1,1,1,1,1,
  0,1,1,1,1,1,
  0,1,1,1,1,1,
  0,1,1,1,1,1,
  0,1,1,1,1,1,
  0,1,1,1,1,1,
  1,1,1,1,1,0
}
tileToCollision[0] = 0

backstring = ''
backstring2 = ''


for j = 1,width do
	local newlinesymbol = '\},\r\n'
	if j == width then newlinesymbol = '\}\r\n' end
	for i = 1,height do
	  local filler = ','
	  if i == 1 then filler = '  \{' end
		if data[i] and data[i][j] then
--      print(data[i][j])
			backstring = backstring .. filler .. data[i][j]
			backstring2 = backstring2 .. filler .. tileToCollision[data[i][j]]
		else
			backstring = backstring .. filler .. '0'
			backstring2 = backstring2 .. filler .. '0'
		end
	end
	backstring = backstring .. newlinesymbol
	backstring2 = backstring2 .. newlinesymbol
end

writedata = ''
writedata = writedata .. 'mapSize(' .. width .. ', ' .. height .. ', ' .. map.tileWidth .. ')\r\n'
writedata = writedata .. 'imageFilename("'..filename..'")'.. '\r\n'
writedata = writedata .. 'loadTiles\{\r\n' .. backstring .. '\}\r\n'
writedata = writedata .. 'loadCollision\{\r\n' .. backstring2 .. '\}'

-- print(writedata)
love.filesystem.write(filetrunc..'.dat',writedata)
end

function love.keypressed(key)   -- we do not need the unicode, so we can leave it out
   if key == "escape" then
      love.event.push("quit")   -- actually causes the app to quit
   end
end
