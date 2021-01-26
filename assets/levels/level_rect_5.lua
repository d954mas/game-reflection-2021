local BaseLvl = require "assets.levels.level_config"
local Region = require "assets.levels.region"

local Lvl = BaseLvl:subclass("Lvl")

function Lvl:initialize(...)
    BaseLvl.initialize(self,"region_rect_5")
    --bg
    self.regions = {
        Region("region_rect_5",0,0,1)
    }

end

return Lvl