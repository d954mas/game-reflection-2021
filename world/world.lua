local COMMON = require "libs.common"
local Storage = require "world.storage"
local Level = require "world.level"
local LEVELS = require "assets.levels.levels"

local TAG = "WORLD"
---@class World:Observable
local M = COMMON.class("World")

function M:level_unload()
    if self.lvl then
        self.lvl:unload()
        self.lvl = nil
    end
end
---@param lvl LevelConfig
function M:level_load(lvl)
    self.lvl_config = assert(lvl, "lvl is nil")
    assert(not self.lvl, "already have level")
    COMMON.i("LOAD LVL:" .. lvl.id .. "(" .. lvl.idx .. ")", TAG)
    self.lvl = Level(self, lvl)
    self.storage.data.level_current = lvl.idx
    self.storage:save()
end

function M:level_show()
    self.lvl:load(self.lvl_config)
end

function M:level_reload()
    assert(self.lvl)
    self.lvl:unload()
    self.lvl:load(self.lvl_config)
end

function M:initialize()
    ---@type Level
    self.lvl = nil
    self.storage = Storage()
    self.commands = {}
end

function M:update(dt)
    self.storage:update(dt)
    if (self.lvl and COMMON.CONTEXT:exist(COMMON.CONTEXT.NAMES.GAME)) then
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.GAME)
        self.lvl:update(dt)
        ctx:remove()
    end
end

function M:level_can_play(level)
    if (level < 0 or level > #LEVELS.levels) then
        return false
    end
    return level == 1 or self.storage.data.levels[level - 1].stars > 0 or self.storage.data.debug.can_play_any
end

function M:level_check_percent(percent)
    assert(self.lvl ~= nil)
    local stars = 0
    for i, star in ipairs(self.lvl.config.targets) do
        local target = self.lvl.config.targets[i]
        if (percent > target) then
            stars = i;
        end
    end
    local lvl_data = self.storage.data.levels[self.lvl.config.idx]
    if (stars > lvl_data.stars) then
        lvl_data.stars = stars;
        self.storage:save()
    end
end


---@return LevelConfig
function M:level_get_current()
    return LEVELS.get_by_idx(self.storage.data.level_current)
end

function M:dispose()
    self:level_unload()
end

return M()