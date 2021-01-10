local COMMON = require "libs.common"
local CAMERA = require "libs_project.cameras"

local View = COMMON.class("LevelLineView")

local COLOR_CURRENT = vmath.vector4(1,0,0,1)
local COLOR_NEW = vmath.vector4(0,1,0,1)
local COLOR_REMOVED = vmath.vector4(0.4,0.4,0.4,1)
local COLOR_WHITE = vmath.vector4(1,1,1,1)

function View:bind_vh()
    self.vh = {
        top = { root = msg.url("game:/line_top"), sprite = msg.url("game:/line_top#sprite") },
        bottom = { root = msg.url("game:/line_bottom") },
        model = msg.url("game:/level_view#model")
    }
end

function View:init()
    sprite.set_constant(self.vh.top.sprite, "tint", vmath.vector4(0, 0, 1, 1))
    self.positions = {
        start = vmath.vector3(0, 0, 0),
        finish = vmath.vector3(0, 0, 0),
        touch = vmath.vector3(0, 0, 0),
    }
    self.show = false
end

---@param world World
function View:initialize(world)
    self.world = assert(world)
    self:bind_vh()
    self:init()
    self:hide()
end

function View:hide()
    self.taking_screenshot = false
    self.show = false
    self.positions = {
        start = vmath.vector3(0, 0, 0),
        finish = vmath.vector3(0, 0, 0),
        touch = nil
    }
    self:update_position()
end

function View:hide_for_screenshot()
    self.taking_screenshot = true
    self:update_position()
end

function View:flip()
    local pos = self.positions.start
    self.positions.start = self.positions.finish
    self.positions.finish = pos
end

function View:final()
    self:hide()
end

function View:on_input(action_id, action)
    if action_id == COMMON.HASHES.INPUT.TOUCH then
        local touch_pos = CAMERA.current:screen_to_world_2d(action.screen_x, action.screen_y)
        if action.pressed then
            self.input_pressed = true
            if self.show then
                local point_a = vmath.vector3(self.positions.start.x, self.positions.start.y, 0)
                local point_b = vmath.vector3(self.positions.finish.x, self.positions.finish.y, 0)

                --Уравнение прямой. Выводим по 2м точкам
                local a = point_a.y - point_b.y
                local b = point_b.x - point_a.x
                local c = point_a.x * point_b.y - point_b.x * point_a.y
                local d = a * touch_pos.x + b * touch_pos.y + c

                --тап далеко от старта, двигаем стартовый тап
                if math.abs(d) > 200000 then
                    self.positions.start.x = touch_pos.x
                    self.positions.start.y = touch_pos.y
                end

                local dist = math.sqrt((touch_pos.x - self.positions.start.x) ^ 2 + (touch_pos.y - self.positions.start.y) ^ 2)
                --тап рядом со стартовой точкой
                if dist < 40 then
                    self.positions.touch = touch_pos
                end
            else
                self.show = true
                self.positions.start.x = touch_pos.x
                self.positions.start.y = touch_pos.y
            end
        end

        if (self.input_pressed) then
            --двигаем точку стартк
            if self.positions.touch then
                local dx = touch_pos.x - self.positions.touch.x
                local dy = touch_pos.y - self.positions.touch.y
                self.positions.touch = touch_pos

                self.positions.start.x = self.positions.start.x + dx
                self.positions.start.y = self.positions.start.y + dy
            else
                --двигаем точку конца
                self.positions.finish.x, self.positions.finish.y = CAMERA.current:screen_to_world_2d(action.screen_x, action.screen_y, false, nil, true)
            end
        end

        if self.input_pressed and action.released then
            self.positions.touch = nil
            self.input_pressed = false
        end

    end
end

function View:update(dt)
    self:update_position()
end

function View:update_position()
    if (not self.world.lvl.matcher or not self.world.lvl.matcher.w) then return end
    local p_w = self.world.lvl.matcher.w
    local p_h = self.world.lvl.matcher.h

    model.set_constant(self.vh.model, "screen", vmath.vector4(p_w, p_h, 0, 0))

    if (not self.show) then
        go.set_position(vmath.vector3(0, 0, -1000), self.vh.top.root)
        go.set_position(vmath.vector3(0, 0, -1000), self.vh.bottom.root)
        model.set_constant(self.vh.model, "line", vmath.vector4(0, 0, 0, 0))
        model.set_constant(self.vh.model,"color_current",COLOR_CURRENT)
        model.set_constant(self.vh.model,"color_new",COLOR_NEW)
        model.set_constant(self.vh.model,"color_removed",COLOR_REMOVED)
    else

        local start_pos = vmath.vector3(self.positions.start.x, self.positions.start.y, 0)
        local end_pos = vmath.vector3(self.positions.finish.x, self.positions.finish.y, 0)

        -- pprint(start_pos)
        -- pprint(self.start_pos)
        local point_a = vmath.vector3(self.positions.start.x + p_w / 2, self.positions.start.y + p_h / 2, 0)
        local point_b = vmath.vector3(self.positions.finish.x + p_w / 2, self.positions.finish.y + p_h / 2, 0)
        --  pprint(point_a)
        --   pprint(point_b)
        local a = point_a.y - point_b.y
        local b = point_b.x - point_a.x
        local c = point_a.x * point_b.y - point_b.x * point_a.y
        model.set_constant(self.vh.model, "line", vmath.vector4(a, b, c, 0))

        --pprint(point_a)
        --pprint(point_b)
        a = start_pos.y - end_pos.y
        b = end_pos.x - start_pos.x
        c = start_pos.x * end_pos.y - end_pos.x * start_pos.y

        -- print("a:" .. a .. " b:" .. b .. " c:" .. c)

        if (b == 0) then return end

        local p1 = vmath.vector3(-540 / 2, (540 / 2 * a - c) / b, 0)
        local p2 = vmath.vector3(540 / 2, (-540 / 2 * a - c) / b, 0)

        --a = point_a.y - point_b.y
        -- b = point_b.x - point_a.x
        -- c = point_a.x * point_b.y - point_b.x * point_a.y

        -- local p1a = vmath.vector3(-540 / 2, (540 / 2 * a - c) / b, 0)
        --  local p2a = vmath.vector3(540 / 2, (-540 / 2 * a - c) / b, 0)
        --pprint(p1)
        -- pprint(p2)
        if (not self.taking_screenshot) then
            msg.post("@render:", "draw_line", { start_point = p1, end_point = p2, color = vmath.vector4(0, 1, 0, 0.66) })
            msg.post("@render:", "draw_line", { start_point = self.positions.start, end_point = self.positions.finish, color = vmath.vector4(1, 1, 0, 0.66) })
            local v = vmath.vector3()
            v.x, v.y, v.z = self.positions.start.x, self.positions.start.y, 0.1
            go.set_position(v, self.vh.top.root)
            v.x, v.y, v.z = self.positions.finish.x, self.positions.finish.y, 0.1
            go.set_position(v, self.vh.bottom.root)
            model.set_constant(self.vh.model,"color_current",COLOR_CURRENT)
            model.set_constant(self.vh.model,"color_new",COLOR_NEW)
            model.set_constant(self.vh.model,"color_removed",COLOR_REMOVED)
        else
            model.set_constant(self.vh.model,"color_current",COLOR_CURRENT)
            model.set_constant(self.vh.model,"color_new",COLOR_CURRENT)
            model.set_constant(self.vh.model,"color_removed",COLOR_WHITE)
            go.set_position(vmath.vector3(0, 0, -1000), self.vh.top.root)
            go.set_position(vmath.vector3(0, 0, -1000), self.vh.bottom.root)
        end
    end
end

return View