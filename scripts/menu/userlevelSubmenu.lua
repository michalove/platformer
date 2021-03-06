local UserlevelSubmenu = {}

--local userlevelFilters
local currentSorting
local sortingSchemes = {
	"Levelname ascending",
	"Levelname descending",
	"Author ascending",
	"Author descending",
	"Fun rating ascending",
	"Fun rating descending",
	"Difficulty rating ascending",
	"Difficulty rating descending",
}
local userlevels = {}
--local userlevelsFiltered = {}
local userlevelsByAuthor = {}

local Submenu = require( "scripts/menu/submenu" )
local Userlevel = require("scripts/levelsharing/userlevel")
local HotkeyDisplay = require("scripts/menu/hotkeyDisplay")
local submenu	-- use this to remember the current sub menu

local LIST_WIDTH = 100	-- Dummy value
local LIST_HEIGHT = 100	-- Dummy value
local LIST_ENTRY_HEIGHT = 8
local selectedUserlevel
local firstDisplayedUserlevel
local displayedUserlevels = 8
local arrowUpVis, arrowDownVis
local sortingIndicator = {}
local buttonWarning

function UserlevelSubmenu:new( x, y )
	local width = love.graphics.getWidth()/Camera.scale - 16
	local height = love.graphics.getHeight()/Camera.scale - 32
	width = 8*math.floor(width/8)
	height = 8*math.floor(height/8)

	LIST_WIDTH = width
	LIST_HEIGHT = height
	displayedUserlevels = (LIST_HEIGHT-16)/(LIST_ENTRY_HEIGHT) - 1

	submenu = Submenu:new( x, y )
	
	local p = submenu:addPanel( -LIST_WIDTH/2, -LIST_HEIGHT/2 - 8, LIST_WIDTH, LIST_HEIGHT )
	p:turnIntoList( LIST_ENTRY_HEIGHT, 2 )
	--local l = submenu:addLayer( "Filters" )
	--submenu:setLayerVisible( "Filters", false )
	--submenu:addPanel( -LIST_WIDTH/2 + 8, 0, LIST_WIDTH - 16, LIST_HEIGHT/2 - 8, "Filters" )

	selectedUserlevel = 1
	firstDisplayedUserlevel = 1

	userlevels = {}
	userlevelsByAuthor = {}
	--userlevelsFiltered = {}

	-- Only load settings when starting the userlevel list for the first time:
	--[[if not self.userlevelFilters then
		userlevelFilters = {
			sorting = 1,
			authorizedOnly = true,
			downloadedOnly = false,
		}
		submenu.loadedUserlevelFilters = true
		local val
		val = config.getValue( "LevelsFilterAuthorized" )
		if val ~= nil then userlevelFilters.authorizedOnly = val end
		--val = config.getValue( "LevelsFilterDownloaded" )
		--if val ~= nil then userlevelFilters.downloadedOnly = val end
		val = config.getValue( "LevelsSorting" )
		if val ~= nil then
			userlevelFilters.sorting =
				math.min(math.max(math.floor(tonumber(val)), 1), #sortingSchemes )
		end
	end]]

	-- Extend the original drawing functions of the submenu class:
	submenu:addCustomDrawFunction( UserlevelSubmenu.drawUserlevels, "MainLayer" )
	submenu:addCustomUpdateFunction( function(dt) UserlevelSubmenu:update( dt ) end, "MainLayer" )

	UserlevelSubmenu:loadDownloadedUserlevels()

	-- Add invisible buttons to list which allow level selection:
	local chooseLevel = function( ignoreLevelVersionCheck )
		if userlevels[selectedUserlevel] then
			if userlevels[selectedUserlevel]:getIsDownloaded() then
				local version = Map:checkFileVersion( userlevels[selectedUserlevel].filename )
				version = version or "0"
				print( "Version check: " .. version .. " " .. MAPFILE_VERSION )
				if version == MAPFILE_VERSION or ignoreLevelVersionCheck then
					userlevels[selectedUserlevel]:play()
				else
					self:warnLevelVersion( userlevels[selectedUserlevel], version )
				end
			else
				userlevels[selectedUserlevel]:download()
			end
		end
	end
	local lineHover = function()
		--menu:updateTextForCurrentUserlevel()	--display name of currently selected level
		local cy = (20 - LIST_HEIGHT/2 + LIST_ENTRY_HEIGHT*(selectedUserlevel-firstDisplayedUserlevel-1))
		local cx = -LIST_WIDTH/2 + 12
		menu:setPlayerPosition( x + cx, y + cy )	-- player position must be in global coordinates
	end

	local buttonCenter = submenu:addButton( "", "", 0, 0, chooseLevel, lineHover )
	buttonCenter.invisible = true

	local moveUp = function()
		selectedUserlevel = math.max( 1, selectedUserlevel - 1 )

		if selectedUserlevel < firstDisplayedUserlevel then
			firstDisplayedUserlevel = selectedUserlevel
		end

		submenu:setSelectedButton( buttonCenter )
	end
	local moveDown = function()
		selectedUserlevel = math.min( #userlevels, selectedUserlevel + 1 )

		if selectedUserlevel - firstDisplayedUserlevel + 1 > displayedUserlevels then
			firstDisplayedUserlevel = selectedUserlevel - displayedUserlevels + 1
		end

		submenu:setSelectedButton( buttonCenter )
	end

	submenu:addButton( "", "", 0, -10, nil, moveUp )
	submenu:addButton( "", "", 0, 10, nil, moveDown )

	-- Add hotkeys:
	local back = function()
		--submenu:startExitTransition(
		--	function()
				menu:switchToSubmenu( "Main" )
		--	end )
	end
	submenu:addHotkey( "CHOOSE", "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		nil )
	submenu:addHotkey( "BACK", "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		back )
	--[[submenu:addHotkey( "FILTERS", "Show Filters",
		-love.graphics.getWidth()/Camera.scale/2 + 48,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		UserlevelSubmenu.showFilters )]]
	submenu:addHotkey( "REFRESH", "Refresh",
		-love.graphics.getWidth()/Camera.scale/2 + 48,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		UserlevelSubmenu.refresh )

	submenu:addHotkey( "SORTDIFFICULTY", "Sort by Difficulty",
		love.graphics.getWidth()/Camera.scale/2 - 50,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		UserlevelSubmenu.sortByDifficulty )
	submenu:addHotkey( "SORTFUN", "Sort by Fun",
		love.graphics.getWidth()/Camera.scale/2 - 80,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		UserlevelSubmenu.sortByFun )
	submenu:addHotkey( "SORTNAME", "Sort by Name",
		love.graphics.getWidth()/Camera.scale/2 - 107,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		UserlevelSubmenu.sortByName )

	--[[submenu:addHotkey( "FILTERS", "Hide Filters",
		-love.graphics.getWidth()/Camera.scale/2 + 48,
		love.graphics.getHeight()/Camera.scale/2 - 16,
			UserlevelSubmenu.hideFilters, "Filters" )	-- turn off on Filters layer
		submenu:addHiddenHotkey( keys.BACK, keys.PAD.BACK,
			UserlevelSubmenu.hideFilters, "Filters" )	-- turn off on Filters layer]]

		submenu:setActivateFunction(
			function()
				submenu:setSelectedButton( buttonCenter )
				self:refresh()
			end )

		local closeWarning = function()
			print("CLOSE WARNING")
			submenu:setLayerVisible( "Warning", false )	
		end
		local ignoreWarning = function()
			print("IGNORE WARNING")
			submenu:setLayerVisible( "Warning", false )	
			chooseLevel( true )	-- choose the current level, ignoring the version difference.
		end

		-- Warning when map version doesn't fit:
		submenu:addLayer("Warning")
		submenu:setLayerVisible( "Warning", false )
		submenu:addPanel( -72, -16, 144, 48, "Warning" )
		submenu:addHotkey( "BACK", "Cancel", 
			- 52, 16, 
			-- -love.graphics.getWidth()/Camera.scale/2 + 24,
			--love.graphics.getHeight()/Camera.scale/2 - 16,
			closeWarning, "Warning" )
		submenu:addHotkey( "CHOOSE", "Ignore and Play", 
			48, 16, 
			--love.graphics.getWidth()/Camera.scale/2 - 24,
			--love.graphics.getHeight()/Camera.scale/2 - 16,
			nil, "Warning" )

		-- add an invisible button for "accept":
		buttonWarning = submenu:addButton( "", "", 0, 0, ignoreWarning, nil, "Warning" )

		-- Arrows indicating whether the whole list is visible of not:
		arrowUpVis = Visualizer:New( "listArrowUp" );
		arrowUpVis:init()
		arrowDownVis = Visualizer:New( "listArrowDown" );
		arrowDownVis:init()
		sortingIndicator.vis = Visualizer:New( "listArrowUp" );
		sortingIndicator.vis:init()
		sortingIndicator.x = 0
		sortingIndicator.y = 0

		UserlevelSubmenu.sortByName()

		return submenu
	end

	-- Load a list of all levels which have already been downloaded previously and are available
	-- locally
	function UserlevelSubmenu:loadDownloadedUserlevels()
		local list = love.filesystem.getDirectoryItems( "userlevels/authorized/" )
		for i, author in pairs(list) do
			local levels = love.filesystem.getDirectoryItems( "userlevels/authorized/" .. author )
			for j, levelname in pairs(levels) do
				local newLevel = Userlevel:new( levelname:sub(1,#levelname-4), author, 0, 0, true )
				UserlevelSubmenu:insertUserlevelIntoList( newLevel )
			end
		end

		list = love.filesystem.getDirectoryItems( "userlevels/unauthorized/" )
		for i, author in pairs(list) do
			local levels = love.filesystem.getDirectoryItems( "userlevels/unauthorized/" .. author )
			for j, levelname in pairs(levels) do
				local newLevel = Userlevel:new( levelname:sub(1,#levelname-4), author, 0, 0, false )
				UserlevelSubmenu:insertUserlevelIntoList( newLevel )
			end
		end
		--UserlevelSubmenu:applyUserlevelFilters()
		UserlevelSubmenu:applySorting()
	end

	-- Called whenever a new level has been downloaded:
	function UserlevelSubmenu:userlevelsLoaded( data, authorizationLevel )
		for line in data:gmatch("([^\n]-)\n") do
			local author, levelname, ratingFun, ratingDifficulty = line:match("(.*)\t(.*)\t.*\t(.*)\t(.*)")
			if author and levelname and ratingFun and ratingDifficulty then
				local level = Userlevel:new( levelname, author, ratingFun, ratingDifficulty, authorizationLevel == "authorized" )
				UserlevelSubmenu:insertUserlevelIntoList( level )
			end
		end
		--menu:updateTextForCurrentUserlevel()	--display name of currently selected level
		--UserlevelSubmenu:applyUserlevelFilters()
		UserlevelSubmenu:applySorting()
	end

	--function UserlevelSubmenu:applyUserlevelFilters()
		--[[
		if userlevelFilterBox and userlevelFilterBox.visible then
			menu:hideUserlevelFilters()
		end

		userlevelsFiltered = {}

	-- Go through all levels and see if they fullfill the filter requirements:
	for k,level in pairs(userlevels) do
		local skip = false
		if userlevelFilters.authorizedOnly == true then
			if level.authorized ~= true then
				skip = true
			end
		end
		if userlevelFilters.downloadedOnly == true then
			if level:getIsDownloaded() ~= true then
				skip = true
			end
		end
		if userlevelFilters.searchText then
			local containsStr = string.lower( level.levelname ):find( userlevelFilters.searchText ) or 
								string.lower( level.author ):find( userlevelFilters.searchText )
			print(level.levelname, level.author, userlevelFilters.searchText, containsStr)
			if not containsStr then
				skip = true
				print("\tskipping")
			end
		end

		if not skip then
			table.insert( userlevelsFiltered, level )
		end
	end

	local sorting = sortingSchemes[userlevelFilters.sorting]
	if sorting == "Levelname ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByNameAscending )
	elseif sorting == "Levelname descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByNameDescending )
	elseif sorting == "Author ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByAuthorAscending )
	elseif sorting == "Author descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByAuthorDescending )
	elseif sorting == "Fun rating ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByFunAscending )
	elseif sorting == "Fun rating descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByFunDescending )
	elseif sorting == "Difficulty rating ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByDifficultyAscending )
	elseif sorting == "Difficulty rating descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByDifficultyDescending )
	end

	-- Adjust list view in case less levels are shown than before:
	menu.firstDisplayedUserlevel = 1
	menu.selectedUserlevel = 1
	userlevelFilters.searchText = nil	-- reset previous
	if buttonCenter then selectButton( buttonCenter ) end

	config.setValue( "LevelsFilterAuthorized", userlevelFilters.authorizedOnly )
	--config.setValue( "LevelsFilterDownloaded", userlevelFilters.downloadedOnly )
	config.setValue( "LevelsSorting", userlevelFilters.sorting )]]
	--end

function UserlevelSubmenu:applySorting()
	local x = -LIST_WIDTH/2 + 4
	local y = -LIST_HEIGHT/2
	local w = LIST_WIDTH - 4
	local h = LIST_HEIGHT

	local xStatus = (x + 12)*Camera.scale
	local xLevelname = (x + 22)*Camera.scale
	local xAuthor = (x + 0.3*w)*Camera.scale
	local xFun = (x + 0.85*w - 2*27)*Camera.scale
	local xDifficulty = (x + 0.85*w - 27)*Camera.scale
	local xAuthorized = (x + 0.85*w)*Camera.scale
	local xEnd = (x + w - 8)*Camera.scale
	sortingIndicator.y = (y + 3.75)*Camera.scale
	if currentSorting == "Levelname ascending" then
		table.sort( userlevels, Userlevel.sortByNameAscending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = 1
		sortingIndicator.x = xAuthor - 24
	elseif currentSorting == "Levelname descending" then
		table.sort( userlevels, Userlevel.sortByNameDescending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = -1
		sortingIndicator.x = xAuthor - 24
	elseif currentSorting == "Author ascending" then
		table.sort( userlevels, Userlevel.sortByAuthorAscending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = -1
		sortingIndicator.x = xFun - 24
	elseif currentSorting == "Author descending" then
		table.sort( userlevels, Userlevel.sortByAuthorDescending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = 1
		sortingIndicator.x = xFun - 24
	elseif currentSorting == "Fun rating ascending" then
		table.sort( userlevels, Userlevel.sortByFunAscending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = -1
		sortingIndicator.x = xDifficulty - 24
	elseif currentSorting == "Fun rating descending" then
		table.sort( userlevels, Userlevel.sortByFunDescending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = 1
		sortingIndicator.x = xDifficulty - 24
	elseif currentSorting == "Difficulty rating ascending" then
		table.sort( userlevels, Userlevel.sortByDifficultyAscending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = -1
		sortingIndicator.x = xAuthorized - 24
	elseif currentSorting == "Difficulty rating descending" then
		table.sort( userlevels, Userlevel.sortByDifficultyDescending )
		sortingIndicator.vis:setAni("sortingArrow")
		sortingIndicator.vis.sy = 1
		sortingIndicator.x = xAuthorized - 24
	end
	if sortingIndicator.vis then
		sortingIndicator.vis:resetVector()
	end
end

function UserlevelSubmenu.sortByName()
	if currentSorting == "Levelname ascending" then
		currentSorting = "Levelname descending"
	else
		currentSorting = "Levelname ascending"
	end
	UserlevelSubmenu:applySorting()
end

function UserlevelSubmenu.sortByFun()
	if currentSorting == "Fun rating descending" then
		currentSorting = "Fun rating ascending"
	else
		currentSorting = "Fun rating descending"
	end
	UserlevelSubmenu:applySorting()
end

function UserlevelSubmenu.sortByDifficulty()
	if currentSorting == "Difficulty rating descending" then
		currentSorting = "Difficulty rating ascending"
	else
		currentSorting = "Difficulty rating descending"
	end
	UserlevelSubmenu:applySorting()
end

function UserlevelSubmenu:insertUserlevelIntoList( level )
	-- Use this function to insert all levels found locally AND online into the list of user levels.
	-- If a level exists twice (once online and once already downloaded) this function sets the
	-- rating info of the local level to the rating info received from the server.
	if userlevelsByAuthor[level.author] and userlevelsByAuthor[level.author][level.levelname] then
		print( "Level " .. level.levelname .. " by " .. level.author .. " already exists locally. Updating data..." )
		local oldLevel = userlevelsByAuthor[level.author][level.levelname]
		if not oldLevel.authorized and level.authorized then
			local oldfilename = "userlevels/unauthorized/" .. level.author .. "/" .. level.levelname .. ".dat"
			local newfilename = "userlevels/authorized/" .. level.author .. "/" .. level.levelname .. ".dat"
			if love.filesystem.exists( oldfilename ) then
				local content = love.filesystem.read( oldfilename )
				love.filesystem.write( newfilename, content )
				love.filesystem.remove( oldfilename )
			end
			love.filename = newfilename
		end

		for k, l in pairs( userlevels ) do
			if l == oldLevel then
				table.remove( userlevels, k )
				break
			end
		end
	end

	table.insert( userlevels, level )

	-- Remember level in list sorted by author/levelname as well:
	if not userlevelsByAuthor[level.author] then
		userlevelsByAuthor[level.author] = {}
	end
	userlevelsByAuthor[level.author][level.levelname] = level

	--userlevelsFiltered = userlevels 
end

function UserlevelSubmenu:drawUserlevels()

	local x = -LIST_WIDTH/2 + 4
	local y = -LIST_HEIGHT/2
	local w = LIST_WIDTH - 4
	local h = LIST_HEIGHT

	local xStatus = (x + 12)*Camera.scale
	local xLevelname = (x + 22)*Camera.scale
	local xAuthor = (x + 0.3*w)*Camera.scale
	local xFun = (x + 0.85*w - 2*27)*Camera.scale
	local xDifficulty = (x + 0.85*w - 27)*Camera.scale
	local xAuthorized = (x + 0.85*w)*Camera.scale
	local xEnd = (x + w - 8)*Camera.scale

	-- draw headers:
	love.graphics.setColor( 0.12,0,0,0.3 )
	love.graphics.rectangle( "fill", xLevelname, y*Camera.scale, xAuthor - xLevelname - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)
	love.graphics.rectangle( "fill", xAuthor, y*Camera.scale, xFun - xAuthor - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)
	love.graphics.rectangle( "fill", xFun, y*Camera.scale, xDifficulty - xFun - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)
	love.graphics.rectangle( "fill", xDifficulty, y*Camera.scale, xAuthorized - xDifficulty - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)
	love.graphics.rectangle( "fill", xAuthorized, y*Camera.scale, xEnd - xAuthorized - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)

	love.graphics.setColor( 1,1,1,1 )
	love.graphics.print( "Level", math.floor(xLevelname + 2*Camera.scale), math.floor((y + 2)*Camera.scale) )
	love.graphics.print( "Author", math.floor(xAuthor + 2*Camera.scale), math.floor((y + 2)*Camera.scale) )
	love.graphics.print( "Fun", math.floor(xFun + 2*Camera.scale), math.floor((y + 2)*Camera.scale) )
	love.graphics.print( "Difficulty", math.floor(xDifficulty + 2*Camera.scale), math.floor((y + 2)*Camera.scale) )
	love.graphics.print( "Authorized", math.floor(xAuthorized + 2*Camera.scale), math.floor((y + 2)*Camera.scale) )

	sortingIndicator.vis:draw( sortingIndicator.x, sortingIndicator.y )
	
	--for i, level in ipairs( userlevels ) do
	local lastDisplayedLevel = math.min( displayedUserlevels + firstDisplayedUserlevel - 1, #userlevels )

	--print(#userlevels, lastDisplayedLevel, displayedUserlevels, firstDisplayedUserlevel )
	for i = firstDisplayedUserlevel, lastDisplayedLevel do
		local level = userlevels[i]

		local curY = (2 + y + LIST_ENTRY_HEIGHT*(i-firstDisplayedUserlevel+1))*Camera.scale

		-- draw indicator showing if level is ready to play or needs to be downloaded first:
		level.statusVis:draw( xStatus + 4*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
		love.graphics.print( i .. ": " .. level.levelname, math.floor(xLevelname), math.floor(curY) )
		love.graphics.print( level.author, math.floor(xAuthor), math.floor(curY) )
		level.ratingFunVis:draw( xFun + 12*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
		level.ratingDifficultyVis:draw( xDifficulty + 12*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
		level.authorizationVis:draw( xAuthorized + 8*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
	end

	-- If not all functions fit onto the currently displayed list, indicate this using arrows:
	if firstDisplayedUserlevel > 1 then
		local posY = (y + LIST_ENTRY_HEIGHT)*Camera.scale
		arrowUpVis:draw( xStatus - 24, posY )
	end
	if lastDisplayedLevel < #userlevels then
		local posY = (8 + y + LIST_ENTRY_HEIGHT*displayedUserlevels)*Camera.scale
		arrowDownVis:draw( xStatus - 24, posY )
	end

	--[[if userlevelFilterBox.visible then
		userlevelFilterBox.box:draw( userlevelFilterBox.x, userlevelFilterBox.y )
	end]]
end

function UserlevelSubmenu:showFilters()
	submenu:setLayerVisible( "Filters", true )
end
function UserlevelSubmenu:hideFilters()
	submenu:setLayerVisible( "Filters", false )
end

function UserlevelSubmenu:getSelectedLevelData()
	if userlevels[selectedUserlevel] then
		return userlevels[selectedUserlevel].levelname, userlevels[selectedUserlevel].author
	end
end

function UserlevelSubmenu:refresh()
	-- Start downloading level list:
	threadInterface.new( "listlevels", "scripts/levelsharing/list.lua", "getLevelNames",
			function(data) UserlevelSubmenu:userlevelsLoaded(data, "unauthorized") end,
			nil, "unauthorized" )
	threadInterface.new( "listlevels", "scripts/levelsharing/list.lua", "getLevelNames",
			function(data) UserlevelSubmenu:userlevelsLoaded(data, "authorized") end,
			nil, "authorized" )
end

function UserlevelSubmenu:update( dt )
	arrowUpVis:update(dt)
	arrowDownVis:update(dt)
	sortingIndicator.vis:update(dt)
end

function UserlevelSubmenu:warnLevelVersion( level, version )
	submenu:clearLayer( "Warning" )
	submenu:addText( "Warning: This level was made with a different version of the game.\n"
		.. "Your editor file version: " .. MAPFILE_VERSION .. "\n"
		.. "Level file version: " .. version .. "\n"
		.. "\nContinue anyway?",
		-60, -6, 120,
		"Warning" )
	submenu:setLayerVisible( "Warning", true )
	submenu:setSelectedButton( buttonWarning, "Warning" )
end

return UserlevelSubmenu
