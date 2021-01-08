local COMMON = require "libs.common"
local LevelMatcher = require "world.level_matcher"

local FACTORY_REGION_URL = msg.url("game:/factories#factory_region")
local FACTORY_EMPTY_URL = msg.url("game:/factories#factory_empty")
local FACTORY_FIGURE_URL = msg.url("game:/factories#factory_figure")
local TAG = "Level"

---@class Level
local Lvl = COMMON.class("Level")

---@param config LevelConfig
function Lvl:initialize(config)
    self.config = assert(config)
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
    self.go_root = self:_create_go(FACTORY_EMPTY_URL)
    self.go_regions = {}
    self.go_figures = {}
    COMMON.d("load regions", TAG)
    for _, region in ipairs(self.config.regions) do
        COMMON.d("region:" .. region.art)
        pprint(region.position)
        local go_url = self:_create_go(FACTORY_REGION_URL, region.position, region.scale, COMMON.HASHES.hash(region.art))
        table.insert(self.go_regions, go_url)
        local sprite_url = msg.url(go_url.socket, go_url.path, "sprite_mask")
        sprite.play_flipbook(sprite_url, hash(region.art))
    end
    COMMON.d("load figures", TAG)
    for _, region in ipairs(self.config.figures) do
        COMMON.d("figure:" .. region.art)
        local go_url = self:_create_go(FACTORY_FIGURE_URL, vmath.vector3(region.position.x, region.position.y, 0.01), region.scale, COMMON.HASHES.hash(region.art))
        table.insert(self.go_figures, go_url)
        local sprite_url = msg.url(go_url.socket, go_url.path, "sprite")
        sprite.set_constant(sprite_url, "tint", vmath.vector4(1, 0, 0, 1))
    end

    timer.delay(0.1,false,function ()
        --wait one frame before all go created
        self.matcher:init()
    end)
    timer.delay(0.2,false,function ()
        for _,figure in ipairs(self.go_figures)do
            go.delete(figure)
        end
    end)
end

function Lvl:update(dt)

end

function Lvl:unload()
    if self.go_root then
        go.delete(self.go_root, true)
        self.go_root = nil
        self.go_regions = nil
        self.go_figures = nil
        self.matcher:final()
        self.matcher = nil
    end
end

return Lvl