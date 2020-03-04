--Don't do setup twice
if _G.IOF then
	return
end

--Set up variables
_G.IOF = _G.IOF or {}
IOF._mod_path = ModPath
IOF._save_path = SavePath
IOF._save_name = "iof_settings.txt"
IOF._settings = {
	iof_community = true,--Enable community/achievement content
	iof_inventory = true,--Block inventory update so skins don't get removed
	iof_filters = true,--Enable Crime.net filters
	iof_chat = true,--Enable chat
	iof_no_interrupt = true,--Don't interrupt interaction
	iof_armor = false,--Disable armor regen bonus
	iof_winters = false--Enable Winters
}
IOF._restart_list = {
	"iof_community",
	"iof_filters",
	"iof_armor"
}
--State of community groups/achievements
IOF._state = {
	pd2_clan = false,--Payday 2 Community
	dbd_clan = false,--Dead by Daylight Community
	solus_clan = false,--The Solus Project Community
	raidww2_clan = false--Raid: World War II Community
}
dofile(IOF._mod_path.."lua/achievement_list.lua")

--JSON encode helper
function IOF:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function IOF:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function IOF:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function IOF:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--For saving state of community content/achievements
--Tied to Steam ID so state can be tracked for different accounts
function IOF:save_user_state()
	local path = self._save_path.."iof_"..tostring(Steam:userid())..".txt"
	self:json_encode(self._state, path)
end

--For loading state of community content/achievements
--Tied to Steam ID so state can be tracked for different accounts
function IOF:load_user_state()
	local path = self._save_path.."iof_"..tostring(Steam:userid())..".txt"
	self:json_decode(self._state, path)
end

--Check if settings have been changed
function IOF:restart_required()
	local old_settings = {}
	self:json_decode(old_settings, self._save_path..self._save_name)
	for _, k in pairs(self._restart_list) do
		if self._settings[k] ~= old_settings[k] then
			return true
		end
	end
	return false
end

--Load settings
local save_exists = io.open(IOF._save_path..IOF._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	IOF:load_settings()
else
	IOF:save_settings()
end

--Load state
--Also loads when online, use to prevent locked outfit bug
local state_exists = io.open(IOF._save_path.."iof_"..tostring(Steam:userid())..".txt", "r")
if state_exists ~= nil then
	state_exists:close()
	IOF:load_user_state()
else
	IOF:save_user_state()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "iof_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(IOF._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "iof_hook_MenuManagerInitialize", function(menu_manager)	
	MenuCallbackHandler.iof_callback_toggle = function(self, item)
		IOF._settings[item:name()] = item:value() == "on"
	end
	
	MenuCallbackHandler.iof_callback_save = function(self, item)
		if IOF:restart_required() then
			IOF:ok_menu("iof_dialog_title", "iof_dialog_restart_required", false, true)
		end
		IOF:save_settings()
	end
	
	MenuHelper:LoadFromJsonFile(IOF._mod_path.."menu/options.txt", IOF, IOF._settings)
end)

--Shortcut for single-option menu
function IOF:ok_menu(title, desc, callback, localize)
	local menu_title = not localize and title or managers.localization:text(title)
	local menu_message = not localize and desc or managers.localization:text(desc)
	local menu_options = {}
	if not callback then
		menu_options = {
			[1] = {
				text = managers.localization:text("dialog_ok"),
				is_cancel_button = true
			}
		}
	else
		menu_options = {
			[1] = {
				text = managers.localization:text("dialog_ok"),
				callback = callback
			}
		}
	end
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end
