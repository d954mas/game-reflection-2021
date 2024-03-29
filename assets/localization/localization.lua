local I18N = require "libs.i18n.init"
local LOG = require "libs.log"
local TAG = "LOCALIZATION"
local LOCALES = { "en", "ru" }
local DEFAULT = "en"
local FALLBACK = "en"

---@class Localization
local M = {
	btnPlay = { en = "Play", ru = "Играть" },
}

function M:locale_exist(key)
	local locale = self[key]
	if not locale then
		LOG.w("key:" .. key .. " not found", TAG,2)
	end
end

function M:set_locale(locale)
	I18N.setLocale(locale)
end

I18N.setFallbackLocale(FALLBACK)
I18N.setLocale(DEFAULT)

for _, locale in ipairs(LOCALES) do
	local table = {}
	for k, v in pairs(M) do
		if type(v) ~= "function" then
			table[k] = v[locale]
		end
	end
	I18N.load({ [locale] = table })
end

for k, v in pairs(M) do
	if type(v) ~= "function" then
		M[k] = function(data)
			return I18N(k, data)
		end
	end
end

--return key if value not founded
local t = setmetatable({ __VALUE = M, }, {
	__index = function(_, k)
		local result = M[k]
		if not result then
			LOG.w("no key:" .. k, TAG,2)
			result = function() return k end
			M[k] = result
		end
		return result
	end,
	__newindex = function() error("table is readonly", 2) end,
})


return t
