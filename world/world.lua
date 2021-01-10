local COMMON = require "libs.common"
local Storage = require "world.storage"
local Level = require "world.level"

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
    self.lvl = Level(self,lvl)
    self.lvl:load(lvl)
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
end

function M:update(dt)
    self.storage:update(dt)
    if (self.lvl) then
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.GAME)
        self.lvl:update(dt)
        ctx:remove()
    end
end

function M:dispose()
    self:level_unload()
end

return M()