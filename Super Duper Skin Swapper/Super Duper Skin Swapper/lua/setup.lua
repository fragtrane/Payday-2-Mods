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
	sdss_hide_unowned = true,--Hide skins that you don't own
	sdss_clean_dupes = 1,--Hide duplicates
	sdss_allow_variants = false,--Allow legendary attachments on akimbo/single variants
	sdss_remove_stats = false,--Remove stats from legendary attachments
	
	sdss_immortal_python = false,--Set default weapon color to Immortal Python
	sdss_paint_scheme = 1,--Override default paint scheme of weapon colors
	sdss_color_wear = 1,--Override default wear of weapon colors
	sdss_pattern_scale = 1,--Override default pattern scale of weapon colors
	
	--NEW 2.1
	sdss_preview_wear = true,--Choose wear in previews
	sdss_page_number_scaling = true,--Scale the page number step so it doesn't get cut off
	
	sdss_edit_filters = false,--Beta, requires manually re-opening weapon customization menu
	sdss_persist_filters = false,--Save the state of the filter
	sdss_filter = 1--Default filter setting, internal use only
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
--Edited to deal with persist filters
function SDSS:save_settings()
	--If not edit filters, reset
	--Not persist is okay because it will get reset after session. We don't want to reset the filters mid-session.
	if not self._settings.sdss_edit_filters then
		self._settings.sdss_filter = 1
	end
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
--Edited to deal with persist filters
function SDSS:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
	--If not persist filters, reset filters.
	--Also reset if filters are not enabled.
	if not self._settings.sdss_persist_filters or not self._settings.sdss_edit_filters then
		self._settings.sdss_filter = 1
	end
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
	elseif multi_id == "sdss_color_wear" then
		if self._settings[multi_id] == 1 then
			return "off"
		elseif self._settings[multi_id] == 2 then
			return "mint"--Mint-Condition
		elseif self._settings[multi_id] == 3 then
			return "fine"--Lightly-Marked
		elseif self._settings[multi_id] == 4 then
			return "good"--Broken-In
		elseif self._settings[multi_id] == 5 then
			return "fair"--Well-Used
		elseif self._settings[multi_id] == 6 then
			return "poor"--Battle-Worn
		end
	elseif multi_id == "sdss_filter" then
		if self._settings[multi_id] == 1 then
			return "preset_all"--All skins
		elseif self._settings[multi_id] == 2 then
			return "preset_cat"--Same category
		elseif self._settings[multi_id] == 3 then
			return "preset_var"--Single/akimbo variants. Also normal/Golden AK.762.
		elseif self._settings[multi_id] == 4 then
			return "preset_off"--Correct weapon only
		end
	end
end

--Set filter settings
function SDSS:filter_button_handler()
	local menu_title = managers.localization:text("sdss_dialog_title")
	--Choose a filter for which skins to show.
	local menu_message = managers.localization:text("sdss_dialog_filter_prompt")
	--Your current filter setting
	local current_string_id = "sdss_dialog_filter_" .. self:get_multi_name("sdss_filter")
	local current_string = managers.localization:text(current_string_id)
	menu_message = menu_message .. " " .. managers.localization:text("sdss_dialog_filter_current", {current_string = current_string})
	--Beta warning
	menu_message = menu_message .. "\n\n" .. managers.localization:text("sdss_dialog_filter_beta_warning")
	
	--TODO: figure out how to refresh properly
	local menu_options = {
		[1] = {
			text = managers.localization:text("sdss_dialog_filter_preset_all"),
			callback = function()
				SDSS._settings.sdss_filter = 1
				if SDSS._settings.sdss_persist_filters then
					SDSS:save_settings()
				end
				managers.menu:back(true)
			end
		},
		[2] = {
			text = managers.localization:text("sdss_dialog_filter_preset_cat"),
			callback = function()
				SDSS._settings.sdss_filter = 2
				if SDSS._settings.sdss_persist_filters then
					SDSS:save_settings()
				end
				managers.menu:back(true)
			end
		},
		[3] = {
			text = managers.localization:text("sdss_dialog_filter_preset_var"),
			callback = function()
				SDSS._settings.sdss_filter = 3
				if SDSS._settings.sdss_persist_filters then
					SDSS:save_settings()
				end
				managers.menu:back(true)
			end
		},
		[4] = {
			text = managers.localization:text("sdss_dialog_filter_preset_off"),
			callback = function()
				SDSS._settings.sdss_filter = 4
				if SDSS._settings.sdss_persist_filters then
					SDSS:save_settings()
				end
				managers.menu:back(true)
			end
		},
		[5] = {
			text = managers.localization:text("dialog_cancel"),
			is_cancel_button = true
		}
	}
	
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Wear preview, mostly stolen from OSA
function SDSS:weapon_wear_handler(data)
	--Show "Real Wear" tag if not a color and the skin is owned
	local real_quality = not data.is_a_color_skin and data.unlocked and data.cosmetic_quality
	--Wear menu
	local menu_title = managers.localization:text("sdss_dialog_title")
	local menu_message = managers.localization:text("sdss_dialog_choose_quality")
	local menu_options = {
		[1] = {
			text = managers.localization:text("bm_menu_quality_mint") .. (real_quality == "mint" and " (".. managers.localization:text("sdss_dialog_real_quality") .. ")" or ""),
			callback = function()
				data.cosmetic_quality = "mint"
				self._state.yes_clbk()
			end
		},
		[2] = {
			text = managers.localization:text("bm_menu_quality_fine") .. (real_quality == "fine" and " (".. managers.localization:text("sdss_dialog_real_quality") .. ")" or ""),
			callback = function()
				data.cosmetic_quality = "fine"
				self._state.yes_clbk()
			end
		},
		[3] = {
			text = managers.localization:text("bm_menu_quality_good") .. (real_quality == "good" and " (".. managers.localization:text("sdss_dialog_real_quality") .. ")" or ""),
			callback = function()
				data.cosmetic_quality = "good"
				self._state.yes_clbk()
			end
		},
		[4] = {
			text = managers.localization:text("bm_menu_quality_fair") .. (real_quality == "fair" and " (".. managers.localization:text("sdss_dialog_real_quality") .. ")" or ""),
			callback = function()
				data.cosmetic_quality = "fair"
				self._state.yes_clbk()
			end
		},
		[5] = {
			text = managers.localization:text("bm_menu_quality_poor") .. (real_quality == "poor" and " (".. managers.localization:text("sdss_dialog_real_quality") .. ")" or ""),
			callback = function()
				data.cosmetic_quality = "poor"
				self._state.yes_clbk()
			end
		},
		[6] = {
			text = managers.localization:text("dialog_cancel"),
			callback = function()
				self._state = nil
			end,
			is_cancel_button = true
		}
	}
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end
