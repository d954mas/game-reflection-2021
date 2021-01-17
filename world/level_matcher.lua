local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"
local CAMERAS = require "libs_project.cameras"

local Matcher = COMMON.class("matcher")

local dec64_b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local dec64 = function(data)
    data = string.gsub(data, '[^' .. dec64_b .. '=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (dec64_b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end)        :gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

function Matcher:initialize()
    self.free_pixels = 0
    self.fill_pixels = 0
    self.percent = 0
    self.command_sequence = {  }
    self.working = false
end

function Matcher:init()
    self.history = {}
    self.history_revert = {}
    self:update_screenshot()
end

function Matcher:buffer_changed()
    local buffer_info = {
        buffer = self.buffer,
        width = self.w,
        height = self.h,
        channels = 4
    }
    self.free_pixels, self.fill_pixels = drawpixels.check_fill(buffer_info)
    self.percent = self.fill_pixels / (self.fill_pixels + self.free_pixels)
end

function Matcher:revert()
    if (#self.history > 1) then
        local current = table.remove(self.history) --remove current
        table.insert(self.history_revert, current)
        local png = self.history[#self.history]
        self:buffer_from_img_data(png)
    end
end

function Matcher:revert_revert()
    if (#self.history_revert > 0) then
        local png = table.remove(self.history_revert, 1) --remove current
        table.insert(self.history, png)
        self:buffer_from_img_data(png)
    end
end

function Matcher:buffer_from_img_data(img_data)
    if (self.buffer) then
        drawpixels.buffer_destroy(self.buffer)
    end
    self.buffer, self.w, self.h = png.decode_rgba(img_data, false)
    self:buffer_changed()
end

function Matcher:update_screenshot()
    if (#self.command_sequence ~= 0) then
        COMMON.w("can't add.not empty. update_screenshot.")
        return
    end
    if (self.working) then
        COMMON.w("can't add.working. update_screenshot.")
        return
    end
    table.insert(self.command_sequence, ACTIONS.Function { fun = function()
        local time = os.clock()
        self.working = true
        coroutine.yield()--wait for input view is hide
        coroutine.yield()--wait for input view is hide
        local x, y = CAMERAS.current.viewport.x, CAMERAS.current.viewport.y

        self.w, self.h = CAMERAS.current.viewport.width, CAMERAS.current.viewport.height
        local dy = COMMON.CONSTANTS.level_view_dy
        local left_bottom = CAMERAS.current:world_to_screen(vmath.vector3(-540 / 2, dy - 540 / 2, 0))
        local right_top = CAMERAS.current:world_to_screen(vmath.vector3(540 / 2, dy + 540 / 2, 0))

        x, y = COMMON.LUME.round(left_bottom.x), COMMON.LUME.round(left_bottom.y)
        --должны быть четными иначе начинает уезжать вверх
        --if(x % 2 == 1)then x = x -1 end
        --   if(y % 2 == 1)then y = y - 1 end


        self.w, self.h = COMMON.LUME.round(right_top.x) - x, COMMON.LUME.round(right_top.y) - y


        --должны быть четными иначе начинает уезжать вверх
        --if(self.w % 2 == 1)then self.w = self.w +1 end
        -- if(self.h % 2 == 1)then self.h = self.h +1 end

        print("x:" .. x .. " y:" .. y .. "w:" .. self.w .. " h:" .. self.h)

        local img_data
        if (COMMON.CONSTANTS.PLATFORM_IS_WEB) then
            local wait = true
            screenshot.html5(x, y, self.w, self.h, function(_, base64)
                base64 = string.sub(base64, 23)
                img_data = dec64(base64)
                wait = false
            end)
            while (wait) do coroutine.yield() end
        else
            local wait = true
            screenshot.callback(x, y, self.w, self.h, function(_, png)
                wait = false
                img_data = png
            end)
            while (wait) do coroutine.yield() end
        end

        if (#self.history > 50) then
            table.remove(self.history, 1)
        end
        table.insert(self.history, img_data)
        self.history_revert = {}
        self:buffer_from_img_data(img_data)

        self.working = false

        COMMON.i("screenshot time:" .. (os.clock() - time))
    end })

end

function Matcher:final()
    self.working = false
    if (self.buffer) then
        drawpixels.buffer_destroy(self.buffer)
    end
    self.history = {}
    self.history_revert = {}
    self.buffer, self.w, self.h = nil, nil, nil
    self.free_pixels, self.fill_pixels = 0, 0
    self.percent = 0
    self.command_sequence = {}
end

return Matcher