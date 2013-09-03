Visualizer = {
	--[[angle = 0,
	timer = 0,
	frame = 0,
	flipped = false
	ox = 0,
	oy = 0,
	alpha = 255,
	sx = 1,
	sy = 1,
	relx = 0,
	rely = 0,--]]
--	currentQuad
--	img
}

function Visualizer:New(name,input)
  local o = input or {}
  o.animation = name or ''
  o.timer = o.timer or 0
  o.frame = o.frame or 1
  o.sx, o.sy = o.sx or 1, o.sy or 1
  o.relX, o.relY = o.relX or 0, o.relY or 0
  o.angle = o.angle or 0
  o.alpha = o.alpha or 255
	setmetatable(o, self)
	self.__index = self
	o:init()
	return o
end

function Visualizer:init()
	local name = AnimationDB.animation[self.animation].source
	self.ox = self.ox or 0.5*AnimationDB.source[name].width/Camera.scale
	self.oy = self.oy or 0.5*AnimationDB.source[name].height/Camera.scale
end

function Visualizer:copy()
  local o = Visualizer:New(self.animation)
  o.timer = self.timer or 0
  o.frame = self.frame or 1
  o.sx, o.sy = self.sx or 1, self.sy or 1
  o.angle = self.angle or 0
  o.alpha = self.alpha or 255
  o.relX, o.relY = self.relX or 0, self.relY or 0
  o:init()
  return o
end

function Visualizer:reset()
	self.frame = 1
	self.timer = 0
end

function Visualizer:draw(x,y)
	love.graphics.setColor(255,255,255,self.alpha)
	if self.img and self.currentQuad then
		love.graphics.drawq(self.img, self.currentQuad,
			x+self.relX*Camera.scale*8,y+self.relY*Camera.scale*8,
			self.angle,
			self.sx,self.sy,
			self.ox*Camera.scale,self.oy*Camera.scale)
	end
end

function Visualizer:update(dt)

  self.timer = self.timer + dt
  -- switch to next frame
  if self.animation then
		local animationData = AnimationDB.animation[self.animation]
		if animationData then -- only advance, if the animation exists in DB
			local source = AnimationDB.source[animationData.source]
			while self.timer > animationData.duration[self.frame] do
				self.timer = self.timer - animationData.duration[self.frame]
				self.frame = self.frame + 1
				if self.frame > #animationData.frames then
					self.frame = 1
				end
			end
			self.currentQuad = source.quads[animationData.frames[self.frame]]
			self.img = source.image
		else -- if animation does not exists
			self.img = nil
		end
  end
end

function Visualizer:setAni()
	if self.animation ~= name then
	  self.animation = name
	  if not continue then
	    self:reset()
	  end
	end
end