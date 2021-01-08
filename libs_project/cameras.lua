local COMMON = require "libs.common"
local Camera = require "rendercam.rendercam_camera"


local Cameras = COMMON.class("Cameras")

function Cameras:initialize()

end

function Cameras:init()
	self.map_camera = Camera("map", {
		orthographic = true,
		near_z = -1,
		far_z = 1,
		view_distance = 1,
		fov = 1,
		ortho_scale = 1,
		fixed_aspect_ratio = false ,
		aspect_ratio = vmath.vector3(1280, 680, 0),
		use_view_area = true,
		view_area = vmath.vector3(1280, 680,0),
		scale_mode = COMMON.CONSTANTS.SBERBANK and Camera.SCALEMODE.FIXEDWIDTH or Camera.SCALEMODE.FIXEDWIDTH
	})

	self.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.WINDOW_RESIZED):subscribe(function()
		self:window_resized()
	end)

	self.map_camera:set_position(vmath.vector3(1280/2,680/2,0))

	self.current = self.map_camera
	self:window_resized()
end

function Cameras:update(dt)
	if (self.map_camera) then
		self.map_camera:update(dt)
	end
end

function Cameras:set_current(camera)
	self.current = assert(camera)
end

function Cameras:window_resized()
	self.map_camera:recalculate_viewport()
end

function Cameras:dispose()
	self.subscription:unsubscribe()
end

return Cameras