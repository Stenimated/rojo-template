local stdio = require("@lune/stdio")

return {
	title = "install",
	description = "install packages",
	order = 4,
	execute = function(content, quickCommand: string?)
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
	end,
}
