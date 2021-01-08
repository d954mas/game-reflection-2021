local BaseLvl = require "assets.levels.level_config"
local Region = require "assets.levels.region"

local Lvl = BaseLvl:subclass("Lvl6")

function Lvl:initialize(...)
    BaseLvl.initialize(self,"Lvl6")
    self.regions = {
        Region("region_5",0,0,1)
    }

    self.figures = {
        Region("rect",-300,0,3)
    }

end

return Lvl