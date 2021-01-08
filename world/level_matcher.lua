local COMMON = require "libs.common"
local ACTIONS = require "libs.actions.actions"

local Matcher = COMMON.class("matcher")

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
        self.buffer, self.w, self.h = screenshot.buffer(0)
        local buffer_info = {
            buffer = self.buffer,
            width = self.w,
            height = self.h,
            channels = 4
        }
        self.free_pixels, self.fill_pixels = drawpixels.check_fill(buffer_info)
        self.total_pixels = self.total_pixels or (self.fill_pixels + self.free_pixels)
        self.percent = self.fill_pixels / self.total_pixels
        self.working = false
        COMMON.i("screenshot time:" .. (os.clock() - time))
    end })

end

function Matcher:final()
    self.working = false
    self.buffer, self.w, self.h = nil, nil, nil
    self.free_pixels, self.fill_pixels, self.total_pixels = 0, 0, nil
    self.percent = 0
    self.command_sequence = {}
end

return Matcher