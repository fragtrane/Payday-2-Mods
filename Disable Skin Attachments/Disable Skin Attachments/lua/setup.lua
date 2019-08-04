--Don't do setup twice
if _G.DSA then
	return
end

--Set up variables
_G.DSA = _G.DSA or {}
DSA._mod_path = ModPath
DSA._save_path = SavePath
DSA._save_name = "dsa_settings.txt"
DSA._settings = {
	dsa_fix_common_uncommon = true,
	dsa_remove_attachments = true,
	dsa_rename_legendary = true,
	dsa_unlock_legendaries = false,
	dsa_remove_unlocked_attachments = false,
	dsa_remove_legendary_stats = false
}
DSA._restart_list = {
	"dsa_fix_common_uncommon",
	"dsa_remove_attachments",
	"dsa_rename_legendary",
	"dsa_unlock_legendaries",
	"dsa_remove_unlocked_attachments",
	"dsa_remove_legendary_stats"
}

--JSON encode helper
function DSA:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function DSA:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function DSA:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function DSA:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Check if settings have been changed
function DSA:restart_required()
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
local save_exists = io.open(DSA._save_path..DSA._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	DSA:load_settings()
else
	DSA:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "dsa_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(DSA._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "dsa_hook_MenuManagerInitialize", function(menu_manager)	
	MenuCallbackHandler.dsa_callback_toggle = function(self, item)
		DSA._settings[item:name()] = item:value() == "on"
	end
	
	MenuCallbackHandler.dsa_callback_save = function(self, item)
		if DSA:restart_required() then
			DSA:ok_menu("dsa_dialog_title", "dsa_dialog_restart_required", false, true)
		end
		DSA:save_settings()
	end
	
	MenuHelper:LoadFromJsonFile(DSA._mod_path.."menu/options.txt", DSA, DSA._settings)
end)

--Shortcut for single-option menu
function DSA:ok_menu(title, desc, callback, localize)
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