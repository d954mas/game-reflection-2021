local COMMON = require "libs.common"

local Matcher = COMMON.class("matcher")

function Matcher:initialize()
    self.free_pixels = 0
    self.fill_pixels = 0
    self.total_pixels = nil
    self.percent = 0
end


function Matcher:init()
    self:update_screenshot()
end


function Matcher:update_screenshot()
    self.buffer, self.w, self.h = screenshot.buffer(0)
    local buffer_info = {
        buffer = self.buffer,
        width = self.w,
        height = self.h,
        channels = 4
    }
    self.free_pixels,  self.fill_pixels = drawpixels.check_fill(buffer_info)
    self.total_pixels = self.total_pixels or (self.fill_pixels + self.free_pixels)
    self.percent = self.fill_pixels/self.total_pixels
end

function Matcher:final()
    self.buffer, self.w, self.h = nil, nil, nil
    self.free_pixels, self.fill_pixels, self.total_pixels = 0, 0, nil
    self.percent = 0
end


return Matcher