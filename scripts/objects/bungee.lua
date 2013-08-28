Bungee = object:New({	
	tag = 'Bungee',
	animation = 'bungee',
	marginx = 0.1,
  marginy = 0.1,
  speed = 50,
  maxLength = 10,
  minLength = 0.5,
})

function Bungee:setAcceleration(dt)
end

function Bungee:draw()
	object.draw(self)
	love.graphics.setLineWidth(Camera.scale*0.4)
	local r, g, b, a = love.graphics.getColor()	
	love.graphics.setColor(212,0,0)
	love.graphics.line(
		math.floor(self.x*myMap.tileSize),
		math.floor(self.y*myMap.tileSize),
		math.floor(p.x*myMap.tileSize),
		math.floor(p.y*myMap.tileSize))
	
	love.graphics.setColor(r,g,b,a)
end

function Bungee:postStep(dt)
	local dx,dy = self.x-p.x, self.y-p.y
	local length = math.sqrt(dx*dx+dy*dy)
	if length > self.maxLength then
		self:kill()
		return
	end
  if self.collisionResult > 0 then
		self.vx = 0
		self.vy = 0	
		p:connect(self)
  end
end

function Bungee:throw()
	game:checkControls()
	local rvx,rvy = p.vx, math.min(p.vy-self.speed,-self.speed)
	if game.isLeft then
		rvx = rvx - self.speed
	end
	if game.isRight then
		rvx = rvx + self.speed
	end
	if rvx ~= 0 then
		rvx,rvy = rvx/math.sqrt(2),rvy/math.sqrt(2)
	end
	local angle = math.atan2(rvy,rvx)
	local newBungee = self:New({x=p.x,y=p.y,vx=rvx,vy=rvy,angle=angle})
	spriteEngine:insert(newBungee)	
end

function Bungee:disconnect()
	self:kill()
end
