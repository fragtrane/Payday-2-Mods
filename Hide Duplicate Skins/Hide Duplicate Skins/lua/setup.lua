--Don't do setup twice
if _G.HideDupeSkins then
	return
end

--Set up variables
_G.HideDupeSkins = _G.HideDupeSkins or {}
HideDupeSkins._mod_path = ModPath
HideDupeSkins._save_path = SavePath
HideDupeSkins._save_name = "hds_settings.txt"
HideDupeSkins._settings = {
	hds_clean_dupes = 1--Hide duplicates
}

--JSON encode helper
function HideDupeSkins:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function HideDupeSkins:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function HideDupeSkins:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function HideDupeSkins:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Load settings
local save_exists = io.open(HideDupeSkins._save_path..HideDupeSkins._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	HideDupeSkins:load_settings()
else
	HideDupeSkins:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "hds_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(HideDupeSkins._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "hds_hook_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.hds_callback_multi = function(self, item)
		HideDupeSkins._settings[item:name()] = item:value()
	end
	
	MenuCallbackHandler.hds_callback_save = function(self, item)
		HideDupeSkins:save_settings()
		--Set visible skins when leaving options menu
		managers.blackmarket:set_visible_cosmetics()
	end
	
	MenuHelper:LoadFromJsonFile(HideDupeSkins._mod_path.."menu/options.txt", HideDupeSkins, HideDupeSkins._settings)
end)

--Map indexes to names for multiple choice settings
function HideDupeSkins:get_multi_name(multi_id)
	if multi_id == "hds_clean_dupes" then
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
