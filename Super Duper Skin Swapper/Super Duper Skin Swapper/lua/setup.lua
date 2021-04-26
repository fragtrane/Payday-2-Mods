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
	sdss_clean_dupes = 4,--Hide duplicates
	sdss_enable_filters = true,--Added in 2.2: new enable filters setting
	sdss_persist_filters = false,--Added in 2.1: Save filter settings
	sdss_page_number_scaling = true,--Added in 2.1: Scale the page number step so it doesn't get cut off
	sdss_page_buttons_max = 35,--Added in 2.2: new maximum page buttons setting
	
	sdss_allow_variants = true,--Allow legendary attachments on akimbo/single variants
	sdss_remove_stats = false,--Remove stats from legendary attachments
	
	sdss_immortal_python = false,--Set default weapon color to Immortal Python
	sdss_paint_scheme = 1,--Override default paint scheme of weapon colors
	sdss_color_wear = 1,--Override default wear of weapon colors
	sdss_pattern_scale = 1,--Override default pattern scale of weapon colors
	
	sdss_fast_preview = false,--Added in 2.2: Double click always opens preview
	sdss_preview_wear = true--Added in 2.1: Choose wear in previews
}
SDSS._default_filters = {
	sdss_hide_unowned = false,--Hide unowned skins
	
	sdss_filter_safe = "off",--Show skins from a specific safe
	
	sdss_filter_rarity = 1,--Show skins which are at least a certain rarity.
	sdss_filter_rarity_exact = false,--Only show skins which exactly match the rarity.
	
	--Filter > 1 is on. 7-quality = index used by dupe hiding.
	sdss_filter_quality = 1,--Show skins which are at least a certain quality.
	sdss_filter_quality_exact = false,--Only show skins which exactly match the quality.
	
	sdss_filter_weapon = 1--Weapon filter presets
}
--Set default filters function
function SDSS:set_default_filters()
	for k, v in pairs(self._default_filters) do
		self._settings[k] = v
	end
end
--Write default filters to settings
SDSS:set_default_filters()

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
--Edited to deal with persist filters
function SDSS:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
	--Reset filter settings if persist not enabled
	if not self._settings.sdss_persist_filters or not self._settings.sdss_enable_filters then
		self:set_default_filters()
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
	
	MenuCallbackHandler.sdss_callback_slider_discrete = function(self, item)
		SDSS._settings[item:name()] = math.floor(item:value()+0.5)
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
	elseif multi_id == "sdss_filter_weapon" then
		if self._settings[multi_id] == 1 then
			return "preset_any"--Any weapon
		elseif self._settings[multi_id] == 2 then
			return "preset_cat"--Same category
		elseif self._settings[multi_id] == 3 then
			return "preset_fam"--Same family or variant.
		elseif self._settings[multi_id] == 4 then
			return "preset_var"--Single/akimbo variants. Also normal/Golden AK.762.
		elseif self._settings[multi_id] == 5 then
			return "preset_cor"--Correct weapon only
		end
	end
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

--Filter Button Handler
function SDSS:generic_filter_button_handler(child_name)
	if child_name == "sdss_filter_button_reset" then
		self:_reset_filter_button_handler()
		return
	elseif child_name == "sdss_filter_button_unowned" then
		self:_unowned_filter_button_handler()
		return
	elseif child_name == "sdss_filter_button_safe" then
		self:_safe_filter_button_handler()
		return
	elseif child_name == "sdss_filter_button_rarity" then
		self:_rarity_filter_button_handler()
		return
	elseif child_name == "sdss_filter_button_quality" then
		self:_quality_filter_button_handler()
		return
	elseif child_name == "sdss_filter_button_weapon" then
		self:_weapon_filter_button_handler()
		return
	end
	
	--Debug message
	local menu = QuickMenu:new("Not Implemented", child_name, {})
	menu:Show()
end

--Save settings and go back
--Maybe try to see if we can actually find a way to refresh without going back
function SDSS:apply_filter_settings()
	self:save_settings()
	managers.menu:back(true)
end

--Reset, easy
function SDSS:_reset_filter_button_handler()
	local menu_title = managers.localization:text("sdss_dialog_title")
	local menu_message = "Are you sure you want to reset your filter settings?"
	local menu_options = {
		[1] = {
			text = managers.localization:text("dialog_yes"),
			callback = function()
				self:set_default_filters()
				self:apply_filter_settings()
			end
		},
		[2] = {
			text = managers.localization:text("dialog_no"),
			is_cancel_button = true
		}
	}
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Toggle hide, easy
function SDSS:_unowned_filter_button_handler()
	local menu_title = managers.localization:text("sdss_dialog_title")
	local menu_message
	if self._settings.sdss_hide_unowned then
		menu_message = "Are you sure you want to show unowned skins?"
	else
		menu_message = "Are you sure you want to hide unowned skins?"
	end
	local menu_options = {
		[1] = {
			text = managers.localization:text("dialog_yes"),
			callback = function()
				self._settings.sdss_hide_unowned = not self._settings.sdss_hide_unowned
				self:apply_filter_settings()
			end
		},
		[2] = {
			text = managers.localization:text("dialog_no"),
			is_cancel_button = true
		}
	}
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Quality handler
function SDSS:_quality_filter_button_handler()
	local menu_title = managers.localization:text("sdss_dialog_title")
	local menu_message
	
	--Mode Name
	local mode_name
	if self._settings.sdss_filter_quality_exact then
		mode_name = "Show Only"
	else
		mode_name = "At Least"
	end
	
	--Filter Name
	local filter_name
	if self._settings.sdss_filter_quality == 1 then
		filter_name = "Any Wear"
	elseif self._settings.sdss_filter_quality == 2 then
		filter_name = managers.localization:text("bm_menu_quality_mint")
	elseif self._settings.sdss_filter_quality == 3 then
		filter_name = managers.localization:text("bm_menu_quality_fine")
	elseif self._settings.sdss_filter_quality == 4 then
		filter_name = managers.localization:text("bm_menu_quality_good")
	elseif self._settings.sdss_filter_quality == 5 then
		filter_name = managers.localization:text("bm_menu_quality_fair")
	elseif self._settings.sdss_filter_quality == 6 then
		filter_name = managers.localization:text("bm_menu_quality_poor")
	end
	
	if self._settings.sdss_filter_quality == 1 then
		menu_message = managers.localization:text("sdss_dialog_filter_quality", {quality = filter_name})
	else
		menu_message = managers.localization:text("sdss_dialog_filter_quality_2", {quality = filter_name, mode = mode_name})
	end
	
	local menu_options = {
		[1] = {
			text = "Any Wear",
			callback = function()
				self:_quality_filter_button_handler_final(1)
			end
		},
		[2] = {
			text = managers.localization:text("bm_menu_quality_mint"),
			callback = function()
				self:_quality_filter_button_handler_final(2)
			end
		},
		[3] = {
			text = managers.localization:text("bm_menu_quality_fine"),
			callback = function()
				self:_quality_filter_button_handler_final(3)
			end
		},
		[4] = {
			text = managers.localization:text("bm_menu_quality_good"),
			callback = function()
				self:_quality_filter_button_handler_final(4)
			end
		},
		[5] = {
			text = managers.localization:text("bm_menu_quality_fair"),
			callback = function()
				self:_quality_filter_button_handler_final(5)
			end
		},
		[6] = {
			text = managers.localization:text("bm_menu_quality_poor"),
			callback = function()
				self:_quality_filter_button_handler_final(6)
			end
		},
		[7] = {
			text = managers.localization:text("dialog_cancel"),
			is_cancel_button = true
		}
	}
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Quality handler mode
function SDSS:_quality_filter_button_handler_final(index)
	--Index 1 is any quality, don't need to ask for exact filter
	if index <= 2 then
		self._settings.sdss_filter_quality = index
		--Exact match is false for "Any Quality" setting (technically doesn't matter because it isn't used.
		if index == 1 then
			self._settings.sdss_filter_quality_exact = false
		else
			--For Mint-Condition, we can't go any higher so it's always an exact match.
			self._settings.sdss_filter_quality_exact = true
		end
		self:apply_filter_settings()
		return
	end
	
	local menu_title = managers.localization:text("sdss_dialog_title")
	local menu_message = managers.localization:text("sdss_dialog_filter_quality_mode")
	local menu_options = {
		[1] = {
			text = "Also Show Higher Qualities",
			callback = function()
				self._settings.sdss_filter_quality = index
				self._settings.sdss_filter_quality_exact = false
				self:apply_filter_settings()
			end
		},
		[2] = {
			text = "Only Show Chosen Quality",
			callback = function()
				self._settings.sdss_filter_quality = index
				self._settings.sdss_filter_quality_exact = true
				self:apply_filter_settings()
			end
		},
		[3] = {
			text = "Go Back",
			callback = function()
				self:_quality_filter_button_handler()
			end,
			is_cancel_button = true
		}
	}
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

function SDSS:_rarity_filter_button_handler()
	local menu_title = managers.localization:text("sdss_dialog_title")
	local menu_message
	
	--Mode Name
	local mode_name
	if self._settings.sdss_filter_rarity_exact then
		mode_name = "Show Only"
	else
		mode_name = "At Least"
	end
	
	--Filter Name
	local filter_name
	if self._settings.sdss_filter_rarity == 1 then
		filter_name = "Any Rarity"
	elseif self._settings.sdss_filter_rarity == 2 then
		filter_name = managers.localization:text("bm_menu_rarity_legendary")
	elseif self._settings.sdss_filter_rarity == 3 then
		filter_name = managers.localization:text("bm_menu_rarity_epic")
	elseif self._settings.sdss_filter_rarity == 4 then
		filter_name = managers.localization:text("bm_menu_rarity_rare")
	elseif self._settings.sdss_filter_rarity == 5 then
		filter_name = managers.localization:text("bm_menu_rarity_uncommon")
	elseif self._settings.sdss_filter_rarity == 6 then
		filter_name = managers.localization:text("bm_menu_rarity_common")
	end
	
	if self._settings.sdss_filter_rarity == 1 then
		menu_message = managers.localization:text("sdss_dialog_filter_rarity", {rarity = filter_name})
	else
		menu_message = managers.localization:text("sdss_dialog_filter_rarity_2", {rarity = filter_name, mode = mode_name})
	end
	
	local menu_options = {
		[1] = {
			text = "Any Rarity",
			callback = function()
				self:_rarity_filter_button_handler_final(1)
			end
		},
		[2] = {
			text = managers.localization:text("bm_menu_rarity_legendary"),
			callback = function()
				self:_rarity_filter_button_handler_final(2)
			end
		},
		[3] = {
			text = managers.localization:text("bm_menu_rarity_epic"),
			callback = function()
				self:_rarity_filter_button_handler_final(3)
			end
		},
		[4] = {
			text = managers.localization:text("bm_menu_rarity_rare"),
			callback = function()
				self:_rarity_filter_button_handler_final(4)
			end
		},
		[5] = {
			text = managers.localization:text("bm_menu_rarity_uncommon"),
			callback = function()
				self:_rarity_filter_button_handler_final(5)
			end
		},
		[6] = {
			text = managers.localization:text("bm_menu_rarity_common"),
			callback = function()
				self:_rarity_filter_button_handler_final(6)
			end
		},
		[7] = {
			text = managers.localization:text("dialog_cancel"),
			is_cancel_button = true
		}
	}
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

function SDSS:_rarity_filter_button_handler_final(index)
	--Index 1 is any rarity, don't need to ask for exact filter
	if index <= 2 then
		self._settings.sdss_filter_rarity = index
		--Exact match is false for "Any Rarity" setting (technically doesn't matter because it isn't used.
		if index == 1 then
			self._settings.sdss_filter_rarity_exact = false
		else
			--For Legendary, we can't go any higher so it's always an exact match.
			self._settings.sdss_filter_rarity_exact = true
		end
		self:apply_filter_settings()
		return
	end
	
	local menu_title = managers.localization:text("sdss_dialog_title")
	local menu_message = managers.localization:text("sdss_dialog_filter_rarity_mode")
	local menu_options = {
		[1] = {
			text = "Also Show Higher Rarities",
			callback = function()
				self._settings.sdss_filter_rarity = index
				self._settings.sdss_filter_rarity_exact = false
				self:apply_filter_settings()
			end
		},
		[2] = {
			text = "Only Show Chosen Rarity",
			callback = function()
				self._settings.sdss_filter_rarity = index
				self._settings.sdss_filter_rarity_exact = true
				self:apply_filter_settings()
			end
		},
		[3] = {
			text = "Go Back",
			callback = function()
				self:_rarity_filter_button_handler()
			end,
			is_cancel_button = true
		}
	}
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Safe filter handler
function SDSS:_safe_filter_button_handler(offset)
	--Sort safe names and make map from name to ID
	local safe_names = {}
	local name_map = {}
	for safe_id, _ in pairs(self._safe_data) do
		local name_id = tweak_data.economy.safes[safe_id].name_id
		local name = managers.localization:text(name_id)
		table.insert(safe_names, name)
		name_map[name] = safe_id
	end
	table.sort(safe_names)
	
	--Insert "Any Safe" as first entry
	local off_name = "Any Safe"
	table.insert(safe_names, 1, off_name)
	name_map[off_name] = "off"
	
	--Menu message
	local menu_title = managers.localization:text("sdss_dialog_title")
	local current_safe
	for name, id in pairs(name_map) do
		if id == self._settings.sdss_filter_safe then
			current_safe = name
			break
		end
	end
	local menu_message = managers.localization:text("sdss_dialog_filter_safe", {safe = current_safe})
	
	--Build menu options
	local items_per_page = 10
	local max_offset = math.ceil(#safe_names/items_per_page) - 1
	
	--Handle offset
	offset = offset or 0
	--Indexes are inclusive
	local start_index = 1 + items_per_page*offset
	local end_index = start_index + items_per_page - 1
	
	local menu_options = {}
	local count = 1
	for i, name in ipairs(safe_names) do
		if i >= start_index and i <= end_index then
			menu_options[count] = {
				text = name,
				callback = function()
					local safe_id = name_map[name]
					self._settings.sdss_filter_safe = safe_id
					self:apply_filter_settings()
				end
			}
			count = count + 1
		end
	end
	--Previous Page
	if offset > 0 then
		menu_options[count] = {
			text = "[Previous Page]",
			callback = function()
				self:_safe_filter_button_handler(offset - 1)
			end
		}
		count = count + 1
	end
	--Next Page
	if offset < max_offset then
		menu_options[count] = {
			text = "[Next Page]",
			callback = function()
				self:_safe_filter_button_handler(offset + 1)
			end
		}
		count = count + 1
	end
	--Cancel Button
	menu_options[count] = {
		text = managers.localization:text("dialog_cancel"),
		is_cancel_button = true
	}
	
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Weapon Filter
function SDSS:_weapon_filter_button_handler()
	local menu_title = managers.localization:text("sdss_dialog_title")
	
	local mode_id = "sdss_dialog_filter_" .. self:get_multi_name("sdss_filter_weapon")
	local mode_name = managers.localization:text(mode_id)
	local menu_message = managers.localization:text("sdss_dialog_filter_weapon", {mode = mode_name})
	
	local menu_options = {
		[1] = {
			text = managers.localization:text("sdss_dialog_filter_preset_any"),
			callback = function()
				self._settings.sdss_filter_weapon = 1
				self:apply_filter_settings()
			end
		},
		[2] = {
			text = managers.localization:text("sdss_dialog_filter_preset_cat"),
			callback = function()
				self._settings.sdss_filter_weapon = 2
				self:apply_filter_settings()
			end
		},
		[3] = {
			text = managers.localization:text("sdss_dialog_filter_preset_fam"),
			callback = function()
				self._settings.sdss_filter_weapon = 3
				self:apply_filter_settings()
			end
		},
		[4] = {
			text = managers.localization:text("sdss_dialog_filter_preset_var"),
			callback = function()
				self._settings.sdss_filter_weapon = 4
				self:apply_filter_settings()
			end
		},
		[5] = {
			text = managers.localization:text("sdss_dialog_filter_preset_cor"),
			callback = function()
				self._settings.sdss_filter_weapon = 5
				self:apply_filter_settings()
			end
		},
		[6] = {
			text = managers.localization:text("dialog_cancel"),
			is_cancel_button = true
		}
	}
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end
