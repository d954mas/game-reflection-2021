local COMMON = require "libs.common"
local CAMERA = require "libs_project.cameras"

local View = COMMON.class("LevelLineView")

function View:bind_vh()
    self.vh = {
        top = { root = msg.url("game:/line_top"), sprite = msg.url("game:/line_top#sprite") },
        bottom = { root = msg.url("game:/line_bottom") }
    }
end


function View:init()
    sprite.set_constant(self.vh.top.sprite, "tint", vmath.vector4(0, 0, 1, 1))
    self.start_pos = nil
    self.next_pos = nil
    self.touch_pos = nil
end

---@param world World
function View:initialize(world)
    self.world = assert(world)
    self:bind_vh()
    self:init()
    self:hide()
end

function View:hide()
    go.set_position(vmath.vector3(10000), self.vh.top.root)
    go.set_position(vmath.vector3(10000), self.vh.bottom.root)
end

function View:final()
    self:hide()
end

function View:on_input(action_id, action)
    if action_id == COMMON.HASHES.INPUT.TOUCH then
        local touch_pos = CAMERA.current:screen_to_world_2d(action.screen_x, action.screen_y)
        if action.pressed then
            if self.start_pos then
                local point_a = vmath.vector3(self.start_pos.x,self.start_pos.y,0)
                local point_b = vmath.vector3(self.next_pos.x,self.next_pos.y,0)

                --Уравнение прямой. Выводим по 2м точкам
                local a = point_a.y - point_b.y
                local b = point_b.x - point_a.x
                local c = point_a.x * point_b.y - point_b.x * point_a.y
                local d = a * touch_pos.x + b* touch_pos.y + c

                --тап далеко от старта, двигаем стартовый тап
                if math.abs(d) > 200000 then
                    self.start_pos = touch_pos
                end
                local dist = math.sqrt((touch_pos.x - self.start_pos.x)^2 + (touch_pos.y - self.start_pos.y)^2)
                --тап рядом со стартовой точкой
                if dist < 40 then
                    self.touch_pos = touch_pos
                end
            else
                self.start_pos = touch_pos
            end
        end


        --двигаем точку стартк
        if self.touch_pos then
            local dx = touch_pos.x - self.touch_pos.x
            local dy = touch_pos.y - self.touch_pos.y
            self.touch_pos = touch_pos
            self.start_pos.x = self.start_pos.x + dx
            self.start_pos.y = self.start_pos.y + dy
        else
            --двигаем точку конца
            self.next_pos = CAMERA.current:screen_to_world_2d(action.screen_x, action.screen_y)
        end

        if action.released then
            self.touch_pos = nil
        end
        self:update_position()
    end
end

function View:update_position()
    if self.next_pos then
        local p_w = self.world.lvl.matcher.w
        local p_h = self.world.lvl.matcher.h
        local start_pos= vmath.vector3(self.start_pos.x,self.start_pos.y,0)
        local end_pos = vmath.vector3(self.next_pos.x,self.next_pos.y,0)
        --размеры экрана
        model.set_constant("test_model#model","screen",vmath.vector4(p_w,p_h,0,0))

        -- pprint(start_pos)
        -- pprint(self.start_pos)
        local point_a = vmath.vector3(self.start_pos.x+p_w/2,self.start_pos.y+p_h/2,0)
        local point_b = vmath.vector3(self.next_pos.x+p_w/2,self.next_pos.y+p_h/2,0)
        --  pprint(point_a)
        --   pprint(point_b)
        local a = point_a.y - point_b.y
        local b = point_b.x - point_a.x
        local c = point_a.x * point_b.y - point_b.x * point_a.y
        model.set_constant("test_model#model","line",vmath.vector4(a,b,c,0))

        --pprint(point_a)
        --pprint(point_b)
        a = start_pos.y - end_pos.y
        b = end_pos.x - start_pos.x
        c = start_pos.x * end_pos.y - end_pos.x * start_pos.y



        local p1 = vmath.vector3(-540/2,(540/2 * a-c)/b,0)
        local p2 = vmath.vector3(540/2,(-540/2 * a-c)/b,0)

        local a = point_a.y - point_b.y
        local b = point_b.x - point_a.x
        local c = point_a.x * point_b.y - point_b.x * point_a.y
        local p1a = vmath.vector3(-540/2,(540/2 * a-c)/b,0)
        local p2a = vmath.vector3(540/2,(-540/2 * a-c)/b,0)
        --pprint(p1)
        -- pprint(p2)
        msg.post("@render:", "draw_line", { start_point = p1, end_point = p2, color = vmath.vector4(0,1,0,0.66) } )
        -- msg.post("@render:", "draw_line", { start_point = p1a, end_point = p2a, color = vmath.vector4(1,1,0,0.3) } )
        go.set_position(self.start_pos,self.vh.top.root)
        go.set_position(self.next_pos,self.vh.bottom.root)
    end
end

return View