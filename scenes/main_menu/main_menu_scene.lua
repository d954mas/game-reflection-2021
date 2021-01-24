local COMMON = require "libs.common"
local BaseScene = require "libs.sm.scene"

local SCENE_ENUMS = require "libs.sm.enums"

---@class SelectLevelScene:Scene
local Scene = BaseScene:subclass("MainMenuModalScene")
function Scene:initialize()
    BaseScene.initialize(self, "MainMenuModalScene", "/main_menu_scene#collectionproxy")
    self._config.modal = true
    self._config.keep_loaded = true
end

---@param transition string
function Scene:transition(transition)
    BaseScene.transition(self,transition)
    if(transition == SCENE_ENUMS.TRANSITIONS.ON_HIDE) then
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MENU_GUI)
        ctx.data:hide_gui()
        COMMON.coroutine_wait(0.7)
    elseif (transition == SCENE_ENUMS.TRANSITIONS.ON_SHOW) then
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.MENU_GUI)
        ctx.data:show_gui()
        COMMON.coroutine_wait(0.7)
    end
end


return Scene