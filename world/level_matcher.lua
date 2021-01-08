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
    self.total_pixels = nil
    self.percent = 0
    self.command_sequence = {  }
    self.working = false
end

function Matcher:init()
    self:update_screenshot()
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
        local x,y = CAMERAS.current.viewport.x, CAMERAS.current.viewport.y
        self.w, self.h = CAMERAS.current.viewport.width, CAMERAS.current.viewport.height
        local left_bottom = CAMERAS.current:world_to_screen(vmath.vector3(-540/2,0-512/2,0))
        local right_top = CAMERAS.current:world_to_screen(vmath.vector3(540/2,512/2,0))
        x,y = math.ceil(left_bottom.x), math.ceil(left_bottom.y)
        self.w, self.h = math.ceil(right_top.x)-x, math.ceil(right_top.y)-y
        local buffer
        if (COMMON.CONSTANTS.PLATFORM_IS_WEB) then
            local wait = true
            screenshot.html5(x, y, self.w, self.h, function(_, base64)
                base64 = string.sub(base64, 23)
                local img_data = dec64(base64)
                buffer, self.w, self.h = png.decode_rgba(img_data, false)
                wait = false
            end)
            while (wait) do coroutine.yield() end
        else
            buffer, self.w, self.h = screenshot.buffer(x,y, self.w, self.h)
        end

        local buffer_info = {
            buffer = buffer,
            width = self.w,
            height = self.h,
            channels = 4
        }
        if(self.buffer)then
            drawpixels.buffer_destroy(self.buffer)
        end
        self.buffer = buffer


        self.free_pixels, self.fill_pixels = drawpixels.check_fill(buffer_info)
        self.total_pixels = self.total_pixels or (self.fill_pixels + self.free_pixels)
        self.percent = self.fill_pixels / self.total_pixels
        self.working = false
        COMMON.i("screenshot time:" .. (os.clock() - time))
    end })

end

function Matcher:final()
    self.working = false
    if(self.buffer)then
        drawpixels.buffer_destroy(self.buffer)
    end
    self.buffer, self.w, self.h = nil, nil, nil
    self.free_pixels, self.fill_pixels, self.total_pixels = 0, 0, nil
    self.percent = 0
    self.command_sequence = {}
end

return Matcher