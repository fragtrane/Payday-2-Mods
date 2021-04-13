--Don't do setup twice
if _G.OSA then
	return
end

--Set up variables
_G.OSA = _G.OSA or {}
OSA._mod_path = ModPath
OSA._save_path = SavePath
OSA._save_name = "osa_settings.txt"
OSA._settings = {
	osa_autobuy = false,--Automatically buy missing parts.
	osa_autobuy_threshold = 50,--Do not let coins drop below this threshold when autobuying.
	osa_prefer_sp_buck = true,--Prefer Gage Shotgun Pack 000 Buckshot if available.
	
	osa_preview = true,--Choose attachments in previews.
	osa_preview_wear = true,--Choose wear in previews
	
	osa_rename_legendary = true,--Allow legendary weapons to be renamed.
	osa_allow_unlock = false,--Allow legendary weapons to be unlocked.
	osa_remove_stats = false,--Remove stats from legendary attachments.
	osa_show_legendary = 1,--Show legendary parts in weapon mod menu. 1 = "off", 2 = "owned", 3 = "all".

	osa_immortal_python = false,--Set default weapon color to Immortal Python
	osa_paint_scheme = 1,--Override default paint scheme of weapon colors
	osa_color_wear = 1,--Override default wear of weapon colors
	osa_pattern_scale = 1--Override default pattern scale of weapon colors
}
OSA._restart_list = {
	"osa_rename_legendary",
	"osa_remove_stats",
	"osa_immortal_python"
}
--Flag for deferring BlackMarketManager:_on_modified_weapon. We need this so that we don't get crashes when keeping attachments.
OSA._skip_omw = false
--Load data for first generation legendary skins
dofile(OSA._mod_path.."lua/gen_1_data.lua")

--JSON encode helper
function OSA:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function OSA:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function OSA:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function OSA:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Check if settings have been changed
function OSA:restart_required()
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
local save_exists = io.open(OSA._save_path..OSA._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	OSA:load_settings()
else
	OSA:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "osa_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(OSA._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "osa_hook_MenuManagerInitialize", function(menu_manager)	
	MenuCallbackHandler.osa_callback_toggle = function(self, item)
		OSA._settings[item:name()] = item:value() == "on"
	end
		
	MenuCallbackHandler.osa_callback_multi = function(self, item)
		OSA._settings[item:name()] = item:value()
	end
	
	MenuCallbackHandler.osa_callback_slider_discrete = function(self, item)
		OSA._settings[item:name()] = math.floor(item:value()+0.5)
	end
	
	MenuCallbackHandler.osa_callback_save = function(self, item)
		if OSA:restart_required() then
			OSA:ok_menu("osa_dialog_title", "osa_dialog_restart_required", false, true)
		end
		OSA:save_settings()
		--Do a Steam inventory refresh, the OSA hook will then set the new legendary attachments
		if Steam:logged_on() then
			Steam:inventory_load(callback(managers.network.account, NetworkAccountSTEAM, "_clbk_inventory_load"))
		end
	end
	
	MenuHelper:LoadFromJsonFile(OSA._mod_path.."menu/options.txt", OSA, OSA._settings)
end)

--Map indexes to names for multiple choice settings
function OSA:get_multi_name(multi_id)
	if multi_id == "osa_show_legendary" then
		if self._settings[multi_id] == 1 then
			return "off"
		elseif self._settings[multi_id] == 2 then
			return "owned"
		elseif self._settings[multi_id] == 3 then
			return "all"
		end
	elseif multi_id == "osa_color_wear" then
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
	end
end

--Shortcut for single-option menu
function OSA:ok_menu(title, desc, callback, localize)
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

--v3.0
--We let BlackMarketGui:_weapon_cosmetics_callback build the params for us
--The we hijack the confirm dialog and call our own
function OSA:weapon_cosmetics_handler(params)
	--Initialize this so we can save options
	self._state.options = {}
	
	--Make our life easier
	local data = self._state.data
	local add = self._state.add
	
	--Check if the skin has the "osa_no_attachments" and set item_has_default_blueprint to false if it does
	--Do the checks the way they do in BlackMarketGui:_weapon_cosmetics_callback()
	if add and params.item_has_default_blueprint then
		local cosmetic_id = data.equip_weapon_cosmetics and data.equip_weapon_cosmetics.entry
		cosmetic_id = cosmetic_id or data.cosmetic_id
		
		local skins_tweak = tweak_data.blackmarket.weapon_skins
		if skins_tweak[cosmetic_id] and skins_tweak[cosmetic_id].osa_no_attachments then
			params.item_has_default_blueprint = false
		end
	end
	
	--Build menu
	local menu_title = managers.localization:text("osa_dialog_title")
	
	--[Slot XX] Weapon Name
	--This is fucking useless maybe we should just get rid of it.
	--[[local menu_message = managers.localization:text("dialog_blackmarket_slot_item", {
		slot = params.slot,
		item = params.weapon_name
	})]]
	local menu_message
	
	if add then
		--Check options
		--You are about to apply weapon skin XXX to your weapon.
		if menu_message then
			menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_add", {
				cosmetic = params.name
			})
		else
			menu_message = managers.localization:text("dialog_weapon_cosmetics_add", {
				cosmetic = params.name
			})
		end
		
		--This will replace your current weapon skin XXX.
		--This is also fucking useless.
		--[[if params.crafted_has_cosmetic then
			menu_message = menu_message.." "..managers.localization:text("dialog_weapon_cosmetics_replace", {
				cosmetic = params.crafted_name
			})
		end]]
		
		--Choose ask cosmetics message
		if params.customize_locked and not self._settings.osa_allow_unlock then
			--This is a special weapon skin, while it is applied you will not be able to change the configuration nor the custom name for this weapon.
			menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_locked")
			--Change your settings in the options menu if you want to customize locked legendary skins.
			menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_change_unlock_settings")
		elseif params.item_has_default_blueprint then
			--This weapon skin contains its own set of modifications and will reaplce your current configuration.
			--menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_set_blueprint")
			--Which attachments do you want to use?
			menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_attachments")
		else
			--Do you want to keep your attachments?
			menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_keep")
		end
		
		--Build menu
		--We can always keep unless we are equipping a locked legendary and unlock not allowed
		local can_keep = not params.customize_locked or self._settings.osa_allow_unlock
		--We can only replace if we are adding and the added item has a blueprint
		local can_replace = params.item_has_default_blueprint
		--We can always remove unless we are equipping a locked legendary and unlock not allowed
		local can_remove = not params.customize_locked or self._settings.osa_allow_unlock
		
		local menu_options = {}
		count = 1
		--Keep attachments
		if can_keep then
			menu_options[count] = {
				text = managers.localization:text("osa_dialog_keep"),
				callback = function()
					self:legendary_handler("keep", params)
				end
			}
			count = count + 1
		end
		--If locked legendary, we can can only replace, so replace dialog with "continue"
		if can_replace then
			menu_options[count] = {
				text = can_keep and managers.localization:text("osa_dialog_replace") or managers.localization:text("dialog_continue"),
				callback = function()
					self:legendary_handler("replace", params)
				end
			}
			count = count + 1
		end
		--Remove
		if can_remove then
			menu_options[count] = {
				text = managers.localization:text("osa_dialog_remove"),
				callback = function()
					self:legendary_handler("remove", params)
				end
			}
			count = count + 1
		end
		--Cancel
		menu_options[count] = {
			text = managers.localization:text("dialog_cancel"),
			callback = function()
				self._state = nil
			end,
			is_cancel_button = true
		}
		--Show Menu
		local menu = QuickMenu:new(menu_title, menu_message, menu_options)
		menu:Show()
	else
		--Remove / Keep
		--You are about to remove weapon skin XXX to your weapon.
		if menu_message then
			menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_remove", {
				cosmetic = params.name
			})
		else
			menu_message = managers.localization:text("dialog_weapon_cosmetics_remove", {
				cosmetic = params.name
			})
		end
		--Do you want to keep your attachments?
		menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_keep")
		
		local menu_options = {
			[1] = {
				text = managers.localization:text("osa_dialog_keep"),
				callback = function()
					self:remove_handler("keep", params)
				end
			},
			[2] = {
				text = managers.localization:text("osa_dialog_remove"),
				callback = function()
					self:remove_handler("remove", params)
				end
			},
			[3] = {
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
end

--Finish remove
function OSA:remove_handler(option, params)
	--Save
	self._state.options.attach = option
	
	--Done, run callback
	self._state.yes_clbk()
end

--Handle menu for legendary options
--Options: keep / replace / remove
function OSA:legendary_handler(option, params)
	--Save
	self._state.options.attach = option
	
	--Only need to handle if locked and allow unlock is enabled
	--If not we just pass
	if not (params.customize_locked and self._settings.osa_allow_unlock) then
		--Don't unlock
		self:apply_handler("no", params)
	else
		local menu_title = managers.localization:text("osa_dialog_title")
		--This is a special weapon skin, while it is applied you will not be able to change the configuration nor the custom name for this weapon.
		local menu_message = managers.localization:text("dialog_weapon_cosmetics_locked")
		local menu_options
		if option ~= "replace" then
			--If not replacing, this is just an unlock confirmation
			if option == "keep" then
				--Keep
				menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_keep_unlock_warn")
			else
				--Remove
				menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_remove_unlock_warn")
			end
			
			--Unlock or go back
			menu_options = {
				[1] = {
					text = managers.localization:text("osa_dialog_unlock"),
					callback = function()
						self:apply_handler("yes", params)
					end
				},
				[2] = {
					text = managers.localization:text("osa_dialog_back"),
					callback = function()
						self:weapon_cosmetics_handler(params)
					end,
					is_cancel_button = true
				}
			}
		else
			--Choose whether to unlock
			menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_unlock")
			menu_options = {
				[1] = {
					text = managers.localization:text("osa_dialog_unlock"),
					callback = function()
						self:apply_handler("yes", params)
					end
				},
				[2] = {
					text = managers.localization:text("osa_dialog_unlock_remove_legend"),
					callback = function()
						self:apply_handler("remove_legend", params)
					end
				},
				[3] = {
					text = managers.localization:text("osa_dialog_dont_unlock"),
					callback = function()
						self:apply_handler("no", params)
					end
				},
				[4] = {
					text = managers.localization:text("osa_dialog_back"),
					callback = function()
						self:weapon_cosmetics_handler(params)
					end,
					is_cancel_button = true
				}
			}
		end
		
		--Show Menu
		local menu = QuickMenu:new(menu_title, menu_message, menu_options)
		menu:Show()
	end
end

--Finish apply
function OSA:apply_handler(option, params)
	--Save
	self._state.options.unlock = option
	
	--Done, run callback
	self._state.yes_clbk()
end

--Pass all of the data so we can also set the wear if we want later.
function OSA:weapon_preview_handler(data)
	--Initialize this so we can save options
	self._state.options = {}
	
	--Check if skin has blueprint
	local skin_id = data.cosmetic_id
	local skin_data = tweak_data.blackmarket.weapon_skins[skin_id]
	local has_blueprint = skin_data and skin_data.default_blueprint and not skin_data.osa_no_attachments
	
	--Build menu
	local menu_title = managers.localization:text("osa_dialog_title")
	local menu_message = managers.localization:text("osa_dialog_ask_preview")
	
	local menu_options = {}
	count = 1
	--Keep attachments, we can always do this
	menu_options[count] = {
		text = managers.localization:text("osa_dialog_keep"),
		callback = function()
			self:weapon_wear_handler("keep", data)
		end
	}
	count = count + 1
	--Use skin attachments, only if the skin has a blueprint
	if has_blueprint then
		menu_options[count] = {
			text = managers.localization:text("osa_dialog_replace"),
			callback = function()
				self:weapon_wear_handler("replace", data)
			end
		}
		count = count + 1
	end
	--Remove, we can always do this
	menu_options[count] = {
		text = managers.localization:text("osa_dialog_remove"),
		callback = function()
			self:weapon_wear_handler("remove", data)
		end
	}
	count = count + 1
	--Cancel
	menu_options[count] = {
		text = managers.localization:text("dialog_cancel"),
		callback = function()
			self._state = nil
		end,
		is_cancel_button = true
	}
	--Show Menu
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Choose wear
function OSA:weapon_wear_handler(option, data)
	--Save
	self._state.options.attach = option
	
	--Wear preview off, go directly to final
	if not self._settings.osa_preview_wear then
		self:weapon_preview_handler_final(nil, data)
	else
		--Show "Real Wear" tag if not a color and the skin is owned
		local real_quality = not data.is_a_color_skin and data.unlocked and data.cosmetic_quality
		--Wear menu
		local menu_title = managers.localization:text("osa_dialog_title")
		local menu_message = managers.localization:text("osa_dialog_choose_quality")
		local menu_options = {
			[1] = {
				text = managers.localization:text("bm_menu_quality_mint") .. (real_quality == "mint" and " (".. managers.localization:text("osa_dialog_real_quality") .. ")" or ""),
				callback = function()
					self:weapon_preview_handler_final("mint", data)
				end
			},
			[2] = {
				text = managers.localization:text("bm_menu_quality_fine") .. (real_quality == "fine" and " (".. managers.localization:text("osa_dialog_real_quality") .. ")" or ""),
				callback = function()
					self:weapon_preview_handler_final("fine", data)
				end
			},
			[3] = {
				text = managers.localization:text("bm_menu_quality_good") .. (real_quality == "good" and " (".. managers.localization:text("osa_dialog_real_quality") .. ")" or ""),
				callback = function()
					self:weapon_preview_handler_final("good", data)
				end
			},
			[4] = {
				text = managers.localization:text("bm_menu_quality_fair") .. (real_quality == "fair" and " (".. managers.localization:text("osa_dialog_real_quality") .. ")" or ""),
				callback = function()
					self:weapon_preview_handler_final("fair", data)
				end
			},
			[5] = {
				text = managers.localization:text("bm_menu_quality_poor") .. (real_quality == "poor" and " (".. managers.localization:text("osa_dialog_real_quality") .. ")" or ""),
				callback = function()
					self:weapon_preview_handler_final("poor", data)
				end
			},
			[6] = {
				text = managers.localization:text("osa_dialog_back"),
				callback = function()
					self:weapon_preview_handler(data)
				end,
				is_cancel_button = true
			}
		}
		--Show Menu
		local menu = QuickMenu:new(menu_title, menu_message, menu_options)
		menu:Show()
	end
end

--Set attachment option
function OSA:weapon_preview_handler_final(option, data)
	--Set quality
	if option then
		data.cosmetic_quality = option
	end
	
	--Done, run callback
	self._state.yes_clbk()
end
