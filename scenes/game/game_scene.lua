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
    assert(self._input, "need input")
    assert(self._input.level, "need level")
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.GAME)
    WORLD:level_load(LEVELS.get_by_id(self._input.level))
    ctx:remove()
end

function Scene:hide_done()
    local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.GAME)
    WORLD:level_unload()
    ctx:remove()
end

return Scene