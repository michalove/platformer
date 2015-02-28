local Laser = object:New({
	tag = 'Laser',
	category = 'Enemies',
  --firerate = 1.2, -- in seconds
  --velocity = 15,
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  solid = true,
  isFiring = false,
  vis = {
		Visualizer:New('laser'),
		Visualizer:New('laserDot',{active = false}),
	},
	properties = {
		angle = utility.newCycleProperty({0, 1, 2, -1}, {'right', 'down', 'left', 'up'}),
		timeOn = utility.newIntegerProperty(10,0.1,5,0.1),
		timeOff = utility.newIntegerProperty(10,0.1,5,0.1),
		phase = utility.newCycleProperty({0, .1, .2, .3, .4, .5, .6, .7, .8, .9}),

	},
})

function Laser:applyOptions()
	self.vis[1].angle = self.angle*0.5*math.pi
	self.vis[2].angle = self.angle*0.5*math.pi
	
	-- determine normal and parallel vector
	self.ex = math.cos(self.angle*0.5*math.pi)
	self.ey = math.sin(self.angle*0.5*math.pi)
	self.nx = -self.ey
	self.ny = self.ex
	
	self.sx = self.x + 0.5*self.ex
	self.sy = self.y + 0.5*self.ey
	
	-- determine endpoints:
	if myMap then
		if self.angle == 0 then
			self.endx = myMap.width+1
			self.endy = self.y
		elseif self.angle == 1 then
			self.endx = self.x
			self.endy = myMap.height+1
		elseif self.angle == 2 then
			self.endx = -1
			self.endy = self.y
		elseif self.angle == -1 then
			self.endx = self.x
			self.endy = -1
		end
	else
		self.endx = self.x
		self.endy = self.y
	end	
end

function Laser:draw()
	if self.isFiring and self.tx then
		love.graphics.setLineWidth(Camera.scale*0.6)
		love.graphics.setColor(127,0,0)
		love.graphics.line(
			math.floor(self.sx*myMap.tileSize),
			math.floor(self.sy*myMap.tileSize),
			math.floor(self.tx*myMap.tileSize),
			math.floor(self.ty*myMap.tileSize))
			
		love.graphics.setLineWidth(Camera.scale*0.2)
		love.graphics.setColor(255,0,0)
		love.graphics.line(
			math.floor(self.sx*myMap.tileSize),
			math.floor(self.sy*myMap.tileSize),
			math.floor(self.tx*myMap.tileSize),
			math.floor(self.ty*myMap.tileSize))			
			
		love.graphics.setColor(255,255,255)
		
		
	end
	self.vis[2].active = (self.isFiring and self.tx)
	object.draw(self)
end

function Laser:setAcceleration()
end

function Laser:postStep(dt)
	local timeTot = self.timeOn+self.timeOff
	self.phase = (self.phase - dt / timeTot)%1
	if self.phase < self.timeOff/timeTot then
		self.isFiring = true
	else
		self.isFiring = false
	end
end

function Laser:postpostStep(dt)
	-- relative position of player
	local dx,dy = p.x-self.sx,p.y-self.sy
	local distance = self.nx * dx + self.ny * dy
	local position = self.ex * dx + self.ey*dy
	
	if self.isFiring then
		if myMap then -- find endpoints
			local free,tx,ty = myMap:lineOfSight(self.sx,self.sy,self.endx,self.endy)
			if not free then
				self.tx = tx
				self.ty = ty
			else
				self.tx = self.endx
				self.ty = self.endy
			end
			self.vis[2].relX = self.tx-self.x
			self.vis[2].relY = self.ty-self.y			
		end
		-- check for player hit
		local length = utility.pyth(self.tx-self.sx,self.ty-self.sy)
		
		if position > 0 and position < length and not p.dead then
			local crossed = (distance * self.distanceOld <= 0)
			
			local dd -- determine relevant dimension of player
			if self.angle == 0 or self.angle == 2 then
				dd = p.semiheight
			else
				dd = p.semiwidth 
			end
			
			if (crossed or math.abs( distance) < dd ) then
				p:kill()
				objectClasses.Meat:spawn(p.x,p.y,0,0)
			end
		end
	end
	self.distanceOld = distance
end

return Laser
