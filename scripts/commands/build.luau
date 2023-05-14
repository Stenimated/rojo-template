local place = require("../util/place")
local command = require("../util/command")
local stdio = require("@lune/stdio")

local buildablePlaces = {
	"default",
}

return {
	title = "build",
	description = "Build a local-place",
	order = 3,
	execute = function(content, quickCommand: string?)
		local target = quickCommand
			or buildablePlaces[command.prompt(`What place would you like to build?`, buildablePlaces, false):expect()]

		if table.find(buildablePlaces, target) == nil then
			error(`Invalid place {target}`)
		end

		stdio.write(`Building {target}...\n`)

		place.BuildPlace(target):expect(`Failed to build place`)

		stdio.write(`Successfully built {target}!\n`)
	end,
}
