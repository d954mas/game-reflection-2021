local M = {}

local levels = {
    require "assets.levels.level_6",
    require "assets.levels.level_1",
    require "assets.levels.level_4",
    require "assets.levels.level_3",
    require "assets.levels.level_5",
    require "assets.levels.level_2"
}


---@type LevelConfig[]
M.levels = {}
---@type LevelConfig[]
M.level_by_id = {}

---@param lvl LevelConfig
local function addLevel(lvl)
    lvl.idx = #M.levels + 1
    table.insert(M.levels, lvl)
    assert(not M.level_by_id[lvl.id], "level with id:" .. lvl.id .. " already exist. Idx:" .. lvl.idx)
    M.level_by_id[lvl.id] = lvl
end

for _, level in ipairs(levels)do
    addLevel(level())
end

function M.get_by_id(id)
    assert(id, "id is nil")
    return assert(M.level_by_id[id], "no level with id:" .. tostring(id))
end

return M