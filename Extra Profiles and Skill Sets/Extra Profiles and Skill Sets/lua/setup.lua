--Don't do setup twice
if _G.fragProfiles then
	return
end

_G.fragProfiles = _G.fragProfiles or {}
fragProfiles._mod_path = ModPath
fragProfiles._save_path = SavePath
fragProfiles._save_name = "extraprofiles_settings.txt"
fragProfiles._min_profiles = 15--Number of profiles in base game
fragProfiles._default_profiles = 30
fragProfiles._settings = {
	total_profiles = fragProfiles._default_profiles--Total number of profiles (includes base game profiles)
}
--For confirmation, don't save settings automatically
fragProfiles._deferred_settings = {}

--JSON encode helper
function fragProfiles:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function fragProfiles:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function fragProfiles:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function fragProfiles:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Validate total number of profiles in case minimum is changed
function fragProfiles:validate_total_profiles()
	if self._settings.total_profiles < self._min_profiles then
		self._settings.total_profiles = self._min_profiles
		self:save_settings()
	end
end

--Load settings
local save_exists = io.open(fragProfiles._save_path..fragProfiles._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	fragProfiles:load_settings()
	fragProfiles:validate_total_profiles()
else
	fragProfiles:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "fragProfiles_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(fragProfiles._mod_path.."localizations/english.txt")
	--Default names for skill sets
	--Unused strings when i < num. of skill sets in base game
	--But there is no harm in adding them and it simplifies things since the number of skill sets could change in the future.
	for i=1,fragProfiles._settings.total_profiles do
		local id = "fragProfiles_set_"..tostring(i)
		local str = "Set #"..tostring(i)
		loc:add_localized_strings( {[id] = str} )
	end
end)

Hooks:Add("MenuManagerInitialize", "fragProfiles_hook_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.fragProfiles_callback_slider_discrete = function(self, item)
		fragProfiles._deferred_settings[item:name()] = math.floor(item:value()+0.5)
	end
	
	MenuCallbackHandler.fragProfiles_callback_button = function(self, item)
		if item:name() == "commit_settings" then
			fragProfiles:commit_settings()
		end
	end
	
	MenuHelper:LoadFromJsonFile(fragProfiles._mod_path.."menu/options.txt", fragProfiles, fragProfiles._settings)
end)

--Commit settings button
function fragProfiles:commit_settings()
	--Get current settings from file (in case we saved already but haven't restarted yet)
	local actual_settings = {}
	local path = self._save_path..self._save_name
	self:json_decode(actual_settings, path)
	
	--Get delta
	local num_old_profiles = actual_settings.total_profiles or self._settings.total_profiles
	local num_new_profiles = self._deferred_settings.total_profiles or self._settings.total_profiles
	local delta = num_new_profiles - num_old_profiles
	
	--Build menu message
	local title = managers.localization:text("fragProfiles_dialog_title")
	local message = ""
	
	if delta == 0 then
		--Number of profiles has not been changed.
		message = managers.localization:text("fragProfiles_dialog_unchanged")
		self:ok_menu(title, message, false, false)
		return
	else
		--Print number of profiles
		local macros = {
			profile_chosen = num_new_profiles,
			profile_current = num_old_profiles
		}
		message = message..managers.localization:text("fragProfiles_dialog_number_profiles", macros)
		
		--Inform which profiles will be added/removed
		if delta == 1 or delta == -1 then
			local macros = {
				profile_single = math.min(num_old_profiles + 1, num_new_profiles + 1),
				profile_operation = delta > 0 and "added" or "removed"
			}
			message = message.."\n\n"..managers.localization:text("fragProfiles_dialog_add_remove_single", macros)
		else
			local macros = {
				profile_min = math.min(num_old_profiles + 1, num_new_profiles + 1),
				profile_max = math.max(num_old_profiles, num_new_profiles),
				profile_operation = delta > 0 and "added" or "removed"
			}
			message = message.."\n\n"..managers.localization:text("fragProfiles_dialog_add_remove_multiple", macros)
		end
		
		--Warn if profiles will be removed
		if delta < 0 then
			message = message.."\n\n"..managers.localization:text("fragProfiles_dialog_warn_remove")
		end
		
		--Ask to continue
		message = message.."\n\n"..managers.localization:text("fragProfiles_dialog_ask_continue")
	end
	
	--Show menu
	local options = {
		[1] = {
			text = managers.localization:text("dialog_yes"),
			callback = callback(self, self, "save_deferred_settings")
		},
		[2] = {
			text = managers.localization:text("dialog_no"),
			is_cancel_button = true
		}
	}
	local menu = QuickMenu:new(title, message, options)
	menu:Show()
end

--Write deferred settings
function fragProfiles:save_deferred_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._deferred_settings, path)
	self:ok_menu("fragProfiles_dialog_title", "fragProfiles_dialog_saved", false, true)
end

--Shortcut for single-option menu
function fragProfiles:ok_menu(title, desc, callback, localize)
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
