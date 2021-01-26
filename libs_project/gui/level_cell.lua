local COMMON = require "libs.common"
local LEVELS = require "assets.levels.levels"
local WORLD = require "world.world"
local SM = require "libs_project.sm"
local COLOR_HELPER = require "richtext.color"
local ButtonScale = require "libs_project.gui.button_scale"

local COLORS = {
    CURRENT = COLOR_HELPER.parse_hex("#6b8e23"),
    CLOSED = COLOR_HELPER.parse_hex("#472A15"), --COLOR_HELPER.parse_hex("#999999"),
    OPENED = COLOR_HELPER.parse_hex("#472A15")
}

---@class LevelCellGui
local LevelCell = COMMON.class("LevelCellGui")

function LevelCell:initialize(root_name)
    self.vh = {
        root = gui.get_node(root_name .. "/root"),
        bg = gui.get_node(root_name .. "/bg"),
        icon = gui.get_node(root_name .. "/icon"),
        lock = gui.get_node(root_name .. "/lock"),
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

function LevelCell:level_set_idx(lvl_idx)
    checks("?", "number")
    self.level = assert(LEVELS.get_by_idx(lvl_idx))
    gui.play_flipbook(self.vh.icon, COMMON.HASHES.hash(self.level.regions[1].art))

    self:on_storage_changed()
end

function LevelCell:on_storage_changed()
    local opened = WORLD:level_can_play(self.level.idx)
    for i = 1, 3 do
        gui.set_enabled(self.vh.stars[i], opened)
    end
    local stars = WORLD.storage:level_get_stars(self.level.idx)
    for i = 1, 3 do
        gui.play_flipbook(self.vh.stars[i], COMMON.HASHES.hash((i <= stars) and "icon_star_on" or "icon_star_off"))
    end

    gui.set_enabled(self.vh.lock, not opened)

    if (self.level == WORLD:level_get_current()) then
        gui.set_color(self.vh.bg, COLORS.CURRENT)
    else
        gui.set_color(self.vh.bg, opened and COLORS.OPENED or COLORS.CLOSED)
    end
    self.views.btn:set_ignore_input(not opened)
end

function LevelCell:percent_set(percent)
    checks("?", "number")
    self.percent = percent
    gui.set_text(self.vh.lbl, percent)
end

function LevelCell:activate()
    if (self.active) then return true end
    gui.play_flipbook(self.vh.star, COMMON.HASHES.hash("icon_star_on"))
end

function LevelCell:on_input(action_id, action)
    return self.views.btn:on_input(action_id, action)
end

return LevelCell



