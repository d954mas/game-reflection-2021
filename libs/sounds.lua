local COMMON = require "libs.common"
local WORLD = require "world.world"

local TAG = "Sound"
local Sounds = COMMON.class("Sounds")

--gate https://www.defold.com/manuals/sound/
function Sounds:initialize()
	self.gate_time = 0.1
	self.gate_sounds = {}
	self.sounds = {
		star_new = {name = "star_new", url = msg.url("main:/sounds#star_new")}
	}
	self.music = {
		game_music = {name = "game_music", url = msg.url("main:/music#game_music")}
	}
	self.scheduler = COMMON.RX.CooperativeScheduler.create()
	self.subscription = COMMON.EVENT_BUS:subscribe(COMMON.EVENTS.STORAGE_CHANGED)
			:go_distinct(self.scheduler):subscribe(function ()
			self:on_storage_changed()
	end)
	self:on_storage_changed()
end

function Sounds:on_storage_changed()
	sound.set_group_gain(COMMON.HASHES.hash("music"),WORLD.storage.data.options.music and 1 or 0)
	sound.set_group_gain(COMMON.HASHES.hash("sound"),WORLD.storage.data.options.sound and 1 or 0)
end

function Sounds:pause()
	print("PAUSE SOUND")
	COMMON.i("pause", TAG)
	self.gain_music = sound.get_group_gain(COMMON.HASHES.hash("music"))
	self.gain_sound = sound.get_group_gain(COMMON.HASHES.hash("sound"))
	sound.set_group_gain(COMMON.HASHES.hash("music"),0)
	sound.set_group_gain(COMMON.HASHES.hash("sound"),0)
end

function Sounds:resume()
	print("RESUME SOUND")
	COMMON.i("resume", TAG)
	if(self.gain_music) then
		sound.set_group_gain(COMMON.HASHES.hash("music"),self.gain_music)
		self.gain_music = nil
	end
	if(self.gain_sound) then
		sound.set_group_gain(COMMON.HASHES.hash("sound"),self.gain_sound)
		self.gain_sound = nil
	end
end

function Sounds:update(dt)
	self.scheduler:update(dt)
	for k, v in pairs(self.gate_sounds) do
		self.gate_sounds[k] = v - dt
		if self.gate_sounds[k] < 0 then
			self.gate_sounds[k] = nil
		end
	end
end

function Sounds:play_sound(sound_obj)
	assert(sound_obj)
	assert(type(sound_obj) == "table")
	assert(sound_obj.url)


	if not self.gate_sounds[sound_obj] then
		self.gate_sounds[sound_obj] = self.gate_time
		sound.play(sound_obj.url)
		COMMON.i("play sound:" .. sound_obj.name, TAG)
	else
		COMMON.i("gated sound:" .. sound_obj.name .. "time:" .. self.gate_sounds[sound_obj], TAG)
	end
end
function Sounds:play_music(music_obj)
	assert(music_obj)
	assert(type(music_obj) == "table")
	assert(music_obj.url)


	sound.play(music_obj.url)
	COMMON.i("play music:" .. music_obj.name, TAG)
end

return Sounds()