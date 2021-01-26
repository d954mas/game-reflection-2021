local BaseLvl = require "assets.levels.level_config"
local Region = require "assets.levels.region"

local Lvl = BaseLvl:subclass("Lvl")

function Lvl:initialize(...)
    BaseLvl.initialize(self,"region_in_an_1")
    --bg
    self.regions = {
        Region("region_in_an_1",0,0,1)
    }

end

return Lvl