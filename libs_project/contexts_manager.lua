local CLASS = require "libs.middleclass"
local ContextManager = require "libs.contexts_manager"

---@class ContextManagerProject:ContextManager
local Manager = CLASS.class("ContextManagerProject", ContextManager)

Manager.NAMES = {
	MAIN = "MAIN",
	MENU_GUI = "MENU_GUI",
	GAME = "GAME",
	DEBUG_GUI = "DEBUG_GUI",
}

---@class ContextStackWrapperMain:ContextStackWrapper
-----@field data ScriptMain

---@return ContextStackWrapperMain
function Manager:set_context_top_main()
	return self:set_context_top_by_name(self.NAMES.MAIN)
end


return Manager()