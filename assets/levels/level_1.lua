local BaseLvl = require "assets.levels.level_config"
local Region = require "assets.levels.region"

local Lvl = BaseLvl:subclass("Lvl1")

function Lvl:initialize(...)
    BaseLvl.initialize(self,"Lvl1")
    --bg
    self.regions = {
        Region("region_1",0,0,2)
    }

    --red. Copy figures to fill regions
    self.figures = {
        Region("rect",-100,-100,1)
    }
end

return Lvl