local stdio = require("@lune/stdio")
local promise = require("./promise")

local module = {}

function module.prompt(message: string, options: {string}, multiSelect: boolean)
    return promise.new(function(resolve)
        local result = stdio.prompt(
            if multiSelect then
                "multiSelect"
            else
                "select"
            ,
            stdio.format(
                message   
            ),
            options
        )

        resolve(result)
    end)
end


return module