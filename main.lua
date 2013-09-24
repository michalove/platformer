-- main menu test


loading = require("scripts/loading")


mode = 'menu'	-- must be global
fullscreenCanvas = nil		-- initialized and maintained in settings:setWindowSize()
DEBUG = false
USE_SHADERS = true

-- temporary
springtime = love.graphics.newImage('images/transition/silhouette.png')


function love.load(args)


	for k, v in pairs(arg) do
		if v == "--debug" or v == "-d" then
			DEBUG = true
		end
		if v == "--no-shaders" or v == "-n" then
			USE_SHADERS = false
			print("Manually disabled shaders.")
		end
		if v == "--shadows" or v == "-s" then
			USE_SHADOWS = true
			print("Enabled shadows")
		end
	end

	-- hide mouse
	love.mouse.setVisible(false)
	
	mode = 'loading'
end

function love.update( dt )

	if mode == 'loading' then
		loading.update( dt )
	else
		if USE_SHADOWS and shadows.needsShadowUpdate then
			if myMap then
				myMap:updateShadows()
			end
		end

		if mode == 'game' then
			game:update(dt)
		elseif mode == 'menu' then
			menu:update(dt)
		elseif mode == 'intro' then
			intro:update(dt)
		end
	
		if menu.transitionActive then
			menu.transitionPercentage = menu.transitionPercentage + dt*1000	-- 1 second
			if USE_SHADERS then
				shaders.fadeToBlack:send("percentage", menu.transitionPercentage)
			end
			if menu.transitionPercentage >= 50 and menu.transitionEvent then
				menu.transitionEvent()
				menu.transitionEvent = nil		
			end
			if menu.transitionPercentage >= 100 then
				menu.transitionActive = false		
			end
		end

		keys.catchGamepadEvents()
	end
	--print(love.joystick.getHat(1,1), love.joystick.getHat(1,2), love.joystick.getHat(1,3))
	--vis:update(dt)
end

local a = 0

function love.draw()

	--shaders.grayScale:send( "amount", 0.5+0.5*math.sin(love.timer.getTime()) )
	--love.graphics.setPixelEffect( shaders.grayScale )
	if mode == 'loading' then
		loading.draw()
	else
		if USE_SHADERS and menu.transitionActive then
			love.graphics.setCanvas(fullscreenCanvas)
			fullscreenCanvas:clear()
			love.graphics.setColor(love.graphics.getBackgroundColor())
			love.graphics.rectangle('fill', 0, 0, fullscreenCanvas:getWidth(), fullscreenCanvas:getHeight())
			love.graphics.setColor(255,255,255,255)
		end

		if mode == 'game' then
			game:draw()
		elseif mode == 'menu' then
			menu:draw()
		elseif mode == 'intro' then
			intro:draw()
		elseif mode == 'levelEnd' then
			levelEnd:draw()
		end
	
		if USE_SHADERS and menu.transitionActive then
			love.graphics.setCanvas()
			love.graphics.setPixelEffect( shaders.fadeToBlack )
			love.graphics.draw(fullscreenCanvas, 0, 0)
			love.graphics.setPixelEffect()
		end
	
		if menu.transitionActive and menu.transitionPercentage < 50 then	
			local sx = (menu.transitionPercentage/15)^3
		
			love.graphics.draw(springtime,640,400,0,sx,sx,120,130)
		end
	
		if DEBUG then
			love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 20)
		end
	end
	
	--love.graphics.setPixelEffect()
	--vis:draw(100,100)
end

function love.keypressed( key, unicode )
	
	if menu.transitionActive then return end
	
	if keys.currentlyAssigning then
		if menu.state == 'keyboard' then
			print("new", key)
			keys.assign( key )
		end
		return
	else
	
		if key == keys.FULLSCREEN then
			settings:toggleFullScreen()
		end

		if mode == 'menu' then
			menu:keypressed( key, unicode )
		elseif mode == 'game' then
			game.keypressed( key )
		elseif mode == 'levelEnd' then
			levelEnd:keypressed( key, unicode )
		end

		-- always works, independently of game state:
		if key == keys.SCREENSHOT then
			love.graphics.newScreenshot():encode('screenshot.png')
			print('Saved screenshot')
		end
		if key == keys.RESTARTMAP then
			myMap:start(p)
		end
		if key == keys.RESTARTGAME then
			Campaign:reset()
			myMap:start(p)
		end
	end
end


function love.keyreleased(key)
	if mode == 'game' then
		game.keyreleased(key)
	end
end

function love.joystickpressed(joystick, button)
	if keys.currentlyAssigning then	
		if menu.state == 'gamepad' then
			keys.assign( tostring(button) )
		end
		return	
	end

	if mode == 'game' then
		game.joystickpressed(joystick, button)
	end
	--if button == 9 then Campaign:reset() myMap:start(p) end
end

function love.joystickreleased(joystick, button)
	if mode == 'game' then
		game.joystickreleased(joystick, button)
	end
end
