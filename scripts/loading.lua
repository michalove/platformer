
require 'scripts/font'

local loading = {
	step = -1,
	msg = "scripts",
}

-- Every time this function is called, the next step will be loaded.
-- Important: the loading.msg must be set to the name of the NEXT module, not the current one,
-- because love.draw gets called after love.update.
function loading.update()

	if loading.step == 0 then
		menu = require("scripts/menu")
		
		-- loads all scripts and puts the necessary values into the global
		-- environment:
		
		config = require("scripts/config")
		settings = require("scripts/settings")
		keys = require("scripts/keys")
		require("scripts/misc")
		shaders = require("scripts/shaders")

		require 'scripts/utility'
		require 'scripts/camera'
		require 'scripts/game'
		require 'scripts/spritefactory'
		require 'scripts/map'
		require 'scripts/intro'
		require 'scripts/campaign'
		require 'scripts/levelEnd'
		
		
		loading.msg = "camera"
	elseif loading.step == 1 then
		-- set screen resolution (and fullscreen)
		Camera:init()
		loading.msg = "animation"
	elseif loading.step == 2 then
		-- load all images
		AnimationDB:loadAll()
		loading.msg = "keyboard setup"
	elseif loading.step == 3 then
		keys.load()
		loading.msg = "menu"
	elseif loading.step == 4 then
		menu:init()	-- must be called after AnimationDB:loadAll()
		loading.msg = "shaders"
	elseif loading.step == 5 then	
		if USE_SHADERS then
			shaders.load()
		end
		loading.msg = "campaign"
	elseif loading.step == 6 then
		recorder = false
		screenshots = {}
		recorderTimer = 0

		timer = 0

		Campaign:reset()
		loading.msg = "main menu"
	elseif loading.step == 7 then
		mode = 'menu'
		menu.initMain()
		loading.msg = "shadows"
	elseif loading.step == 8 then
		shadows = require("scripts/monocle")
	end
	loading.step = loading.step + 1
end

function loading.draw()
	--os.execute("sleep .5")
	love.graphics.setColor(255,255,255,255)
	local str = "loading: " .. loading.msg
	print(loading.msg)
	love.graphics.print(str, 20, 20)
end

return loading