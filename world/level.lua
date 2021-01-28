local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local LevelMatcher = require "world.level_matcher"
local LineView = require "scenes.game.go.level_line_view"

local FACTORY_REGION_URL = msg.url("game:/factories#factory_region")
--local FACTORY_REGION_BG_URL = msg.url("game:/factories#factory_region_bg")
--local FACTORY_EMPTY_URL = msg.url("game:/factories#factory_empty")
local FACTORY_FIGURE_URL = msg.url("game:/factories#factory_figure")
local TAG = "Level"

---@class Level
local Lvl = COMMON.class("Level")

---@param world World
---@param config LevelConfig
function Lvl:initialize(world,config)
    self.world = assert(world)
    self.config = assert(config)
    self.command_sequence = ACTIONS.Sequence()
    self.command_sequence.drop_empty = false
end

function Lvl:_create_go(factory_url, position, scale, image)
    local go_url = msg.url(factory.create(factory_url, position, nil, nil, scale))
    if image then
        local sprite_url = msg.url(go_url)
        sprite_url.fragment = "sprite"
        sprite.play_flipbook(sprite_url, image)
    end
    if self.go_root then
        go.set_parent(go_url, self.go_root)
    end
    return go_url
end

function Lvl:load()
    self.matcher = LevelMatcher()
    self.go_root = msg.url("game:/level_center")
    self.go_regions = {}
    self.go_figures = {}
    self.views = {
        line_view = LineView(self.world)
    }
    COMMON.d("load regions", TAG)
    for _, region in ipairs(self.config.regions) do
        COMMON.d("region:" .. region.art)
        local go_url = self:_create_go(FACTORY_REGION_URL, region.position, region.scale, COMMON.HASHES.hash(region.art))
        table.insert(self.go_regions, go_url)
        local sprite_url = msg.url(go_url.socket, go_url.path, "sprite_mask")
        sprite.play_flipbook(sprite_url, hash(region.art))


    --    local go_url = self:_create_go(FACTORY_REGION_BG_URL, vmath.vector3(region.position.x, region.position.y, 0),
        --region.scale, COMMON.HASHES.hash(region.art .. "_bg"))
      -- local sprite_url = msg.url(go_url.socket, go_url.path, "sprite")
      --  sprite.set_constant(sprite_url, "tint", vmath.vector4(0.55, 0.55, 0.55, 1))
    end
    COMMON.d("load figures", TAG)
    for _, region in ipairs(self.config.figures) do
        COMMON.d("figure:" .. region.art)
        local go_url = self:_create_go(FACTORY_FIGURE_URL, vmath.vector3(region.position.x, region.position.y, 0.01),
                region.scale, COMMON.HASHES.hash(region.art))
        table.insert(self.go_figures, go_url)
        local sprite_url = msg.url(go_url.socket, go_url.path, "sprite")
        sprite.set_constant(sprite_url, "tint", vmath.vector4(1, 0, 0, 1))
    end
    self.command_sequence:add_action(function()
        coroutine.yield()--wait 1 frame
        coroutine.yield()--wait 1 frame
        coroutine.yield()--wait 1 frame
        coroutine.yield()--wait 1 frame
    end)
    self.command_sequence:add_action(function()
        self.matcher:init()
        local commands = self.matcher.command_sequence
        self.matcher.command_sequence = {}
        local sequence = ACTIONS.Sequence()
        for _, cmd in ipairs(commands) do
            sequence:add_action(cmd)
        end
        sequence:update(0)
        while (not sequence:is_empty()) do
            local dt = coroutine.yield()
            sequence:update(dt)
        end
        for _, figure in ipairs(self.go_regions) do
            local sprite_url = msg.url(figure.socket, figure.path, "sprite")
            msg.post(sprite_url,COMMON.HASHES.MSG.DISABLE)
        end
        local ctx = COMMON.CONTEXT:set_context_top_by_name(COMMON.CONTEXT.NAMES.GAME_GUI)
        ctx.data:tutorial_check_start()
        ctx:remove()
    end)
    self.command_sequence:add_action(function()
        go.set_position(vmath.vector3(0, 0, 0), "game:/level_view")
    end)
    self.command_sequence:add_action(function()
        for _, figure in ipairs(self.go_figures) do
            go.delete(figure)
        end
    end)

end

function Lvl:update(dt)
    if (#self.matcher.command_sequence > 0) then
        for _, cmd in ipairs(self.matcher.command_sequence) do
            self.command_sequence:add_action(cmd)
        end
        self.matcher.command_sequence = {}
    end
    if (self.views) then
        self.views.line_view:update(dt)
    end
    self.command_sequence:update(dt)
end

function Lvl:unload()
    if self.go_root then
        go.delete(self.go_root, true)
        self.go_root = nil
        self.go_regions = nil
        self.go_figures = nil
        self.matcher:final()
        self.matcher = nil
        self.command_sequence = ACTIONS.Sequence()
        self.command_sequence.drop_empty = false
        self.views.line_view:final()
        self.views = nil
    end
end

function Lvl:on_input(action_id, action)
    if (self.views) then
        self.views.line_view:on_input(action_id, action)
    end
end

return Lvl