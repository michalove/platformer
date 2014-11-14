
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
	activeSubmenu = "Main",
	parallaxPos = 0
}

local Submenu = require( "scripts/menu/submenu" )
local UserlevelSubmenu = require( "scripts/menu/userlevelsubmenu" )

local submenus = {}

local menuPlayer = {
	x = 0,
	y = 0,
}

function menu:init()

	-- Create the menu ninja:
	menuPlayer.vis = Visualizer:New( "playerWalk" )
	menuPlayer.visBandana = Visualizer:New("bandanaWalk")
	menuPlayer.vis:init()
	menuPlayer.visBandana:init()

	-- Create the ninja's Bandana
	menuPlayer.vis:setAni("playerWalk")
	menuPlayer.vis.sx = 1
	menuPlayer.visBandana:setAni("bandanaWalk")
	menuPlayer.visBandana.sx = 1

	-- Create the main menu:
	local mainMenu = Submenu:new()
	mainMenu:addImage( "logo", -85, -78 )
	local p = mainMenu:addPanel( -24, -20, 48, 80 )
	mainMenu:addButton( "startOff", "startOn", -3, -10,
		nil, self:setPlayerPositionEvent( -6, -5) )

	local switchToUserlevels = function()
		mainMenu:startExitTransition(
				function()
					self:switchToSubmenu( "Userlevels" )
				end )
	end
	
	mainMenu:addButton( "downloadOff", "downloadOn", -2, 0,
		switchToUserlevels, self:setPlayerPositionEvent( -6, 5) )
	mainMenu:addButton( "settingsOff", "settingsOn", -2, 10,
		nil, self:setPlayerPositionEvent( -6, 15) )
	mainMenu:addButton( "editorOff", "editorOn", -2, 20,
		nil, self:setPlayerPositionEvent( -6, 25) )
	mainMenu:addButton( "creditsOff", "creditsOn", -2, 30,
		nil, self:setPlayerPositionEvent( -6, 35) )

	local quit = function()
		mainMenu:startExitTransition( love.event.quit )
	end

	mainMenu:addButton( "exitOff", "exitOn", -2, 40,
		quit, self:setPlayerPositionEvent( -6, 45) )

	mainMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )

	mainMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Exit",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		quit )

	
	submenus["Main"] = mainMenu

	-- Create userlevel submenu:
	local userlevelsMenu = UserlevelSubmenu:new()

	submenus["Userlevels"] = userlevelsMenu

end

function menu:initMain()
	mode = 'menu'

	self.xCamera = 0
	self.yCamera = 0
	self.xTarget = 0
	self.yTarget = 0

	-- initialize parallax background
	parallax:init()

	--menu:switchToSubmenu( "Main" )
	menu:switchToSubmenu( "Main" )
end

function menu:switchToSubmenu( menuName )
	menu.activeSubmenu = menuName
	submenus[menu.activeSubmenu]:startIntroTransition()

	if menuName == "Main" then
		self.parallaxSlideTo = 0
		self.parallaxSlideStart = self.parallaxPos
		self.parallaxSlideTime = 0.5
		self.parallaxPassedTime = 0
		self.parallaxSlide = true
	else
		self.parallaxSlideTo = -1000
		self.parallaxSlideStart = self.parallaxPos
		self.parallaxSlideTime = 0.75
		self.parallaxPassedTime = 0
		self.parallaxSlide = true
	end
end

function menu:update( dt )
	--if menu.state == "main" then
		--parallax:update(dt)
	parallax:setPosition( self.parallaxPos )
	--end
	if self.parallaxSlide then
		self.parallaxPassedTime = self.parallaxPassedTime + dt
		if self.parallaxPassedTime < self.parallaxSlideTime then
			local amount = utility.interpolateCos( self.parallaxPassedTime/self.parallaxSlideTime )
			self.parallaxPos = self.parallaxSlideStart + 
				(self.parallaxSlideTo - self.parallaxSlideStart)*amount
		else
			self.parallaxPos = self.parallaxSlideTo
			self.parallaxSlide = false
		end
	end

	menuPlayer.vis:update(dt/2)
	menuPlayer.visBandana:update(dt/2)

	submenus[self.activeSubmenu]:update(dt)
end

function menu:updateLevelName( dt )
end

function menu:draw()

	--if menu.state == 'main' then
		parallax:draw()
	--end

	love.graphics.push()
	love.graphics.translate(
		-math.floor(self.xCamera*Camera.scale)+love.graphics.getWidth()/2,
		-math.floor(self.yCamera*Camera.scale)+love.graphics.getHeight()/2)

	-- Draw all visible panels:
	if self.activeSubmenu then
		submenus[self.activeSubmenu]:draw()

		-- If there's no transition in progress...
		if not submenus[self.activeSubmenu]:getTransition() then
			-- Draw the menu ninja:
			local x = menuPlayer.x*Camera.scale
			local y = menuPlayer.y*Camera.scale
			menuPlayer.vis:draw(x,y,true)

			local color = utility.bandana2color[Campaign.bandana]
			if color then
				local r,g,b = love.graphics.getColor()
				love.graphics.setColor(color[1],color[2],color[3],255)
				menuPlayer.visBandana:draw(x,y,true)
				love.graphics.setColor(r,g,b)
			end
		end
	end

	love.graphics.pop()
end

-- Remove every panel
function menu:clear()
	submenus = {}
end

function menu:drawTransition()
end

-- Todo: move this to GUI?
function menu:drawLevelName()
end

function menu:keypressed( key, repeated )
	if self.activeSubmenu then
		-- Don't let user control menu while a transition is active:
		if not submenus[self.activeSubmenu]:getTransition() then
			if key == keys.LEFT then
				submenus[self.activeSubmenu]:goLeft()
			elseif key == keys.RIGHT then
				submenus[self.activeSubmenu]:goRight()
			elseif key == keys.UP then
				submenus[self.activeSubmenu]:goUp()
			elseif key == keys.DOWN then
				submenus[self.activeSubmenu]:goDown()
			elseif key == keys.CHOOSE then
				submenus[self.activeSubmenu]:startButtonEvent()
			else
				submenus[self.activeSubmenu]:hotkey( key )
			end
		end
	end
end

function menu:textinput( letter )
end

function menu:downloadedVersionInfo( info )
end

function menu:setPlayerPosition( x, y )
	menuPlayer.x = x
	menuPlayer.y = y
end

function menu:setPlayerPositionEvent( x, y )
	return function()
		menuPlayer.x = x
		menuPlayer.y = y
	end
end

function menu:setPlayerAnimation( animation )
end

----------------------------------------------------------------------
-- Menu transitions:
----------------------------------------------------------------------


return menu
