local keys = {}
keys.currentlyAssigning = false		--holds the string of the key which is currently being changed.


---------------------------------------------------------
-- Defaults
---------------------------------------------------------
function keys.setDefaults()
	keys.SCREENSHOT = 't'
	keys.FULLSCREEN = 'f'
	keys.RESTARTMAP = 'p'
	keys.RESTARTGAME = 'o'
	keys.NEXTMAP = 'q'

	keys.LEFT = 'left'
	keys.RIGHT = 'right'
	keys.UP = 'up'
	keys.DOWN = 'down'

	keys.JUMP = 'a'
	keys.ACTION = 's'
end
keys.setDefaults()


---------------------------------------------------------
-- Load settings:
---------------------------------------------------------

function keys.load()
	local key
	key = config.getValue( "SCREENSHOT", "keyboard.txt")
	if key then keys.SCREENSHOT = key end
	key = config.getValue( "FULLSCREEN", "keyboard.txt")
	if key then keys.FULLSCREEN = key end
	key = config.getValue( "RESTARTMAP", "keyboard.txt")
	if key then keys.RESTARTMAP = key end
	key = config.getValue( "RESTARTGAME", "keyboard.txt")
	if key then keys.RESTARTGAME = key end
	key = config.getValue( "NEXTMAP", "keyboard.txt")
	if key then keys.NEXTMAP = key end
	
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
	key = config.getValue( "ACTION", "keyboard.txt")
	if key then keys.ACTION = key end
end


function keys.startAssign( keyToAssign )
	return function()
		keys.currentlyAssigning = keyToAssign
		menu:changeText( keyToAssign, "")
	end
end

function keys.assign( key )
	if keys.currentlyAssigning then
		if key ~= 'esc' and key ~= 'return' then
			if keys[keys.currentlyAssigning] ~= key then
				keys.changed = true
			end
			keys[keys.currentlyAssigning] = key
			menu:changeText( keys.currentlyAssigning, key)
		end
		menu:changeText( keys.currentlyAssigning, keys[keys.currentlyAssigning])
		keys.currentlyAssigning = false
	end
end

---------------------------------------------------------
-- Display key setting menus:
---------------------------------------------------------

function keys.initKeyboard()
	menu.state = "keyboard"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	
	local x,y = -25, -35
	
	local startButton = menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "left", keys.startAssign( "LEFT" ), nil )
	menu:addText( x+11, y+3, "LEFT", keys.LEFT)
	
	y = y + 7
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "right", keys.startAssign( "RIGHT" ), nil )
	menu:addText( x+11, y+3, "RIGHT", keys.RIGHT)
	y = y + 7
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "up", keys.startAssign( "UP" ), nil )
	menu:addText( x+11, y+3, "UP", keys.UP)
	y = y + 7
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "down", keys.startAssign( "DOWN" ), nil )
	menu:addText( x+11, y+3, "DOWN", keys.DOWN)
	
	y = y + 14
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "jump", keys.startAssign( "JUMP" ), nil )
	menu:addText( x+11, y+3, "JUMP", keys.JUMP)
	y = y + 7
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "use bandana", keys.startAssign( "ACTION" ), nil )
	menu:addText( x+11, y+3, "ACTION", keys.ACTION)
	
	y = y + 14
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "screenshot", keys.startAssign( "SCREENSHOT" ), nil )
	menu:addText( x+11, y+3, "SCREENSHOT", keys.SCREENSHOT)
	y = y + 7
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "fullscreen", keys.startAssign( "FULLSCREEN" ), nil )
	menu:addText( x+11, y+3, "FULLSCREEN", keys.FULLSCREEN)
	y = y + 7
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "restart map", keys.startAssign( "RESTARTMAP" ), nil )
	menu:addText( x+11, y+3, "RESTARTMAP", keys.RESTARTMAP)
	
	
	-- start of with the first button selected:
	selectButton(startButton)
end


function keys.initGamepad()
	menu.state = "gamepad"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	-- TODO: Add gamepad buttons here...
	
end

function keys:exitSubMenu()
	if not keys.currentlyAssigning then
		if keys.changed then
			if menu.state == "keyboard" then	-- save keyboard layout:
				config.setValue( "SCREENSHOT", keys.SCREENSHOT, "keyboard.txt")
				config.setValue( "FULLSCREEN", keys.FULLSCREEN, "keyboard.txt")
				config.setValue( "RESTARTMAP", keys.SCREENSHOT, "keyboard.txt")
				config.setValue( "RESTARTGAME", keys.RESTARTGAME, "keyboard.txt")
				config.setValue( "NEXTMAP", keys.NEXTMAP, "keyboard.txt")
			
				config.setValue( "LEFT", keys.LEFT, "keyboard.txt")
				config.setValue( "RIGHT", keys.RIGHT, "keyboard.txt")
				config.setValue( "UP", keys.UP, "keyboard.txt")
				config.setValue( "DOWN", keys.DOWN, "keyboard.txt")
			
				config.setValue( "JUMP", keys.JUMP, "keyboard.txt")
				config.setValue( "ACTION", keys.ACTION, "keyboard.txt")
			end
		end
		settings.init()
	end
end

return keys