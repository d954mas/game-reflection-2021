local COMMON = require "libs.common"
local LEVELS = require "assets.levels.levels"
local WORLD = require "world.world"
local SM = require "libs_project.sm"
local ButtonScale = require "libs_project.gui.button_scale"

---@class LevelCellGui
local Star = COMMON.class("LevelCellGui")

function Star:initialize(root_name)
    self.vh = {
        root = gui.get_node(root_name .. "/root"),
        icon = gui.get_node(root_name .. "/icon"),
        stars = {
            gui.get_node(root_name .. "/star_1"),
            gui.get_node(root_name .. "/star_2"),
            gui.get_node(root_name .. "/star_3")
        },
    }
    self.views = {
        btn = ButtonScale(root_name)
    }
    self.views.btn:set_input_listener(function()
        SM:reload({ level = self.level.id }, { close_modals = true })
    end)

    self.root_name = root_name
end

function Star:level_set_idx(lvl_idx)
    checks("?", "number")
    self.level = assert(LEVELS.get_by_idx(lvl_idx))
    local stars = WORLD:level_get_stars(lvl_idx)
    for i = 1, 3 do
        gui.play_flipbook(self.vh.stars[i], COMMON.HASHES.hash((i >= stars) and "icon_star_on" or "icon_star_off"))
    end
    gui.play_flipbook(self.vh.icon, COMMON.HASHES.hash(self.level.regions[1].art))
end

function Star:percent_set(percent)
    checks("?", "number")
    self.percent = percent
    gui.set_text(self.vh.lbl, percent)
end

function Star:activate()
    if (self.active) then return true end
    gui.play_flipbook(self.vh.star, COMMON.HASHES.hash("icon_star_on"))
end

function Star:on_input(action_id, action)
    return self.views.btn:on_input(action_id, action)
end

return Star



