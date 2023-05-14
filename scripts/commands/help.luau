local stdio = require("@lune/stdio")

return {
    title = "help",
    description = "Shows a list of commands",
    order = 6,
    execute = function(content)
        for i, v in content.commands do
            stdio.write(`   `)
            stdio.write(stdio.style("bold"))
            stdio.write(`[{v.title}]`)
            stdio.write(stdio.style("reset"))
            stdio.write(` - {v.description}\n`)
        end
    end
}