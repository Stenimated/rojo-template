local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local command = require("../util/command")
local place = require("../util/place")

local startablePlaces = {
	"default",
}

return {
	title = "serve",
	description = "Serve a local-place",
	order = 1,
	execute = function(content, quickCommand: string?)
		local target = quickCommand
			or startablePlaces[command.prompt(`What place would you like to serve?`, startablePlaces, false):expect()]

		if table.find(startablePlaces, target) == nil then
			error(`Invalid place {target}`)
		end

		process.spawn(`rojo`, {
			`serve`,
			`--port`,
			`32000`,
			`{target}.project.json`,
		})
	end,
}
