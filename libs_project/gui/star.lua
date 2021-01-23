local COMMON = require "libs.common"


---@class StarGui
local Star = COMMON.class("Star")

function Star:initialize(root_name)
	self.vh = {
		root = gui.get_node(root_name .. "/root"),
		star = gui.get_node(root_name .. "/star"),
		lbl = gui.get_node(root_name .. "/lbl"),
	}

	self.root_name = root_name
	self.percent = 0;
	self.active = false

	gui.set_text(self.vh.lbl,"")
	gui.play_flipbook(self.vh.star,COMMON.HASHES.hash("icon_star_off"))
end

function Star:position_set_x(x)
	local pos = gui.get_position(self.vh.root)
	pos.x = x
	gui.set_position(self.vh.root,pos)
end

function Star:percent_set(percent)
	checks("?","number")
	self.percent = percent
	gui.set_text(self.vh.lbl,percent)
end

function Star:activate()
	if(self.active)then return true end
	gui.play_flipbook(self.vh.star,COMMON.HASHES.hash("icon_star_on"))
end




return Star



