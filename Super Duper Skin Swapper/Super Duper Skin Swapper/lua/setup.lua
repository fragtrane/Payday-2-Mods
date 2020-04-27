--Don't do setup twice
if _G.SDSS then
	return
end

--Set up variables
_G.SDSS = _G.SDSS or {}
SDSS._mod_path = ModPath
SDSS._save_path = SavePath
SDSS._save_name = "sdss_settings.txt"
SDSS._settings = {
	sdss_enabled = true,--Enable/disable skin swapping
	sdss_allow_beardlib = true,--Allow non-universal BeardLib skins to be used on any weapon
	sdss_hide_unowned = true,--Hide skins that you don't own
	sdss_allow_variants = false,--Allow legendary attachments on akimbo/single variants
	sdss_remove_stats = false,--Remove stats from legendary attachments
	sdss_clean_dupes = 1--Hide duplicates
}
--Load skin data
dofile(SDSS._mod_path.."lua/extra_skin_data.lua")

--JSON encode helper
function SDSS:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function SDSS:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function SDSS:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function SDSS:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Load settings
local save_exists = io.open(SDSS._save_path..SDSS._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	SDSS:load_settings()
else
	SDSS:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "sdss_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(SDSS._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "sdss_hook_MenuManagerInitialize", function(menu_manager)	
	MenuCallbackHandler.sdss_callback_toggle = function(self, item)
		SDSS._settings[item:name()] = item:value() == "on"
	end
		
	MenuCallbackHandler.sdss_callback_multi = function(self, item)
		SDSS._settings[item:name()] = item:value()
	end
	
	MenuCallbackHandler.sdss_callback_save = function(self, item)
		SDSS:save_settings()
		--Set visible skins when leaving options menu
		managers.blackmarket:set_visible_cosmetics()
	end
	
	MenuHelper:LoadFromJsonFile(SDSS._mod_path.."menu/options.txt", SDSS, SDSS._settings)
end)

--Map indexes to names for multiple choice settings
function SDSS:get_multi_name(multi_id)
	if multi_id == "sdss_clean_dupes" then
		if self._settings[multi_id] == 1 then
			return "off"
		elseif self._settings[multi_id] == 2 then
			return "bonus"--Prefer stat boost
		elseif self._settings[multi_id] == 3 then
			return "quality"--Prefer quality
		elseif self._settings[multi_id] == 4 then
			return "both"--Best stat and non-stat
		elseif self._settings[multi_id] == 5 then
			return "allvars"--Show all combinations of boost + wear
		end
	end
end
