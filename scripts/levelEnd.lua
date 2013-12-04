
-- pictures for level end display:
local pics = require("scripts/levelEndPic")

levelEnd = {}

local deathList = {}
local statList = {}
local boxes = {}


function levelEnd:reset()
	deathList["fall"] = 0
	deathList["shuriken"] = 0
	deathList["goalie"] = 0
	deathList["imitator"] = 0
	deathList["missile"] = 0
	deathList["spikey"] = 0
	deathList["runner"] = 0
	deathList["walker"] = 0
	statList["highestJump"] = 0
	statList["farthestJump"] = 0 
	statList["timeInAir"] = 0
	statList["idleTime"] = 0
	statList["numberOfJumps"] = 0
	statList["longestWallHang"] = 0
	statList["numberOfButtons"] = 0
	pics:reset()
end

function levelEnd:addDeath( deathType )
	deathList[deathType] = deathList[deathType] + 1
end

function levelEnd:draw()
	shaders:setDeathEffect( .8 )
	--shaders.grayScale:send( "amount", .8 )
	--love.graphics.setPixelEffect( shaders.grayScale )
	--game:draw()
	--love.graphics.setPixelEffect()
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	-- for now, just show a simple list:
	
	-- draw boxes:	
	for k,element in pairs(boxes) do
		-- scale box coordinates according to scale
		local scaled = {}
		for i = 1,#element.points do
			scaled[i] = element.points[i] * Camera.scale
		end
		-- draw
		love.graphics.setColor(44,90,160)
		love.graphics.setLineWidth(Camera.scale*0.5)
		love.graphics.rectangle('fill',
			element.left*Camera.scale,
			element.top*Camera.scale,
			element.width*Camera.scale,
			element.height*Camera.scale)
		love.graphics.setColor(0,0,10)
		love.graphics.line(scaled)
	end
	
	local font = love.graphics.getFont()
	local i = 0
	for m, list in pairs( { deathList, statList }) do
		for k, v in pairs( list ) do
			love.graphics.setColor(110,168,213)
			love.graphics.print(k, - font:getWidth(k) + 55, - font:getHeight()*(12 -i))
			love.graphics.setColor(255,255,255)
			love.graphics.print(v, 60, - font:getHeight()*(12-i))
			i = i+1
		end
	end

	pics:draw()

	love.graphics.pop()

	controlKeys:draw("win")
end

function levelEnd:display( )	-- called when level is won:
	mode = 'levelEnd'
	love.graphics.setBackgroundColor(40,40,40)
	boxes = {}
	self:addBox(-30,-60,60,80)
	
	--deathList["fall"] = math.random(26)	--debug
	
	if deathList["fall"] > 0 then
		self:addBox(-100,-20,60,40)
		pics:new( -70, 0, "fall", deathList["fall"] )
	end
	
	--deathList["spikey"] = math.random(26)	--debug
	if deathList["spikey"] > 0 then
		self:addBox(40,-20,60,40)
		pics:new( 70, 0, "spikes", deathList["spikey"] )
	end
end

function levelEnd:keypressed( key, unicode )
	if key == 'escape' then
		Campaign:setLevel(Campaign.current+1)
		Campaign:saveState()
		menu.startTransition(menu.initWorldMap)()	-- start the transition and fade into world map
		
	else
	  menu.startTransition(function () Campaign:proceed() end)()
	end
end

function levelEnd:addBox(left,top,width,height)
	local new = {}
	new.points = {}
	new.left = left
	new.top = top
	new.width = width
	new.height = height
	local index = 1
	local stepsize = 0
	table.insert(new.points, left)
	table.insert(new.points, top)
	for i = 1,math.floor(.2*width) do
		stepsize = width/math.floor(.2*width)
		table.insert(new.points, left + i*stepsize)
		table.insert(new.points, top)
	end
	
	for i = 1,math.floor(.2*height) do
		stepsize = height/math.floor(.2*height)
		table.insert(new.points, left+width)
		table.insert(new.points, top + i*stepsize)
	end
	
	for i = 1,math.floor(.2*width) do
		stepsize = width/math.floor(.2*width)
		table.insert(new.points, left + width - i*stepsize)
		table.insert(new.points, top + height)
	end
		
	for i = 1,math.floor(.2*height) do
		stepsize = height/math.floor(.2*height)
		table.insert(new.points, left)
		table.insert(new.points, top + height - i*stepsize)
	end
	
	for i = 1,#new.points-2 do
		new.points[i] = new.points[i] + 0.4*math.random() - 0.4*math.random()
	end
	new.points[#new.points-1] = new.points[1]
	new.points[#new.points] = new.points[2]

	table.insert(boxes, new)
end

function levelEnd:registerJumpStart( x, y )
	print("jump from:", x, y)
	levelEnd.jump = {x=x, y=y}
end
function levelEnd:registerJumpEnd( x, y )
	print("landed @:", x, y)
	if levelEnd.jump then
		if math.abs(levelEnd.jump.x - x) > statList["farthestJump"] then
			statList["farthestJump"] = math.abs(levelEnd.jump.x - x)
		end
		levelEnd.jump = nil
	end
end

function levelEnd:registerButton()

end
