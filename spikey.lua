Spikey = object:New({
	tag = 'spikey',
  img = love.graphics.newImage('images/spikey.png'),
  marginx = 0.8,
  marginy = 0.8,
})

function Spikey:setAcceleration(dt)
	if self:touchPlayer() then  -- Kill player, if touching
    p.dead = true
  end
end
Spikeys = {
[1] = Spikey:New({animation='Spikey1'}),
[2] = Spikey:New({animation='Spikey2'}),
[3] = Spikey:New({animation='Spikey3'}),
[4] = Spikey:New({animation='Spikey4'}),
[5] = Spikey:New({animation='Spikey5'}),
[6] = Spikey:New({animation='Spikey6'}),
[7] = Spikey:New({animation='Spikey7'}),
[8] = Spikey:New({animation='Spikey8'}),
[9] = Spikey:New({animation='Spikey9'}),
[10] = Spikey:New({animation='Spikey10'}),
[11] = Spikey:New({animation='Spikey11'}),
[12] = Spikey:New({animation='Spikey12'}),
[13] = Spikey:New({animation='Spikey13'}),
[14] = Spikey:New({animation='Spikey14'}),
[15] = Spikey:New({animation='Spikey15'}),
[16] = Spikey:New({animation='Spikey16'}),}

--[[for i=1,16 do
  Spikeys[i]:updateAnimation(0)
end--]]