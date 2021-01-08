local BaseScene = require "libs.sm.scene"

---@class GameScene:Scene
local Scene = BaseScene:subclass("Game")
function Scene:initialize()
    BaseScene.initialize(self, "GameScene", "/game_scene#collectionproxy")
end


function Scene:show_done()
    assert(self._input, "need input")
    assert(self._input.level, "need level")
end

return Scene