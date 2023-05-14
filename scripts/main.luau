local command = require('util/command')
local t = require('util/t')
local stdio = require("@lune/stdio")
local fs = require("@lune/fs")

--

local options = {
    "exit"
}
local optionsExecutable = {}
local interfaces = t.interface({
    title = t.string,
    description = t.string,
    execute = t.callback
})

-- Create commands

local successfullyRegisteredCommands, partialCommands = pcall(function()
    local partialCommands = {}

    for _, name in fs.readDir("scripts/commands") do
        local endsWith = string.sub(name, -5)

        if endsWith ~= ".luau" then
            continue
        end

        local interface = require(`commands/{name}`)

        if interfaces(interface) == false then
            error(`Command {interface} does not have the correct interface`)
        end

        table.insert(partialCommands, interface)
    end

    table.sort(partialCommands, function(a, b)
        return a.order > b.order
    end)

    return partialCommands
end)

if successfullyRegisteredCommands == false then
    print("Failed to register commands, err: ", partialCommands)
else
    for _, interface in partialCommands do
        optionsExecutable[interface.title] = interface
        table.insert(options, 1, interface.title)
    end
end

--

local commandContext = {
    commands = optionsExecutable
}

-- QUICK EXECUTION

local function execute(option, ...)
    local args = {...}
    if optionsExecutable[option] then
        local success, err = pcall(function()
            optionsExecutable[option].execute(commandContext, table.unpack(args))
        end)

        if success == false then
            error(`Failed to execute command, err: {tostring(err)}`)
        end
    else
        error("Unknown option")
    end
end

-- 


if #process.args == 0 then
    local exit = false
    while not exit do
        local option = options[command.prompt("Hello welcome to the vba commandline, what would you like to do?", options, false):expect()]
        
        if option == "exit" then
            exit = true
        else
            execute(option)
        end
    end
else
    stdio.write(`Using quick command 🚀🚀🚀🚀\n`)
    execute(table.unpack(process.args))
end

