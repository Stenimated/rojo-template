local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local command = require("../util/command")
local place = require("../util/place")
local serve = require("./serve")

local startablePlaces = {
	"default",
}

return {
	title = "start",
	description = "Starts a local-place",
	order = -1,
	execute = function(content, quickCommand: string?)
		assert(quickCommand == nil, `Quick command not supported, because it would instantly close the starting place`)

		local target =
			startablePlaces[command.prompt(`What place would you like to start?`, startablePlaces, false):expect()]

		if table.find(startablePlaces, target) == nil then
			error(`Invalid place {target}`)
		end

		print(`Starting {target}...{fs.isDir("./Packages")}`)
		if fs.isDir("./Packages") == false then
			stdio.write(`Installing packages... \n`)
			print(process.spawn("wally", {
				"install",
			}))
			stdio.write("Create types for packages... \n")
			print(process.spawn("wally-package-types", {
				"--sourcemap",
				"sourcemap.json",
				"Packages",
			}))
		end

		stdio.write(`Building... \n`)

		place.BuildPlace(target):expect(`Failed to build place`)

		stdio.write(`Starting place... \n`)

		process.spawn(`powershell`, {
			`-Command`,
			`Start-Process`,
			`{process.cwd}places/{target}.rbxl`,
		})

		stdio.write(`Waiting for place to start... \n`)
		while not fs.isFile(`{process.cwd}places/{target}.rbxl.lock`) do
			task.wait()
		end

		local serveThread: thread
		while true do
			local options = {
				"Write",
				"Serve",
			}
			local i = command.prompt(`What would you like to do?`, options, false):expect()

			local value = options[i]

			if value == "Write" then
				print(`Getting place...`)
				local game: DataModel = place.GetPlace(target):expect(`Failed to get place`)
				print(`Writing place...`)
				place.WriteToFileSystem(game, target):expect(`Failed to write place`)
				print(`Place written!`)
			elseif value == "Serve" then
				if serveThread then
					pcall(function()
						task.cancel(serveThread)
					end)
				end
				serveThread = task.spawn(serve.execute, content, target)
				print(`Serving {target} at port 32000`)
			else
				error(`Invalid option {value}`)
			end
		end
	end,
}
