local COMMON = require "libs.common"
local BtnScale = require "libs_project.gui.button_scale"
local COLOR = require "richtext.color"

local DISABLED_COLOR = COLOR.parse_hex("#555555")

---@class BtnBase:BtnScale
local Btn = COMMON.class("BtnBase",BtnScale)


function Btn:set_ignore_input(ignore)
	self.ignore_input = ignore
	gui.set_color(self.vh.root, self.ignore_input and DISABLED_COLOR or COLOR.COLORS.white)
end


return Btn