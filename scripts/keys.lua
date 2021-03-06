
controlKeys = require("scripts/controlKeys")

local keys = {}
keys.gamepadPressed = {}
keys.pressedLastFrame = {}
keys.currentlyAssigning = false		--holds the string of the key which is currently being changed.

keyTypes = {
	"LEFT", "RIGHT", "UP", "DOWN",
	"JUMP", "ROPE", "DASH",
	"CHOOSE", "BACK",
	"SCREENSHOT",
	"RESTARTMAP",
	"REFRESH",
	"SORTNAME",
	"SORTFUN",
	"SORTDIFFICULTY",
	"DELETE_LEVEL",
	"RESET",
	"CLEAR",
}

keys.displayNames = {
	LEFT = "Left", RIGHT = "Right", UP = "Up", DOWN = "Down",
	JUMP = "Jump", ROPE ="Grappling Hook", DASH = "Dash",
	CHOOSE = "Enter", BACK = "Back",
	SCREENSHOT = "Screenshot",
	RESTARTMAP = "Restart Level",
	REFRESH = "Refresh List", SORTNAME = "Sort by Name", SORTFUN = "Sort by Fun", SORTDIFFICULTY = "Sort by Difficulty", DELETE_LEVEL = "Delete Level",
	RESET = "Reset Keybindings", CLEAR = "Clear Keybinding"
	}

-- For each key, list the keys which it may NOT be the same as.
keys.conflictList = {
	-- In game:
	{"SCEENSHOT", "RESTARTMAP", "LEFT", "RIGHT", "UP", "DOWN", "JUMP", "ROPE", "DASH"},
	-- menu:
	{"SCEENSHOT", "LEFT", "RIGHT", "UP", "DOWN", "CHOOSE", "BACK",},
	-- userlevel menu:
	{"SCREENSHOT", "CHOOSE", "BACK", "REFRESH", "DELETE_LEVEL", "SORTNAME", "SORTFUN", "SORTDIFFICULTY",},
	-- key assignment menu:
	{"SCREENSHOT", "LEFT", "RIGHT", "UP", "DOWN", "RESET", "CHOOSE", "BACK", "CLEAR"}
}

-- These keys NEED to be set in order for key assignment to succeed:
keys.mandatoryKeys = {
	"LEFT", "RIGHT", "UP", "DOWN", "JUMP", "ROPE", "DASH", "CHOOSE", "BACK", "REFRESH", "RESET", "BACK",
}

---------------------------------------------------------
-- Defaults
---------------------------------------------------------
function keys.setDefaults()
	-- keyboard defaults:
	keys.SCREENSHOT = 'f2'
	keys.RESTARTMAP = 'r'

	keys.LEFT = 'left'
	keys.RIGHT = 'right'
	keys.UP = 'up'
	keys.DOWN = 'down'

	keys.JUMP = 'a'
	keys.ROPE = 's'
	keys.DASH = 'd'

	keys.CHOOSE = 'return'
	keys.BACK = 'escape'

	keys.REFRESH = "f5"
	keys.SORTNAME = '1'
	keys.SORTFUN = '2'
	keys.SORTDIFFICULTY = '3'
	keys.DELETE_LEVEL = 'x'
	keys.RESET = "r"
	keys.CLEAR = "c"
	
	-- gamepad defaults:
	keys.PAD = {}
	keys.PAD.SCREENSHOT = '6'
	keys.PAD.RESTARTMAP = 'none'

	keys.PAD.LEFT = 'l'
	keys.PAD.RIGHT = 'r'
	keys.PAD.UP = 'u'
	keys.PAD.DOWN = 'd'

	keys.PAD.JUMP = '1'
	keys.PAD.ROPE = '2'
	keys.PAD.DASH = '4'

	keys.PAD.CHOOSE = '1'
	keys.PAD.BACK = '2'

	keys.PAD.REFRESH = 'none'
	keys.PAD.SORTNAME = 'none'
	keys.PAD.SORTFUN = 'none'
	keys.PAD.SORTDIFFICULTY = 'none'

	keys.PAD.RESET = 'none'
	keys.PAD.CLEAR = 'none'

	-- Reset all keys:
	if keys.gamepadPressed then
		for id, joystick in pairs( keys.gamepadPressed ) do
			for b, val in pairs( keys.gamepadPressed[id] ) do
				keys.gamepadPressed[id][b] = nil
				keys.pressedLastFrame[id][b] = nil
			end
		end
	end

end

keys.setDefaults()


---------------------------------------------------------
-- Load settings:
---------------------------------------------------------

function keys.load()
	local key
	
	-- Load keyboard setup:
	key = config.getValue( "SCREENSHOT", "keyboard.txt")
	if key then keys.SCREENSHOT = key end
	key = config.getValue( "RESTARTMAP", "keyboard.txt")
	if key then keys.RESTARTMAP = key end
	
	key = config.getValue( "LEFT", "keyboard.txt")
	if key then keys.LEFT = key end
	key = config.getValue( "RIGHT", "keyboard.txt")
	if key then keys.RIGHT = key end
	key = config.getValue( "UP", "keyboard.txt")
	if key then keys.UP = key end
	key = config.getValue( "DOWN", "keyboard.txt")
	if key then keys.DOWN = key end
	
	key = config.getValue( "JUMP", "keyboard.txt")
	if key then keys.JUMP = key end
	key = config.getValue( "ROPE", "keyboard.txt")
	if key then keys.ROPE = key end
	key = config.getValue( "DASH", "keyboard.txt")
	if key then keys.DASH = key end

	key = config.getValue( "BACK", "keyboard.txt")
	if key then keys.BACK = key end
	key = config.getValue( "CHOOSE", "keyboard.txt")
	if key then keys.CHOOSE = key end

	key = config.getValue( "REFRESH", "keyboard.txt")
	if key then keys.REFRESH = key end
	key = config.getValue( "SORTNAME", "keyboard.txt")
	if key then keys.SORTNAME = key end
	key = config.getValue( "SORTFUN", "keyboard.txt")
	if key then keys.SORTFUN = key end
	key = config.getValue( "SORTDIFFICULTY", "keyboard.txt")
	if key then keys.SORTDIFFICULTY = key end

	
	-- Load gamepad setup:
	key = config.getValue( "SCREENSHOT", "gamepad.txt")
	if key then keys.PAD.SCREENSHOT = key end
	key = config.getValue( "RESTARTMAP", "gamepad.txt")
	if key then keys.PAD.RESTARTMAP = key end
	
	key = config.getValue( "LEFT", "gamepad.txt")
	if key then keys.PAD.LEFT = key end
	key = config.getValue( "RIGHT", "gamepad.txt")
	if key then keys.PAD.RIGHT = key end
	key = config.getValue( "UP", "gamepad.txt")
	if key then keys.PAD.UP = key end
	key = config.getValue( "DOWN", "gamepad.txt")
	if key then keys.PAD.DOWN = key end
	
	key = config.getValue( "JUMP", "gamepad.txt")
	if key then keys.PAD.JUMP = key end
	key = config.getValue( "ROPE", "gamepad.txt")
	if key then keys.PAD.ROPE = key end
	key = config.getValue( "DASH", "gamepad.txt")
	if key then keys.PAD.DASH = key end

	key = config.getValue( "BACK", "gamepad.txt")
	if key then keys.PAD.BACK = key end
	key = config.getValue( "CHOOSE", "gamepad.txt")
	if key then keys.PAD.CHOOSE = key end

	key = config.getValue( "SORTNAME", "gamepad.txt")
	if key then keys.PAD.SORTNAME = key end
	key = config.getValue( "SORTFUN", "gamepad.txt")
	if key then keys.PAD.SORTFUN = key end
	key = config.getValue( "SORTDIFFICULTY", "gamepad.txt")
	if key then keys.PAD.SORTDIFFICULTY = key end
end

function keys.loadGamepad()
	print("Gamepads:")
	if love.joystick.getJoystickCount() == 0 then
		print("\tNone found.")
	else
		for k, pad in ipairs( love.joystick.getJoysticks() ) do
			print("\t",pad:getID(), pad:getName() )

			-- Important! initialize these tables, since they're
			-- usually initialized when joysticks are connected,
			-- but the first joystick is recognized only AFTER
			-- these are first neede!
			keys.gamepadPressed[pad:getID()] = {}
			keys.pressedLastFrame[pad:getID()] = {}
		end
	end
end

function nameForKey( key )
	if key == " " then
		return "space"
	elseif key == "up" then
		return "]"
	elseif key == "down" then
		return "["
	elseif key == "left" then
		return "{"
	elseif key == "right" then
		return "}"
	elseif key == "backspace" then
		return "bspace"
	elseif key == "return" then
		return "£"
	elseif key == "escape" then
		return "^"
	elseif key == "none" then
		return ""
	else
		return key
	end
end

function getImageForKey( str, font )
	if str == "" or str == "none" then
		return "keyNone", "keyNone"
	end

	if str == " " then str = "space" end
	if str == "up" then str = "A" end
	if str == "down" then str = "B" end
	if str == "left" then str = "C" end
	if str == "right" then str = "D" end
	if str == "escape" then str = "^" end
	if str == "return" then str = "A" end
	if #str > 1 then --font:getWidth(str) > menu.images.keyOn:getWidth()/2 then
		return "keyLargeOff", "keyLargeOn"
	end
	return "keyOff", "keyOn"
end

function getAnimationForKey( str )
	str = nameForKey( str )
	if str == "" or str == "none" then
		return "keyNone"
	end
	if #str > 2 then --font:getWidth(str) > menu.images.keyOn:getWidth()/2 then
		return "keyboardLarge"
	end
	return "keyboardSmall"
end

function getImageForPad( str )
	if str == "1" then
		return "gamepadA","gamepadA"
	elseif str == "2" then
		return "gamepadB","gamepadB"
	elseif str == "3" then
		return "gamepadX","gamepadX"
	elseif str == "4" then
		return "gamepadY","gamepadY"
	elseif str == "5" then
		return "gamepadLB","gamepadLB"
	elseif str == "6" then
		return "gamepadRB","gamepadRB"
	elseif str == "u" then
		return "gamepadUp","gamepadUp"
	elseif str == "d" then
		return "gamepadDown","gamepadDown"
	elseif str == "l" then
		return "gamepadLeft","gamepadLeft"
	elseif str == "r" then
		return "gamepadRight","gamepadRight"
	elseif str == "8" then
		return "gamepadStart","gamepadStart"
	elseif str == "7" then
		return "gamepadBack","gamepadBack"
	else
		return "keyNone","keyNone"
	end
end

function getAnimationForPad( str )
	if str == "1" then
		return "gamepadA"
	elseif str == "2" then
		return "gamepadB"
	elseif str == "3" then
		return "gamepadX"
	elseif str == "4" then
		return "gamepadY"
	elseif str == "5" then
		return "gamepadLB"
	elseif str == "6" then
		return "gamepadRB"
	elseif str == "u" then
		return "gamepadUp"
	elseif str == "d" then
		return "gamepadDown"
	elseif str == "l" then
		return "gamepadLeft"
	elseif str == "r" then
		return "gamepadRight"
	elseif str == "8" then
		return "gamepadStart"
	elseif str == "9" then
		return "gamepadBack"
	else
		return "keyNone"
	end
end

---------------------------------------------------------
-- Handle the joysticks in-game:
---------------------------------------------------------

--[[
keys.lastFrameJoyHat = nil
keys.lastFrameKey1 = nil
keys.lastFrameKey2 = nil

function keys.catchGamepadEvents()
	for k, v in pairs( keys.PAD ) do
		keys.gamepadPressed[k] = nil	-- reset all
	end
	
	local joyHat = love.joystick.getHat( 1,1 )
	
	if joyHat == "lu" or joyHat == "ld" then
		joyHat = "l"
	elseif joyHat == "ru" or joyHat == "rd" then
		joyHat = "r"
	end

	if mode == "menu" or mode == "levelEnd" then
		if not keys.currentlyAssigning then
			if love.joystick.isDown( 1, 1 ) then
				if not keys.lastFrameKey1 then
					if mode == "menu" then
						menu:keypressed( "return" )
					else
						levelEnd:keypressed( "return" )
					end
					keys.lastFrameKey1 = true
				end
			else
				keys.lastFrameKey1 = false
			end
			if love.joystick.isDown( 1, 2 ) then
				if not keys.lastFrameKey2 then
					if mode == "menu" then
						menu:keypressed( "escape" )
					else
						levelEnd:keypressed( "escape" )
					end
					keys.lastFrameKey2 = true
				end
			else
				keys.lastFrameKey2 = false
			end
		else
			keys.lastFrameKey1 = true
			keys.lastFrameKey2 = true
		end
	
		if joyHat ~= 'c' then
			if keys.currentlyAssigning and menu.state == 'gamepad' then
				keys.assign( joyHat )
			else
				if mode == "menu" and keys.lastFrameJoyHat ~= joyHat then
					menu:keypressed( joyHat )
				end
			end
		end
		
	end
	
	if mode == 'game' then
		for k, v in pairs( keys.PAD ) do
			if v == joyHat then
				if not keys.gamepadPressed[k] then
					keys.gamepadPressed[k] = true
					game.joystickpressed(1, v)
				end
			end
			if tonumber(v) then	-- if the button is a number button, check if that one's pressed
				if love.joystick.isDown( 1, tonumber(v) ) then
					keys.gamepadPressed[k] = true
				end
			end
		end
	end
	
	keys.lastFrameJoyHat = joyHat
end]]--

-- calls events in case a gamepad button has been pressed this frame:
-- Must be called every frame!
function keys.handleGamepad( ID )
	ID = ID or 1 -- default to joystick 1
	if not keys.gamepadPressed[ID] then return end
	-- check for released events:
	for k, v in pairs( keys.pressedLastFrame[ID] ) do
		if not keys.gamepadPressed[ID][k] then
			keys.pressedLastFrame[ID][k] = nil
			if mode == "game" then
				game.joystickreleased( ID, k )
			elseif mode == "menu" then
			end
		end
	end

	-- check for newly pressed buttons:
	for k, v in pairs( keys.gamepadPressed[ ID ]) do
		if not keys.pressedLastFrame[ID][k] then
			if keys.currentlyAssigning then
				if menu.state == 'gamepad' then
					keys.assign( k )
				else
					keys.abortAssigning()
				end
			else

				if mode == "game" then
					game.joystickpressed( ID, k )
				elseif mode == "menu" then
					--menu:keypressed( k )
				elseif mode == "levelEnd" then
					levelEnd:keypressed( k )
				end
			end
		end
		keys.pressedLastFrame[ID][k] = true
	end
end

function keys.pressGamepadKey( joystick, button )
	button = tostring(button)
	keys.gamepadPressed[joystick:getID()][button] = true
end

function keys.releaseGamepadKey( joystick, button )
	button = tostring(button)
	keys.gamepadPressed[joystick:getID()][button] = nil
end

function keys.getGamepadIsDown( ID, str )
	ID = ID or 1
	return keys.gamepadPressed[ID] and keys.gamepadPressed[ID][str] or false
end

-- called when new joystick has been connected:
function keys.joystickadded( j )
	-- if this is the first joystick, switch menu keys to
	-- be displayed in joystick-mode
	keys.gamepadPressed[j:getID()] = {}
	keys.pressedLastFrame[j:getID()] = {}
	if love.joystick.getJoystickCount() == 1 then
		controlKeys:setup()
	end
end

-- called when new joystick has been disconnected:
function keys.joystickremoved( j )
	-- if, with the removal of this joystick, the last one
	-- has been removed, switch to keyboard:
	if love.joystick.getJoystickCount() == 0 then
		controlKeys:setup()
	end

	keys.gamepadPressed[j:getID()] = nil
	keys.pressedLastFrame[j:getID()] = nil
end

---------------------------------------------------------
-- Display key setting menus:
---------------------------------------------------------

function keys.moveMenuPlayer( x, y, newAnimation )
	return function()
		menuPlayer.x = x
		menuPlayer.y = y
		menuPlayer.vis:setAni( newAnimation )
		local sel = menu:getSelected()
		if sel and (sel.name == "key_LEFT" or sel.name == "key_PAD_LEFT") then
			menuPlayer.vis.sx = -1
		else
			menuPlayer.vis.sx = 1
		end
	end
end

-- check for double assignments or empty keys.
function keys:checkInvalid()
	if menu.state == "keyboard" then
		for k = 1, #keyTypes-1 do
			for k2 = k+1, #keyTypes do
				if keyTypes[k] ~= "CHOOSE" and keyTypes[k2] ~= "CHOOSE" and keyTypes[k] ~= "BACK" and keyTypes[k2] ~= "BACK" then
				if keys[keyTypes[k]] == keys[keyTypes[k2]] then
					menu.text = string.lower("Keys for " .. keyTypes[k] .. " and " .. keyTypes[k2] .. " are the same. Please change one of them.")
					return true
				end
			end
			end
		end
	else
		for k = 1, #keyTypes-1 do
			for k2 = k+1, #keyTypes do
				-- handle "choose" and "back" seperately:
				if keyTypes[k] ~= "CHOOSE" and keyTypes[k2] ~= "CHOOSE" and keyTypes[k] ~= "BACK" and keyTypes[k2] ~= "BACK" then
					if keys.PAD[keyTypes[k]] == keys.PAD[keyTypes[k2]] then
						menu.text = string.lower("Keys for " .. keyTypes[k] .. " and " .. keyTypes[k2] .. " are the same. Please change one of them.")
						return true
					end
				end
			end
		end
		if keys.PAD.CHOOSE == keys.PAD.BACK then
			menu.text = string.lower("Keys for CHOOOSE and BACK are the same. Please change one of them.")
			return true
		end
	end
	return false
end

function keys:save()

	if keys.changed then
		config.setValue( "SCREENSHOT", keys.SCREENSHOT, "keyboard.txt")
		config.setValue( "RESTARTMAP", keys.RESTARTMAP, "keyboard.txt")

		config.setValue( "LEFT", keys.LEFT, "keyboard.txt")
		config.setValue( "RIGHT", keys.RIGHT, "keyboard.txt")
		config.setValue( "UP", keys.UP, "keyboard.txt")
		config.setValue( "DOWN", keys.DOWN, "keyboard.txt")
	
		config.setValue( "JUMP", keys.JUMP, "keyboard.txt")
		config.setValue( "ROPE", keys.ROPE, "keyboard.txt")
		config.setValue( "DASH", keys.DASH, "keyboard.txt")

		config.setValue( "CHOOSE", keys.CHOOSE, "keyboard.txt")
		config.setValue( "BACK", keys.BACK, "keyboard.txt")

		config.setValue( "REFRESH", keys.REFRESH, "keyboard.txt")
		config.setValue( "SORTNAME", keys.SORTNAME, "keyboard.txt")
		config.setValue( "SORTFUN", keys.SORTFUN, "keyboard.txt")
		config.setValue( "SORTDIFFICULTY", keys.SORTDIFFICULTY, "keyboard.txt")
			
		config.setValue( "SCREENSHOT", keys.PAD.SCREENSHOT, "gamepad.txt")
		config.setValue( "RESTARTMAP", keys.PAD.RESTARTMAP, "gamepad.txt")
	
		config.setValue( "LEFT", keys.PAD.LEFT, "gamepad.txt")
		config.setValue( "RIGHT", keys.PAD.RIGHT, "gamepad.txt")
		config.setValue( "UP", keys.PAD.UP, "gamepad.txt")
		config.setValue( "DOWN", keys.PAD.DOWN, "gamepad.txt")
	
		config.setValue( "JUMP", keys.PAD.JUMP, "gamepad.txt")
		config.setValue( "ROPE", keys.PAD.ROPE, "gamepad.txt")
		config.setValue( "DASH", keys.PAD.DASH, "gamepad.txt")

		config.setValue( "CHOOSE", keys.PAD.CHOOSE, "gamepad.txt")
		config.setValue( "BACK", keys.PAD.BACK, "gamepad.txt")

		config.setValue( "REFRESH", keys.PAD.REFRESH, "gamepad.txt")
		config.setValue( "SORTNAME", keys.PAD.SORTNAME, "gamepad.txt")
		config.setValue( "SORTFUN", keys.PAD.SORTFUN, "gamepad.txt")
		config.setValue( "SORTDIFFICULTY", keys.PAD.SORTDIFFICULTY, "gamepad.txt")

		keys.changed = false
	end
end

function keys.startAssign( keyToAssign )
	return function()
		if menu.state == "keyboard" then
			keys.currentlyAssigning = keyToAssign
			--menu:changeText( keyToAssign, "")
			local imgOff, imgOn = getImageForKey( "", 'fontSmall' )
			menu:changeButtonImage( "key_" .. keyToAssign, imgOff, imgOn )
			menu:changeButtonLabel( "key_" .. keyToAssign, "" )
		elseif menu.state == "gamepad" then
			keys.currentlyAssigning = keyToAssign
			local imgOff, imgOn = getImageForPad( "" )
			menu:changeButtonImage( "key_PAD_" .. keyToAssign, imgOff, imgOn )
		end
	end
end

function keys.assign( key )
	if keys.currentlyAssigning then
		if menu.state == "keyboard" then
				if keys[keys.currentlyAssigning] ~= key then
					keys.changed = true
				end
				keys[keys.currentlyAssigning] = key

				--menu:changeText( keys.currentlyAssigning, key)
			local imgOff,imgOn = getImageForKey( keys[keys.currentlyAssigning] )
			menu:changeButtonImage( "key_" .. keys.currentlyAssigning, imgOff, imgOn )
			menu:changeButtonLabel( "key_" .. keys.currentlyAssigning,
						nameForKey(keys[keys.currentlyAssigning]))
			if keys.currentlyAssigning == "BACK" or keys.currentlyAssigning == "CHOOSE" then
				controlKeys:setup()
			end

			keys.currentlyAssigning = false

		elseif menu.state == "gamepad" then
			if keys.PAD[keys.currentlyAssigning] ~= key then
				keys.changed = true
			end
			keys.PAD[keys.currentlyAssigning] = key

			local imgOff,imgOn = getImageForPad( keys.PAD[keys.currentlyAssigning] )
			menu:changeButtonImage( "key_PAD_" .. keys.currentlyAssigning, imgOff, imgOn )

			if keys.currentlyAssigning == "BACK" or keys.currentlyAssigning == "CHOOSE" then
				controlKeys:setup()
			end
			keys.currentlyAssigning = false
		end
	end
end

function keys.abortAssigning()
	keys.changed = true

	imgOff,imgOn = getImageForPad( keys.PAD[keys.currentlyAssigning] )
	menu:changeButtonImage( "key_PAD_" .. keys.currentlyAssigning, imgOff, imgOn )
	keys.currentlyAssigning = false
end

function keys.setChanged()
	keys.changed = true
end

return keys
