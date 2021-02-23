local COMMON = require "libs.common"

local TAG = "UNITY ADS"
local TIME_DELAY = 20 * 60
local TIME_DELAY_START = 10 * 60

local M = {}

function M.init()
    assert(COMMON.CONSTANTS.PLATFORM_IS_ANDROID,"not android")
    assert(unityads,"no sdk")
    COMMON.w("init",TAG)
    M.inited = true
    M.ad_next_time = os.clock() + TIME_DELAY_START
    unityads.initialize("4023673", function (_, msg_type, message)
        COMMON.w("msg:" .. tostring(msg_type),TAG)
    end,false)

end

function M.update(dt)
    if(not M.inited)then return end
end

function M.ad_show()
    if(not M.inited)then return end
    if(os.clock()>M.ad_next_time)then
        M.ad_next_time = os.clock() + TIME_DELAY
        COMMON.w("show_interstitial_ad",TAG)
        unityads.show() -- show default ad
    end
end

return M