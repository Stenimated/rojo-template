local place = require("../util/place")
local command = require("../util/command")
local stdio = require("@lune/stdio")

local buildablePlaces = {
	"default",
}

return {
	title = "write",
	description = "Take data from .rbxl file and write it to assets/**/*, used to represent the source of truth for Bushido",
	order = 2,
	execute = function(content, quickCommand: string?)
		local target = quickCommand
			or buildablePlaces[command
				.prompt(`What place would you like to write down?`, buildablePlaces, false)
				:expect()]

		if table.find(buildablePlaces, target) == nil then
			error(`Invalid place {target}`)
		end

		stdio.write(`Writing {target}...\n`)

		local datamodel = place.GetPlace(target):expect()

		place.WriteToFileSystem(datamodel, target):expect()

		stdio.write(`Successfully built {target}!\n`)
	end,
}
