--Don't do setup twice
if _G.RevertTitanCams then
	return
end

--Set up variables
_G.RevertTitanCams = _G.RevertTitanCams or {}
RevertTitanCams._mod_path = ModPath
RevertTitanCams._save_path = SavePath
RevertTitanCams._save_name = "rtc_settings.txt"
RevertTitanCams._settings = {
	rtc_big = true,--Big Bank
	rtc_four_stores = true,--Four Stores
	rtc_welcome_to_the_jungle_1 = true,--Big Oil Day 1
	rtc_family = true--Diamond Store
}

--JSON encode helper
function RevertTitanCams:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function RevertTitanCams:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function RevertTitanCams:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function RevertTitanCams:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Load settings
local save_exists = io.open(RevertTitanCams._save_path..RevertTitanCams._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	RevertTitanCams:load_settings()
else
	RevertTitanCams:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "rtc_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(RevertTitanCams._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "rtc_hook_MenuManagerInitialize", function(menu_manager)	
	MenuCallbackHandler.rtc_callback_toggle = function(self, item)
		RevertTitanCams._settings[item:name()] = item:value() == "on"
	end
	
	MenuCallbackHandler.rtc_callback_save = function(self, item)
		RevertTitanCams:save_settings()
	end
	
	MenuHelper:LoadFromJsonFile(RevertTitanCams._mod_path.."menu/options.txt", RevertTitanCams, RevertTitanCams._settings)
end)
