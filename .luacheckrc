std = "lua51"
files['.luacheckrc'].global = false
unused_args = false
cache = true
jobs = 4
max_line_length = 140
max_code_line_length = 140
--remove some imported libs
exclude_files = {
	"richtext/**",
	"gooey/**",
	"libs/rx.lua",
	"libs/curve.lua",
	"libs/log.lua",
	"libs/ecs.lua",
	"libs/checks.lua",
	"libs/i18n/**",
	"_headers/**",
	"tests/**",
	"jstodef/**",
	"assets/spine/fix_spine.lua",
	"googleanalytics/internal/**",
	"googleanalytics/tracker.lua",
}

read_globals = {
  "sys",
  "bit",
  "go",
  "gui",
  "label",
  "render",
  "crash",
  "sprite",
  "sound",
  "tilemap",
  "spine",
  "particlefx",
  "physics",
  "factory",
  "collectionfactory",
  "iac",
  "msg",
  "vmath",
  "url",
  "http",
  "image",
  "json",
  "zlib",
  "iap",
  "push",
  "facebook",
  "hash",
  "hash_to_hex",
  "pprint",
  "window",
  "unityads",
  "socket",
  "defreview",
  "resource",
  "buffer",
  "appsflyer",
  "timer",
  "model",
  "profiler",
  "defos",
  "mnu",
  "native_raycasting",
  "lua_script_instance",
  "lottie_web",
  "checks",
  "drawpixels",
  "png",
  "screenshot",
}

globals = {
  "init",
  "cjson",
  "jstodef",
  "final",
  "update",
  "on_input",
  "on_message",
  "on_reload",
  "interactive_canvas",
  "requiref",
  "__dm_script_instance__"
}
