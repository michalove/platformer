Exit = object:New({
	tag = 'exit',
  marginx = 0.8,
  marginy = 0.8,
  vis = {Visualizer:New( 'exit'),},
})

function Exit:setAcceleration(dt)
end

function Exit:postStep(dt)
	if self:touchPlayer() then
		game.won = true
	end
end
