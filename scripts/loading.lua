local startTime
local loading = {
	step = -1,
	msg = "Scripts",
	done = false,-- set to true when everything has been loaded
}
local proverb
local source

-- Every time this function is called, the next step will be loaded.
-- Important: the loading.msg must be set to the name of the NEXT module, not the current one,
-- because love.draw gets called after love.update.
function loading.update()

	if not startTime then
		startTime = love.timer.getTime()
	end
	if loading.step == 0 then
		
		love.filesystem.createDirectory("userlevels")

		menu = require("scripts/menu/menu")
		parallax = require("scripts/parallax")
		BambooBox = require("scripts/bambooBox")
		
		-- loads all scripts and puts the necessary values into the global
		-- environment:
		keys = require("scripts/keys")
		--require("scripts/misc")
		shaders = require("scripts/shaders")

		require 'scripts/utility'
		require 'scripts/game'
		--require 'scripts/spritefactory'
		Map = require 'editor/editorMap'
		Sound = require 'scripts/sound'
		require 'scripts/sounddb'
		Sound:loadAll()
		require 'scripts/campaign'
		require 'scripts/levelEnd'
		Bridge = require 'scripts/bridge'
		objectClasses = require 'scripts/objectclasses'

		gui = require('scripts/gui')

		fader = require('scripts/fader')

		loading.msg = "Camera"
	elseif loading.step == 1 then
		Camera:applyScale()
		loading.msg = "Keyboard Setup"
	elseif loading.step == 2 then
		keys.load()
		loading.msg = "Gamepad Setup"
	elseif loading.step == 3 then
		keys.loadGamepad()
		loading.msg = "Menu"
	elseif loading.step == 4 then
		gui.init()	
		menu:init()	-- must be called after AnimationDB:loadAll()
		--BambooBox:init()
		upgrade = require("scripts/upgrade")		
		love.keyboard.setKeyRepeat( true )
		loading.msg = "Shaders"
	elseif loading.step == 5 then	
		if settings:getShadersEnabled() then
			shaders.load()
		end
		loading.msg = "Editor"
	elseif loading.step == 6 then
		editor = require("editor/editor")
		editor.init()
		loading.msg = "Campaign"
	elseif loading.step == 7 then
		recorder = false
		screenshots = {}
		recorderTimer = 0
		timer = 0
		Campaign:init()
		Campaign.bandana = config.getValue("bandana") or 'blank'
		loading.msg = "Shadows"
	elseif loading.step == 8 then
		shadows = require("scripts/monocle")
		loading.msg = "Levels"
	elseif loading.step == 9 then
		levelEnd:init()	-- must be called AFTER requiring the editor
		loading.msg = "Menu"
	elseif loading.step == 10 then
		loading.done = true
		-- temporary
		--springtime = love.graphics.newImage('images/transition/silhouette.png')
		--bg_test = love.graphics.newImage('images/menu/bg_main.png')		

	threadInterface.new( "version info",	-- thread name (only used for printing debug messages)
		"scripts/levelsharing/get.lua",	-- thread script
		"get",	-- function to call (inside script)
		menu.downloadedVersionInfo, nil,	-- callback events when done
		-- the following are arguments passed to the function:
		"version.php" )
	end
	if loading.done and love.timer.getTime() > startTime + 5 then
		menu:switchToSubmenu( "Main" )
		menu:show()	
	end
	loading.step = loading.step + 1
end

function loading.draw()
	--os.execute("sleep .5")
	love.graphics.setColor(colors.white)
	local str = "Loading: " .. loading.msg
	--print(str)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	if not loading.done then
		love.graphics.setColor(colors.grayText)
		love.graphics.setFont(fontSmall)
		love.graphics.print(str, math.floor(Camera.scale*5), math.floor(love.graphics.getHeight()-Camera.scale*8))
	end
	
	local width, lines = fontLarge:getWrap(proverb, 0.6*w)
	lines = #lines
	local textH = fontLarge:getHeight() * lines
	
	love.graphics.setColor(colors.blueText)
	love.graphics.setFont(fontLarge)
	love.graphics.printf(proverb, math.floor(0.2*w), math.floor(0.5*h-0.5*textH), 0.6*w, 'center')
	
	love.graphics.setColor(colors.grayText)
	love.graphics.setFont(fontSmall)
	love.graphics.printf(source, math.floor(0.5*w-0.5*width), math.floor(0.5*h + textH * 1), width,'right')

	if loading.done then
		love.graphics.printf( "Any Key to Start",
			math.floor(0.2*w), math.floor(love.graphics.getHeight()-Camera.scale*8),
			0.6*w, 'center' )
	end
end

function loading.preload()
-- This function does everything that is necessary before the loading 
-- screen can be shown: Set graphical mode and load font.
	settings:loadAll()
	Camera:init()	
	loadFont()

	-- hide mouse
	love.mouse.setVisible(false)
	
	local proverbs = {
	{"Perseverence is strength.",'Japanese Proverb'},
	{"Failure is the mother of success.",'Japanese Proverb'},
	{"Fall down seven times,\n stand up eight.",'Japanese Proverb'},
	{"Don't follow proverbs blindly!",'Proverb'},
	{"Don't go fishing while\n your house is on fire.",'Proverb'},
	{"An idiot won't be cured,\n unless he dies.",'Proverb'},
	{"If pushing hard does not work,\n try pulling!",'Proverb'},
	{"Many skills is no skill",'Proverb'},
	{"A frog in a well does not\n know the great sea",'Proverb'},
	{"I never said half the crap,\n people said I did",'Buddha'},
	}
	local nr = love.math.random(#proverbs)
	proverb = proverbs[nr][1]
	source = proverbs[nr][2]
	
	mode = 'loading'	
end

function loading.keypressed()
	if loading.done then
		menu:switchToSubmenu( "Main" )
		menu:show()
	end
end

--[[ some proverbs:
----------------
Source: http://en.wikiquote.org/wiki/Japanese_proverbs

継続は力なり。
Keizoku wa chikara nari.
Translation: Perseverance is strength.

愚公山を移す
Translation: Faith can move mountains.

亀の甲より年の功
Translation: Experience is the mother of wisdom.

虎穴に入らずんば虎子を得ず。
Koketsu ni irazunba koji wo ezu.
Translation: If you do not enter the tiger's cave, you will not catch its cub.

七転び八起き Nana korobi ya oki
Translation: Fall down seven times, stand up eight

能ある鷹は爪を隠す。Nō aru taka wa tsume wo kakusu.
Translation: The talented hawk hides its claws

--------------
Source: http://senseis.xmp.net/?GoProverbs
Don't follow proverbs blindly
Big dragons never die
Don't go fishing while your house is on fire
--]]

return loading
