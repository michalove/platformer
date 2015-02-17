require 'scripts/objects.object'

spriteEngine = {
objects = {},
queue = {}
}

function spriteEngine:insert(newObject,pos)
	table.insert(self.queue,{obj = newObject, pos = pos})
end

function spriteEngine:addQueue()
	for k,v in pairs(self.queue) do
		local newObject = v.obj
		local pos = v.pos
		if newObject.init then
			newObject:init()
		end
		if newObject.preInsert then
			newObject:preInsert()
		end
		if pos then
			table.insert(self.objects,pos,newObject)
		else
			table.insert(self.objects,newObject)
		end
	end
	self.queue = {}
end

function spriteEngine:update(dt)
	local postpostList = {}
  for i,v in ipairs(self.objects) do
    if v.update then
      v:update(dt)
    end
    if v.postpostStep then
			table.insert(postpostList,v)
    end
  end
  for i,v in ipairs(postpostList) do
		v:postpostStep(dt)
  end
	Sound:setPositions()  
  self:kill()
  self:addQueue()
end

function spriteEngine:draw()
  for i = #self.objects,1,-1 do
    if self.objects[i].draw then
			self.objects[i]:draw()
	  end
  end
end

function spriteEngine:empty()
	Sound:stopAllLongSounds()
  self.objects = {}
end

function spriteEngine:sort()
	table.sort(self.objects, function(a,b) return a.z>b.z end)
end

function spriteEngine:kill()
-- erase 'dead' objects
  for i = #self.objects,1,-1 do
		local thisObject = self.objects[i]
		if thisObject.tag~= 'Player' and
			(thisObject.x < -1 or
		   thisObject.x > myMap.width +3 or
		   thisObject.y < -1 or
		   thisObject.y > myMap.height+3) then
			thisObject.dead = true
		end
		   
    if thisObject.dead then
			Sound:stopLongSound(thisObject)
			table.remove(self.objects,i)
			if thisObject.onKill then thisObject:onKill() end
		end
  end
end

function spriteEngine:DoAll(functionName,args)
  for i,v in ipairs(self.objects) do
		if v[functionName] then
		  v[functionName](v,args)
		end
	end
end
