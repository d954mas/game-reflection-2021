local COMMON = require "libs.common"
local SCENE_ENUMS = require "libs.sm.enums"
local SOUNDS = require "libs.sounds"

local TAG = "GAME_DISTRIBUTION"
local TIME_DELAY = 10 * 60

local M = {}

function M.init()
    assert(COMMON.CONSTANTS.PLATFORM_IS_WEB,"not web")
    assert(gdsdk,"no sdk")
    COMMON.w("init",TAG)
    M.inited = true
    M.ad_next_time = os.clock() + TIME_DELAY
    gdsdk.set_listener(function(self, event, message)
        COMMON.w("event:" .. tostring(event) ,TAG)
        local SM = requiref "libs_project.sm"
        if event == gdsdk.SDK_GAME_PAUSE then
            SOUNDS:pause()
            local scene = SM:get_top()
            if(scene._state == SCENE_ENUMS.STATES.RUNNING)then
                scene:pause()
            end
        elseif event == gdsdk.SDK_GAME_START then
            SOUNDS:resume()
            local scene = SM:get_top()
            if(scene._state == SCENE_ENUMS.STATES.PAUSED)then
                scene:resume()
            end
        end
    end)
  --  gdsdk.show_display_ad("canvas-ad")
end

function M.update(dt)
    if(not M.inited)then return end
end

function M.ad_show()
    if(not M.inited)then return end
    if(os.clock()>M.ad_next_time)then
        M.ad_next_time = os.clock() + TIME_DELAY
        COMMON.w("show_interstitial_ad",TAG)
        gdsdk.show_interstitial_ad()
    end
end

return M