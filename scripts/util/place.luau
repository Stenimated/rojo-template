local roblox = require("@lune/roblox")
local net = require("@lune/net")
local fs = require("@lune/fs")
local promise = require("./promise")
local t = require("./t")

--

local module = {}

function module.GetPlace(name: string)
	assert(t.string(name))

	local fullName = `places/{name}.rbxl`
	if fs.isFile(fullName) == false then
		return promise.reject("Place does not exist")
	end

	return promise.new(function(resolve)
		resolve(roblox.readPlaceFile(fullName))
	end)
end

function module.BuildPlace(placeName: string)
	assert(t.string(placeName))

	local projectFile = `{placeName}.project.json`

	local target = `{process.cwd}{projectFile}`

	if fs.isFile(target) == false then
		return promise.reject("Project file does not exist")
	end

	return promise.new(function(resolve, err)
		local result = process.spawn("rojo", {
			"build",
			"--output",
			`places/{placeName}.rbxl`,
			target,
		})

		if result.ok then
			resolve()
		else
			err(result)
		end
	end)
end

function module.WriteToFileSystem(datamodel: DataModel, placeName: "default")
	assert(placeName == "default", "Invalid place name")

	local SERVICES = {
		"Lighting",
		"TextChatService",
		"Chat",
		"VoiceChatService",
		"LocalizationService",
		"StarterGui",
		"Players",
		"StarterPlayer",
		"SoundService",
		"HttpService",
		"ServerStorage",
		"ReplicatedStorage",
	}
	local IGNORE_CHILDREN_DESTRUCTION =
		{ ["TextChatService"] = true, ["StarterGui"] = true, ["ServerStorage"] = true, ["Lighting"] = true }
	local TRANSFORMER = {
		["StarterPlayer"] = function(StarterPlayer: StarterPlayer)
			for _, v in StarterPlayer:GetChildren() do
				if v.Name == "StarterCharacterScripts" or v.Name == "StarterPlayerScripts" then
					v:Destroy()
				end
			end
		end,
		["ReplicatedStorage"] = function(ReplicatedStorage: ReplicatedStorage)
			for _, v in ReplicatedStorage:GetChildren() do
				if v.Name == "WallyPackages" or v.Name == "Packages" or v.Name == "Client" or v.Name == "Shared" then
					v:Destroy()
				end
			end
		end,
	}
	local ASSETS = `assets`
	local DIRECTORY_SHARED = `{ASSETS}/shared`

	return promise.new(function(resolve)
		-- delete stuff

		local readyToWrite = {}
		for _, serviceName in SERVICES do
			local service = datamodel:GetService(serviceName)

			if TRANSFORMER[serviceName] then
				TRANSFORMER[serviceName](service)
			elseif not IGNORE_CHILDREN_DESTRUCTION[serviceName] then
				for _, child in service:GetChildren() do
					child:Destroy()
				end
			end

			table.insert(readyToWrite, service)
		end

		for _, service in readyToWrite do
			roblox.writeModelFile(`{DIRECTORY_SHARED}/{service.Name}.rbxm`, { service })
		end

		do
			-- Workspace is a special case because we want to seperate the Workspace.Map from The actual Workspace because the "Workspace" will be a XML file while "Workspace.Map" is binary.
			-- Map is tremendously large and Github file limit is 100MB so we need to seperate it.
			-- Include Terrain into that equation LOL

			local workspace = datamodel:GetService("Workspace"):Clone()
			local map = workspace:FindFirstChild("Map")

			if map then
				map:Destroy()
			end

			local terrain = workspace:FindFirstChild("Terrain")

			if terrain then
				terrain:Destroy()
			end

			roblox.writeModelFile(`{ASSETS}/{placeName}/Workspace.rbxmx`, { workspace })
		end

		do
			--
			local workspace = datamodel:GetService("Workspace")
			local map = workspace:FindFirstChild("Map")

			roblox.writeModelFile(`{ASSETS}/{placeName}/Workspace-Map.rbxm`, { map })
		end

		resolve()
	end)
end

return module
