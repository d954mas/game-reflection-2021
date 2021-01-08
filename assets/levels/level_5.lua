local BaseLvl = require "assets.levels.level_config"
local Region = require "assets.levels.region"

local Lvl = BaseLvl:subclass("Lvl5")

function Lvl:initialize(...)
    BaseLvl.initialize(self,"Lvl5")
    self.regions = {
        Region("region_4",0,0,1)
    }

    self.figures = {
        Region("circle",0,0,1.2)
    }
end

return Lvl