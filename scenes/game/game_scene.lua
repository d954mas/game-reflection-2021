local COMMON = require "libs.common"
local WORLD = require "world.world"
local LEVELS = require "assets.levels.levels"

local BaseScene = require "libs.sm.scene"

---@class GameScene:Scene
local Scene = BaseScene:subclass("Game")
function Scene:initialize()
    BaseScene.initialize(self, "GameScene", "/game_scene#collectionproxy")
end

function Scene:show_done()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.GAME)
    assert(self._input, "need input")
    assert(self._input.level, "need level")
    WORLD:level_load(LEVELS.get_by_id(self._input.level))
    ctx:remove()
end

return Scene