local COMMON = require "libs.common"
local Storage = require "world.storage"

local TAG = "WORLD"
---@class World:Observable
local M = COMMON.class("World")

function M:level_unload()
    if self.lvl then
        self.lvl:unload()
        self.lvl = nil
    end
end
---@param lvl Level
function M:level_load(lvl)
    assert(lvl)
    assert(self.lvl)
    COMMON.i("LOAD LVL:" .. lvl, TAG)
    self.lvl = lvl
    self.lvl:load()
end

function M:level_reload()
    assert(self.lvl)
    self.lvl:unload()
    self.lvl:load()
end

function M:initialize()
    ---@type Level
    self.lvl = nil
    self.storage = Storage()
end

function M:update(dt)
    self.storage:update(dt)
    if (self.lvl) then
        self.lvl:update(dt)
    end
end

function M:dispose()
    self:level_unload()
end

return M()