local COMMON = require "libs.common"

---@class LevelConfig
local Lvl = COMMON.class("LevelConfig")

function Lvl:initialize(id)
    self.id = assert(id)
    ---@type LevelConfigRegion[]
    self.regions = {}
    ---@type LevelConfigRegion[]
    self.figures = {}
    self.targets = {
        0.60, 0.80, 0.95
    }
end

return Lvl