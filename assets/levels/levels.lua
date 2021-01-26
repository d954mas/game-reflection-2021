local M = {}

local levels = {
    require "assets.levels.level_rect_1",
    require "assets.levels.level_rect_2",
    require "assets.levels.level_rect_4",
    require "assets.levels.level_circle_3",
    require "assets.levels.level_rect_3",
    require "assets.levels.level_3cells_1",
    require "assets.levels.level_circle_1",
    require "assets.levels.level_heart_1",
    require "assets.levels.level_crest_1",
    require "assets.levels.level_3cells_2",
    require "assets.levels.level_in_an_1",
    require "assets.levels.level_in_an_2",

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
    assert(#lvl.regions == 1, "only 1 region is support")
--    assert(#lvl.figures >= 1, "need >= 1 figures")
end

for _, level in ipairs(levels)do
    addLevel(level())
end

---@return LevelConfig
function M.get_by_id(id)
    assert(id, "id is nil")
    return assert(M.level_by_id[id], "no level with id:" .. tostring(id))
end

---@return LevelConfig
function M.get_by_idx(idx)
    assert(idx, "idx is nil")
    return assert(M.levels[idx], "no level with idx:" .. tostring(idx))
end

return M