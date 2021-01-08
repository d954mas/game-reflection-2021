local COMMON = require "libs.common"

---@class LevelConfigRegion
local Region = COMMON.class("Region")

function Region:initialize(art,x,y,scale)
    self.art = assert(art)
    self.position = vmath.vector3(x,y,0)
    self.scale = scale or vmath.vector3(1)
    if type(self.scale) == "number" then
        self.scale = vmath.vector3(self.scale)
    end
end

return Region