local BaseLvl = require "assets.levels.level_config"
local Region = require "assets.levels.region"

local Lvl = BaseLvl:subclass("Lvl1")

function Lvl:initialize(...)
    BaseLvl.initialize(self,"Lvl3")
    self.regions = {
        Region("region_3",0,0,1)
    }

    self.figures = {
        Region("rect",40,225,2)
    }
end

return Lvl