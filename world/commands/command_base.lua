local COMMON = require "libs.common"

---@class Command
local Command = COMMON.class("Command")

function Command:initialize(name, data)
    self.name = assert(name)
    self.data = data or {}
    self.world = reqf "models.world"
    self:check_data(data)
end

function Command:check_data(data)
end

--inside coroutine
function Command:act(dt)

end

function Command:__tostring()
    return string.format("Command<%s>", self.name)
end

return Command
