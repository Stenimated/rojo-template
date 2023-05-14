local stdio = require("@lune/stdio")
local place = require("../util/place")

return {
	title = "deploy",
	description = "Publishes the local-place directly to roblox, use with caution",
	order = 10,
	execute = function(content, quickCommand: string?)
		if quickCommand ~= "ci/cd" then
			stdio.prompt(
				"confirm",
				`Are you sure you want to publish the place? You should be rather pushing and wait`,
				false
			)
		else
			print(`CI/CD detected, skipping prompt`)
		end

		print(`Building...`)
		place.BuildPlace(`full`):expect(`Failed to build place`)
		print(`Building complete!`)
		print(`Uploading...`)

		error(`Rbx cloud is not installed/impelemented yet`)

		-- print(process.spawn(`rbxcloud`, {
		--     -- `experience`,
		--     -- `publish`,
		-- }))
	end,
}
