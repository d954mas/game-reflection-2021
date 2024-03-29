local COMMON = require "libs.common"
local CAMERA = require "libs_project.cameras"
local COLORS = require "richtext.color"

local View = COMMON.class("LevelLineView")

local COLOR_CURRENT = vmath.vector4(1, 0, 0, 1)
local COLOR_NEW = vmath.vector4(0, 1, 0, 1)
local COLOR_REMOVED = vmath.vector4(0.4, 0.4, 0.4, 1)
local COLOR_WHITE = vmath.vector4(1, 1, 1, 1)
local COLOR_LINE = COLORS.parse_hex("#80800099")

function View:bind_vh()
    self.vh = {
        top = { root = msg.url("game:/line_top"), sprite = msg.url("game:/line_top#sprite"),arrow =msg.url("game:/line_top/arrow")  },
        bottom = { root = msg.url("game:/line_bottom"),arrow =msg.url("game:/line_bottom/arrow") },
        model = msg.url("game:/level_view#model"),
        line ={root = msg.url("game:/line_line_root"),line = msg.url("game:/line_line"),arrow = msg.url("game:/line_line_arrow"), sprite = msg.url("game:/line_line#sprite")}
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
    self.touched_point = nil
end

---@param world World
function View:initialize(world)
    self.world = assert(world)
    self:bind_vh()
    self:init()
    self:hide()
    go.set_scale(vmath.vector3(10000,20,1),self.vh.line.line)
    sprite.set_constant(self.vh.line.sprite,"tint",COLOR_LINE)
end

function View:hide()
    self.taking_screenshot = false
    self.show = false
    self.positions = {
        start = vmath.vector3(0, 0, 0),
        finish = vmath.vector3(0, 0, 0),
        touch = nil
    }
    msg.post(self.vh.line.root,COMMON.HASHES.MSG.DISABLE)
    msg.post(self.vh.line.line,COMMON.HASHES.MSG.DISABLE)
    msg.post(self.vh.line.arrow,COMMON.HASHES.MSG.DISABLE)
    self:update_position()
end

function View:hide_for_screenshot()
    self.taking_screenshot = true
    msg.post(self.vh.line.root,COMMON.HASHES.MSG.DISABLE)
    msg.post(self.vh.line.line,COMMON.HASHES.MSG.DISABLE)
    msg.post(self.vh.line.arrow,COMMON.HASHES.MSG.DISABLE)
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

        touch_pos.x = COMMON.LUME.clamp(touch_pos.x,-250,250)
        touch_pos.y = COMMON.LUME.clamp(touch_pos.y,-310,220)
        if action.pressed then
            self.input_pressed = true
            if self.show then
              --  local point_a = vmath.vector3(self.positions.start.x, self.positions.start.y, 0)
              --  local point_b = vmath.vector3(self.positions.finish.x, self.positions.finish.y, 0)

                --Уравнение прямой. Выводим по 2м точкам
            --    local a = point_a.y - point_b.y
              --  local b = point_b.x - point_a.x
            --    local c = point_a.x * point_b.y - point_b.x * point_a.y
             --   local d = a * touch_pos.x + b * touch_pos.y + c

                local dist_start = math.sqrt((touch_pos.x - self.positions.start.x) ^ 2 + (touch_pos.y - self.positions.start.y) ^ 2)
                local dist_end = math.sqrt((touch_pos.x - self.positions.finish.x) ^ 2 + (touch_pos.y - self.positions.finish.y) ^ 2)

                self.positions.touch = touch_pos
                if (dist_start < dist_end) then
                    self.touched_point = "start"
                    if (dist_start > 80) then
                        self.touched_point = nil
                    end
                else
                    self.touched_point = "end"
                    if (dist_end > 80) then
                        self.touched_point = nil
                    end
                end
            else
                self.show = true
                self.touched_point = "end"
                self.positions.touch = touch_pos
                self.positions.start.x = touch_pos.x
                self.positions.start.y = touch_pos.y
                self.positions.finish.x = touch_pos.x
                self.positions.finish.y = touch_pos.y
                msg.post(self.vh.line.root,COMMON.HASHES.MSG.ENABLE)
                msg.post(self.vh.line.line,COMMON.HASHES.MSG.ENABLE)
                msg.post(self.vh.line.arrow,COMMON.HASHES.MSG.ENABLE)
            end
        end

        if (self.input_pressed) then
            --двигаем точку стартк
            if self.touched_point == "start" then
                local dx = touch_pos.x - self.positions.touch.x
                local dy = touch_pos.y - self.positions.touch.y
                self.positions.touch = touch_pos

                self.positions.start.x = self.positions.start.x + dx
                self.positions.start.y = self.positions.start.y + dy
            elseif self.touched_point == "end" then
                local dx = touch_pos.x - self.positions.touch.x
                local dy = touch_pos.y - self.positions.touch.y
                self.positions.touch = touch_pos

                self.positions.finish.x = self.positions.finish.x + dx
                self.positions.finish.y = self.positions.finish.y + dy
            end

        end

        if self.input_pressed and action.released then
            self.positions.touch = nil
            self.input_pressed = false

            if (self.touched_point) then
                local stay_point
                local move_point
                if (self.touched_point == "start") then
                    stay_point = self.positions.finish
                    move_point = self.positions.start
                elseif (self.touched_point == "end") then
                    stay_point = self.positions.start
                    move_point = self.positions.finish
                end

                local min_dist = 100
                local dist = vmath.length(move_point - stay_point)
                if (dist >0 and dist < min_dist) then
                    local dist_v = stay_point + (move_point - stay_point) / dist * min_dist

                    if( dist_v.x >-250 and dist_v.x <250 and dist_v.y > -310 and dist_v.y < 220)then
                        move_point.x = dist_v.x
                        move_point.y = dist_v.y
                    end
                end

                min_dist = 140
                dist = vmath.length(move_point - stay_point)
                if (dist >0 and dist < min_dist) then
                    local dist_v = stay_point + (move_point - stay_point) / dist * min_dist

                    if( dist_v.x >-250 and dist_v.x <250 and dist_v.y > -310 and dist_v.y < 220)then
                        move_point.x = dist_v.x
                        move_point.y = dist_v.y
                    end
                end


                if(dist == 0)then
                    self:hide()
                end
            end
            self.touched_point = nil
            --add min dist


        end

    end
end

function View:update(dt)
    self:update_position()
end

function View:update_position()
    if (not self.world.lvl.matcher or not self.world.lvl.matcher.w) then return end
    local p_w = 540--self.world.lvl.matcher.w
    local p_h = 540--self.world.lvl.matcher.h

    model.set_constant(self.vh.model, "screen", vmath.vector4(540, 540, 0, 0))

    if (not self.show) then
        go.set_position(vmath.vector3(0, 0, -1000), self.vh.top.root)
        go.set_position(vmath.vector3(0, 0, -1000), self.vh.bottom.root)
        model.set_constant(self.vh.model, "line", vmath.vector4(0, 0, 0, 0))
        model.set_constant(self.vh.model, "color_current", COLOR_CURRENT)
        model.set_constant(self.vh.model, "color_new", COLOR_NEW)
        model.set_constant(self.vh.model, "color_removed", COLOR_REMOVED)
    else

        local start_pos = vmath.vector3(self.positions.start.x, self.positions.start.y, 0)
        local end_pos = vmath.vector3(self.positions.finish.x, self.positions.finish.y, 0)

        -- pprint(start_pos)
        -- pprint(self.start_pos)
        local point_a = vmath.vector3(self.positions.start.x + p_w / 2,
                self.positions.start.y + p_h / 2-COMMON.CONSTANTS.level_view_dy, 0)
        local point_b = vmath.vector3(self.positions.finish.x + p_w / 2,
                self.positions.finish.y + p_h / 2-COMMON.CONSTANTS.level_view_dy, 0)
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
        local v2 = vmath.normalize(self.positions.finish-self.positions.start)
        local angle =  math.atan2(v2.y,v2.x)

        go.set(self.vh.line.root,"euler.z",math.deg(angle))
        go.set(self.vh.top.arrow,"euler.z",math.deg(angle))
        go.set(self.vh.bottom.arrow,"euler.z",math.deg(angle))
        go.set(self.vh.line.root,"euler.z",math.deg(angle))
        go.set_position(self.positions.start + (self.positions.finish-self.positions.start)/2,self.vh.line.root)

        if (not self.taking_screenshot) then
            local v = vmath.vector3()
            v.x, v.y, v.z = self.positions.start.x, self.positions.start.y, 0.1
            go.set_position(v, self.vh.top.root)
            v.x, v.y, v.z = self.positions.finish.x, self.positions.finish.y, 0.1
            go.set_position(v, self.vh.bottom.root)
            model.set_constant(self.vh.model, "color_current", COLOR_CURRENT)
            model.set_constant(self.vh.model, "color_new", COLOR_NEW)
            model.set_constant(self.vh.model, "color_removed", COLOR_REMOVED)
        else
            model.set_constant(self.vh.model, "color_current", COLOR_CURRENT)
            model.set_constant(self.vh.model, "color_new", COLOR_CURRENT)
            model.set_constant(self.vh.model, "color_removed", COLOR_WHITE)
            go.set_position(vmath.vector3(0, 0, -1000), self.vh.top.root)
            go.set_position(vmath.vector3(0, 0, -1000), self.vh.bottom.root)
        end
    end
end

return View