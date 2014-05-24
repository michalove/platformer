-- Script used to upload a file to the server.
-- The file is defined by passing a filename to this script.
-- The script will load the file and upload it to the server.
-- The upload will block, so this script is designed to be run in a background thread.
-- The script will use the POST http method.

local http = require("socket.http")	-- for communication
local ltn12 = require("ltn12")	-- for sinks into which the result will be stored

local levelVerification = require("scripts/levelsharing/levelVerification")

local upload = {}

function upload.sendFile( url, filename, levelname, creator )
	local success, err = levelVerification.checkFile( filename )
	if not success then
		print("Could not upload File: " .. err )
	end

	local f = assert(io.open(filename, "r"))
	local data = f:read("*all")

	levelname = levelname or "testlevel"
	creator = creator or "anonymous"

	--data = "Name: " .. levelname .. "\nCreator: " .. creator .. "\n" .. data
	data = "Name: " .. levelname .. "\nCreator: " .. creator .. "\n" .. data

	--data = "test"
	--data = "anid=&protocol=1&"

    local response = {} -- for the response body

    local result, respcode, respheaders, respstatus = http.request {
        method = "POST",
        url = "http://www.germanunkol.de/bandana/userlevels/upload.php",
        source = ltn12.source.string(data),
        headers = {
            ["content-type"] = "text/plain",
            ["content-length"] = tostring(#data)
        },
        sink = ltn12.sink.table(response)
    }
	print("Sent: '", data:sub(1, 50) .. "...'" )
	
	print( "response:", result, respcode, respheaders, respstatus )
	print( table.concat( response ))
end

upload.sendFile( "asds", "/home/micha/.local/share/love/bandana/mylevels/climb.dat", "climb", "germanunkol" )

return upload
