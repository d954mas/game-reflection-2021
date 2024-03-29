local COMMON = require "libs.common"
local Camera = require "rendercam.rendercam_camera"


local Cameras = COMMON.class("Cameras")

function Cameras:initialize()

end

function Cameras:init()
	self.game_camera = Camera("game", {
		orthographic = true,
		near_z = -1,
		far_z = 1,
		view_distance = 1,
		fov = 1,
		ortho_scale = 1,
		fixed_aspect_ratio = false ,
		aspect_ratio = vmath.vector3(540, 960, 0),
		use_view_area = true,
		view_area = vmath.vector3(540, 960,0),
		scale_mode =  Camera.SCALEMODE.FIXEDWIDTH
	})

	self.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.WINDOW_RESIZED):subscribe(function()
		self:window_resized()
	end)

	--self.game_camera:set_position(vmath.vector3(540/2,960/2,0))

	self.current = self.game_camera
	self:window_resized()
end

function Cameras:update(dt)
	if (self.game_camera) then
		self.game_camera:update(dt)
	end
end

function Cameras:set_current(camera)
	self.current = assert(camera)
end

function Cameras:window_resized()
	self.game_camera:recalculate_viewport()
end

function Cameras:dispose()
	self.subscription:unsubscribe()
end

return Cameras