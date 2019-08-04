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
	osa_save_removed = true,--Try to save attachments when a skin is removed from Steam inventory.
	
	osa_optional_boost = false,--Allow optional stat boosts.
	osa_disable_all_boosts = false,--Disable all stat boosts.
	
	osa_rename_legendary = true,--Allow legendary weapons to be renamed.
	osa_allow_unlock = false,--Allow legendary weapons to be unlocked.
	osa_remove_stats = false,--Remove stats from legendary attachments.
	osa_show_legendary = 1--Show legendary parts in weapon mod menu. 1 = "off", 2 = "owned", 3 = "all".
}
OSA._restart_list = {
	"osa_rename_legendary",
	"osa_remove_stats"
}
--Track parameters for applying skin
OSA._state_apply = {
	attach = "keep",--"keep" "replace" "remove"
	unlock = false,
	nolegend = false,
	boost = false,
	ready = false
}
--Track parameters for removing skin
OSA._state_remove = {
	keep = false,
	ready = false
}
--Flag for BlackMarketGui:buy_equip_weapon_cosmetics_callback
OSA._buy_equip_flag = false
--Flag for deferring BlackMarketManager:_on_modified_weapon. We need this so that we don't get crashes when keeping attachments.
OSA._skip_omw = false
--List of first generation legendary skins and parts
OSA._gen_1_mods = {
	--Vlad's Rodina
	ak74_rodina = {
		"wpn_fps_ass_74_b_legend",
		"wpn_upg_ak_fg_legend",
		"wpn_upg_ak_g_legend",
		"wpn_upg_ak_s_legend",
		"wpn_upg_ak_fl_legend"
	},
	--Midas Touch
	deagle_bling = {
		"wpn_fps_pis_deagle_b_legend"
	},
	--Dragon Lord
	flamethrower_mk2_fire = {
		"wpn_fps_fla_mk2_body_fierybeast"
	},
	--Green Grin
	rpg7_boom = {
		"wpn_fps_rpg7_m_grinclown"
	},
	--The Gimp
	m134_bulletstorm = {
		"wpn_fps_lmg_m134_body_upper_spikey",
		"wpn_fps_lmg_m134_barrel_legendary"
	},
	--Alamo Dallas
	p90_dallas_sallad = {
		"wpn_fps_smg_p90_b_legend"
	},
	--Big Kahuna
	r870_waves = {
		"wpn_fps_shot_r870_b_legendary",
		"wpn_fps_shot_r870_s_legendary",
		"wpn_fps_shot_r870_fg_legendary"
	},
	--Santa's Slayers
	x_1911_ginger = {
		"wpn_fps_pis_1911_g_legendary",
		"wpn_fps_pis_1911_fl_legendary"
	},
	--Don Pastrami
	model70_baaah = {
		"wpn_fps_snp_model70_b_legend",
		"wpn_fps_snp_model70_s_legend"
	},
	--Hungry Wolf
	par_wolf = {
		"wpn_fps_lmg_svinet_b_standard",
		"wpn_fps_lmg_svinet_s_legend"
	},
	--Astatoz
	m16_cola = {
		"wpn_fps_ass_m16_b_legend",
		"wpn_fps_ass_m16_fg_legend",
		"wpn_fps_ass_m16_s_legend"
	},
	--Anarcho
	judge_burn = {
		"wpn_fps_pis_judge_b_legend",
		"wpn_fps_pis_judge_g_legend"
	},
	--Apex
	boot_buck = {
		"wpn_fps_sho_boot_b_legendary",
		"wpn_fps_sho_boot_fg_legendary",
		"wpn_fps_sho_boot_o_legendary",
		"wpn_fps_sho_boot_s_legendary"
	},
	--Admiral
	ksg_same = {
		"wpn_fps_sho_ksg_b_legendary"
	},
	--Mars Ultor
	tecci_grunt = {
		"wpn_fps_ass_tecci_b_legend",
		"wpn_fps_ass_tecci_fg_legend",
		"wpn_fps_ass_tecci_s_legend"
	},
	--Demon
	serbu_lones = {
		"wpn_fps_shot_shorty_b_legendary",
		"wpn_fps_shot_shorty_fg_legendary",
		"wpn_fps_shot_shorty_s_legendary"
	},
	--Plush Phoenix
	new_m14_lones = {
		"wpn_fps_ass_m14_b_legendary",
		"wpn_fps_ass_m14_body_legendary",
		"wpn_fps_ass_m14_body_upper_legendary",
		"wpn_fps_ass_m14_body_lower_legendary"
	}
}
--First generation legendary skin icons (use as icons for legendary parts)
OSA._gen_1_folders = {
	--Vlad's Rodina
	ak74_rodina = "guis/dlcs/cash/safes/sputnik/weapon_skins/ak74_rodina",
	--Midas Touch
	deagle_bling = "guis/dlcs/cash/safes/cf15/weapon_skins/deagle_bling",
	--Dragon Lord
	flamethrower_mk2_fire = "guis/dlcs/cash/safes/cop/weapon_skins/flamethrower_mk2_fire",
	--Green Grin
	rpg7_boom = "guis/dlcs/cash/safes/cop/weapon_skins/rpg7_boom",
	--The Gimp
	m134_bulletstorm = "guis/dlcs/cash/safes/cop/weapon_skins/m134_bulletstorm",
	--Alamo Dallas
	p90_dallas_sallad = "guis/dlcs/cash/safes/dallas/weapon_skins/p90_dallas_sallad",
	--Big Kahuna
	r870_waves = "guis/dlcs/cash/safes/surf/weapon_skins/r870_waves",
	--Santa's Slayers
	x_1911_ginger = "guis/dlcs/cash/safes/flake/weapon_skins/x_1911_ginger",
	--Don Pastrami
	model70_baaah = "guis/dlcs/cash/safes/bah/weapon_skins/model70_baaah",
	--Hungry Wolf
	par_wolf = "guis/dlcs/cash/safes/pack/weapon_skins/par_wolf",
	--Astatoz
	m16_cola = "guis/dlcs/cash/safes/cola/weapon_skins/m16_cola",
	--Anarcho
	judge_burn = "guis/dlcs/cash/safes/burn/weapon_skins/judge_burn",
	--Apex
	boot_buck = "guis/dlcs/cash/safes/buck/weapon_skins/boot_buck",
	--Admiral
	ksg_same = "guis/dlcs/cash/safes/same/weapon_skins/ksg_same",
	--Mars Ultor
	tecci_grunt = "guis/dlcs/cash/safes/grunt/weapon_skins/tecci_grunt",
	--Demon
	serbu_lones = "guis/dlcs/cash/safes/lones/weapon_skins/serbu_lones",
	--Plush Phoenix
	new_m14_lones = "guis/dlcs/cash/safes/lones/weapon_skins/new_m14_lones"
}

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

--Build params to make it easier to set menu text
--Mostly copied from BlackMarketGui:_weapon_cosmetics_callback
function OSA:build_skin_params(data, add)
	local cosmetic_id = data.equip_weapon_cosmetics and data.equip_weapon_cosmetics.entry
	local cosmetic_name_id = cosmetic_id and tweak_data.blackmarket.weapon_skins[cosmetic_id].name_id
	local name_localized = cosmetic_name_id and managers.localization:text(cosmetic_name_id) or data.name_localized or data.name
	local crafted = managers.blackmarket:get_crafted_category(data.category)[data.slot]
	local crafted_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local crafted_default_blueprint = crafted.default_blueprint
	local crafted_has_cosmetic = not not crafted_cosmetic_id
	local crafted_has_default_blueprint = crafted_cosmetic_id and tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id] and not not tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id].default_blueprint
	local item_has_cosmetic = add
	local item_has_default_blueprint = add and tweak_data.blackmarket.weapon_skins[cosmetic_id or data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[cosmetic_id or data.cosmetic_id].default_blueprint and true or false
	local skin_params = {
		name = name_localized,
		category = data.category,
		slot = data.slot,
		weapon_name = managers.weapon_factory:get_weapon_name_by_factory_id(crafted.factory_id),
		customize_locked = add and data.locked_cosmetics and true or false,
		crafted_name = crafted_cosmetic_id and tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id] and tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id].name_id and managers.localization:text(tweak_data.blackmarket.weapon_skins[crafted_cosmetic_id].name_id) or managers.localization:text("bm_menu_no_mod"),
		crafted_has_cosmetic = crafted_has_cosmetic,
		crafted_has_default_blueprint = crafted_has_default_blueprint,
		item_has_cosmetic = item_has_cosmetic,
		item_has_default_blueprint = item_has_default_blueprint,
	}
	return skin_params
end

--First menu when skin is applied.
--Stage 1: choose attachments.
--Input Params: params.skin_params, params.data, params._callback
function OSA:apply_skin_menu(params)
	local menu_title = managers.localization:text("osa_dialog_title")
	
	--Menu Message
	--Build params if necessary
	local skin_params
	if not params.skin_params then
		skin_params = self:build_skin_params(params.data, true)
	else
		skin_params = params.skin_params
	end
	--Weapon slot message
	local menu_message = managers.localization:text("dialog_blackmarket_slot_item", {
		slot = skin_params.slot,
		item = skin_params.weapon_name
	})
	--Apply skin message
	menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_add", {
		cosmetic = skin_params.name
	})
	--Replace skin message (when the weapon already has a skin)
	if skin_params.crafted_has_cosmetic then
		menu_message = menu_message.." "..managers.localization:text("dialog_weapon_cosmetics_replace", {
		cosmetic = skin_params.crafted_name
	})
	end
	--Choose ask cosmetics message
	if skin_params.customize_locked and not self._settings.osa_allow_unlock then
		--If unlock is not allowed and skin is locked legendary, warn.
		menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_locked")
		menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_change_unlock_settings")
	elseif skin_params.item_has_default_blueprint then
		--Otherwise print replace message if skin has attachments
		menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_set_blueprint")
		menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_attachments")
	else
		--Otherwise just ask to keep attachments.
		menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_keep")
	end
	
	--Three menus
	--1. Apply commons/uncommons. Options: Keep, Remove All, Cancel.
	--2. Apply rares/epics/unlocked. Options: Keep, Use Skin, Remove All, Cancel.
	--3. Apply locked when unlocking is not allowed. Options: Continue, Cancel.
	
	--Menu Options
	local menu_options = {}
	if skin_params.customize_locked and not self._settings.osa_allow_unlock then
		--Locked legendary, continue
		menu_options = {
			[1] = {
				text = managers.localization:text("dialog_continue"),
				callback = callback(self, self, "attachments_callback_apply", {
					attach = "replace",
					skin_params = skin_params,
					data = params.data,
					_callback = params._callback
				})
			},
			[2] = {
				text = managers.localization:text("dialog_cancel"),
				is_cancel_button = true
			}
		}
	elseif skin_params.item_has_default_blueprint then
		--Skins with attachments
		menu_options = {
			[1] = {
				text = managers.localization:text("osa_dialog_keep"),
				callback = callback(self, self, "attachments_callback_apply", {
					attach = "keep",--Stage 1 flag
					skin_params = skin_params,
					data = params.data,
					_callback = params._callback
				})
			},
			[2] = {
				text = managers.localization:text("osa_dialog_replace"),
				callback = callback(self, self, "attachments_callback_apply", {
					attach = "replace",--Stage 1 flag
					skin_params = skin_params,
					data = params.data,
					_callback = params._callback
				})
			},
			[3] = {
				text = managers.localization:text("osa_dialog_remove"),
				callback = callback(self, self, "attachments_callback_apply", {
					attach = "remove",--Stage 1 flag
					skin_params = skin_params,
					data = params.data,
					_callback = params._callback
				})
			},
			[4] = {
				text = managers.localization:text("dialog_cancel"),
				is_cancel_button = true
			}
		}
	else
		--Skins without attachments
		menu_options = {
			[1] = {
				text = managers.localization:text("osa_dialog_keep"),
				callback = callback(self, self, "attachments_callback_apply", {
					attach = "keep",--Stage 1 flag
					skin_params = skin_params,
					data = params.data,
					_callback = params._callback
				})
			},
			[2] = {
				text = managers.localization:text("osa_dialog_remove"),
				callback = callback(self, self, "attachments_callback_apply", {
					attach = "remove",--Stage 1 flag
					skin_params = skin_params,
					data = params.data,
					_callback = params._callback
				})
			},
			[3] = {
				text = managers.localization:text("dialog_cancel"),
				is_cancel_button = true
			}
		}
	end
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Stage 2: choose whether to unlock the skin.
--Input Params: params.attach, params.skin_params, params.data, params._callback
function OSA:attachments_callback_apply(params)
	--If not locked legendary or unlock is not allowed, skip to next step
	local skin_params = params.skin_params
	if not skin_params.customize_locked or not self._settings.osa_allow_unlock then
		--If not legendary, move on.
		self:boost_callback({
			nolegend = false,--Stage 2 flag
			unlock = false,--Stage 2 flag
			attach = params.attach,--Stage 1 flag
			skin_params = skin_params,
			data = params.data,
			_callback = params._callback
		})
	else
		--Otherwise confirm unlock
		local menu_title = managers.localization:text("osa_dialog_title")
		local menu_message = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = skin_params.slot,
			item = skin_params.weapon_name
		})
		menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_locked")
		if params.attach == "keep" then
			--If "keep" was selected, warn that the skin will be unlocked
			menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_keep_unlock_warn")
			local menu_options = {
				[1] = {
					text = managers.localization:text("osa_dialog_unlock"),
					callback = callback(self, self, "boost_callback", {
						nolegend = false,--Stage 2 flag
						unlock = true,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				},
				[2] = {
					text = managers.localization:text("osa_dialog_back"),
					callback = callback(self, self, "apply_skin_menu", {
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				}
			}
			local menu = QuickMenu:new(menu_title, menu_message, menu_options)
			menu:Show()
		elseif params.attach == "replace" then
			--If "replace" was selected, ask if the user wants to unlock the skin
			menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_unlock")
			local menu_options = {
				[1] = {
					text = managers.localization:text("osa_dialog_unlock"),
					callback = callback(self, self, "boost_callback", {
						nolegend = false,--Stage 2 flag
						unlock = true,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				},
				[2] = {
					text = managers.localization:text("osa_dialog_unlock_remove_legend"),
					callback = callback(self, self, "boost_callback", {
						nolegend = true,--Stage 2 flag
						unlock = true,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				},
				[3] = {
					text = managers.localization:text("osa_dialog_dont_unlock"),
					callback = callback(self, self, "boost_callback", {
						nolegend = false,--Stage 2 flag
						unlock = false,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				},
				[4] = {
					text = managers.localization:text("osa_dialog_back"),
					callback = callback(self, self, "apply_skin_menu", {
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				}
			}
			local menu = QuickMenu:new(menu_title, menu_message, menu_options)
			menu:Show()
		elseif params.attach == "remove" then
			--If "remove" was selected, warn that the skin will be unlocked
			menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_remove_unlock_warn")
			local menu_options = {
				[1] = {
					text = managers.localization:text("osa_dialog_unlock"),
					callback = callback(self, self, "boost_callback", {
						nolegend = false,--Stage 2 flag
						unlock = true,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				},
				[2] = {
					text = managers.localization:text("osa_dialog_back"),
					callback = callback(self, self, "apply_skin_menu", {
						skin_params = skin_params,
						data = params.data,
						_callback = params._callback
					})
				}
			}
			local menu = QuickMenu:new(menu_title, menu_message, menu_options)
			menu:Show()
		end
	end
end

--Stage 3: choose whether to apply stat boost.
--Input Params: params.nolegend, params.unlock, params.attach, params.skin_params, params.data, params._callback
function OSA:boost_callback(params)
	--Check whether the skin has a stat boost
	local instance_id = params.data.name
	if params.data.equip_weapon_cosmetics then
		instance_id = params.data.equip_weapon_cosmetics.instance_id
	end
	local item_data = managers.blackmarket:get_inventory_tradable()[instance_id]
	--Fix for Immortal Python
	local has_boost = false
	if item_data then 
		has_boost = item_data.bonus
	end
	--Skip this step if optional boosts is not enabled
	--Or if the skin does not have a boost / is Immortal Python (no item_data)
	--Or if disable all boost -> disable boost and skip
	if not self._settings.osa_optional_boost or not has_boost or not item_data or self._settings.osa_disable_all_boosts then
		self:apply_final({
			boost = has_boost and not self._settings.osa_disable_all_boosts,--Stage 3 flag
			nolegend = params.nolegend,--Stage 2 flag
			unlock = params.unlock,--Stage 2 flag
			attach = params.attach,--Stage 1 flag
			_callback = params._callback
		})
	else
		local menu_title = managers.localization:text("osa_dialog_title")

		local skin_params = params.skin_params
		local menu_message = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = skin_params.slot,
			item = skin_params.weapon_name
		})	
		menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_boost")
		
		--Generate bonus text
		--Based on build params
		--params.data.cosmetic_id has the ID
		local cosmetic_id = params.data.equip_weapon_cosmetics and params.data.equip_weapon_cosmetics.entry or params.data.cosmetic_id
		local bonus = cosmetic_id and tweak_data.blackmarket.weapon_skins[cosmetic_id].bonus
		
		--Bonus Name ID
		bonus_name_id = tweak_data.economy.bonuses[bonus].name_id

		--Get team bonus
		local team = false
		if tweak_data.economy.bonuses[bonus].exp_multiplier then
			local tb = (tweak_data.economy.bonuses[bonus].exp_multiplier - 1) * 100
			team = "+"..string.format("%.0f", tb).."%"
		end
		
		--Get bonus value depending on type of bonus
		local value
		--Concealment Bonus
		if string.sub(tostring(bonus), 1, 13) == "concealment_p" then
			value = string.sub(tostring(bonus), 14, 14)
			value = tonumber(value)
		end
		--Damage Bonus
		if string.sub(tostring(bonus), 1, 8) == "damage_p" then
			value = string.sub(tostring(bonus), 9, 9)
			value = tonumber(value)
		end
		--Stability Bonus (Step 4)
		if string.sub(tostring(bonus), 1, 8) == "recoil_p" then
			value = string.sub(tostring(bonus), 9, 9)
			value = 4*tonumber(value)
		end
		--Negative Accuracy Bonus (Step 4)
		if string.sub(tostring(bonus), 1, 8) == "spread_n" then
			value = string.sub(tostring(bonus), 9, 9)
			value = -4*tonumber(value)
		end
		--Accuracy Bonus (Step 4)
		if string.sub(tostring(bonus), 1, 8) == "spread_p" then
			value = string.sub(tostring(bonus), 9, 9)
			value = 4*tonumber(value)
		end
		--Team Bonus
		if string.sub(tostring(bonus), 1, 16) == "team_exp_money_p" then
			value = ""
		end
		--Total Ammo Bonus (Step 5%)
		if string.sub(tostring(bonus), 1, 12) == "total_ammo_p" then
			local weapon_id = tweak_data.blackmarket.weapon_skins[cosmetic_id].weapon_id
			local AMMO_MAX = tweak_data.weapon[weapon_id].AMMO_MAX
			value = string.sub(tostring(bonus), 13, 13)
			value = tonumber(value)*5/100*AMMO_MAX
			value = math.floor(value + 0.5)--Round
		end
		--Convert value to string (except in the case of team boost)
		if type(value) == "number" then
			if value > 0 then
				value = "+"..tostring(value).." "
			else
				value = tostring(value).." "
			end
		end
		--Build string
		if team then
			bonus_string = value..managers.localization:text(bonus_name_id, {team_bonus = team})
		else
			bonus_string = value..managers.localization:text(bonus_name_id)
		end
		
		--Append string
		menu_message = menu_message.."\n\n"..bonus_string
		
		local menu_options = {}
		--Ask to apply bonus
		if not skin_params.customize_locked or not self._settings.osa_allow_unlock then
			--Back button: If non-legendary or unlock not allowed, go back to apply_skin_menu
			menu_options = {
				[1] = {
					text = managers.localization:text("dialog_yes"),
					callback = callback(self, self, "apply_final", {
						boost = true,--Stage 3 flag
						nolegend = params.nolegend,--Stage 2 flag
						unlock = params.unlock,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						_callback = params._callback
					})
				},
				[2] = {
					text = managers.localization:text("dialog_no"),
					callback = callback(self, self, "apply_final", {
						boost = false,--Stage 3 flag
						nolegend = params.nolegend,--Stage 2 flag
						unlock = params.unlock,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						_callback = params._callback
					})
				},
				[3] = {
					text = managers.localization:text("osa_dialog_back"),
					callback = callback(self, self, "apply_skin_menu", {
						skin_params = params.skin_params,
						data = params.data,
						_callback = params._callback
					})
				}
			}
		else
			--Back button: If locked legendary and unlock is allowed, go back to attachments_callback_apply
			menu_options = {
				[1] = {
					text = managers.localization:text("dialog_yes"),
					callback = callback(self, self, "apply_final", {
						boost = true,--Stage 3 flag
						nolegend = params.nolegend,--Stage 2 flag
						unlock = params.unlock,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						_callback = params._callback
					})
				},
				[2] = {
					text = managers.localization:text("dialog_no"),
					callback = callback(self, self, "apply_final", {
						boost = false,--Stage 3 flag
						nolegend = params.nolegend,--Stage 2 flag
						unlock = params.unlock,--Stage 2 flag
						attach = params.attach,--Stage 1 flag
						_callback = params._callback
					})
				},
				[3] = {
					text = managers.localization:text("osa_dialog_back"),
					callback = callback(self, self, "attachments_callback_apply", {
						attach = params.attach,--Stage 1 flag
						skin_params = params.skin_params,
						data = params.data,
						_callback = params._callback
					})
				}
			}
		end

		local menu = QuickMenu:new(menu_title, menu_message, menu_options)
		menu:Show()
	end
end

--Final execution once all options have been set
--Input Params: params.boost, params.nolegend, params.unlock, params.attach, params._callback
function OSA:apply_final(params)
	--Set State
	self._state_apply.boost = params.boost
	self._state_apply.nolegend = params.nolegend
	self._state_apply.unlock = params.unlock
	self._state_apply.attach = params.attach
	self._state_apply.ready = true--Flag to indicate to use OSA settings when applying skin
	--Execute Callback
	params._callback()
end

--Menu when skin is removed.
function OSA:remove_skin_menu(params)
	local menu_title = managers.localization:text("osa_dialog_title")
	
	--Menu Message
	local skin_params
	if not params.skin_params then
		skin_params = self:build_skin_params(params.data, true)
	else
		skin_params = params.skin_params
	end
	local menu_message = managers.localization:text("dialog_blackmarket_slot_item", {
		slot = skin_params.slot,
		item = skin_params.weapon_name
	})
	menu_message = menu_message.."\n\n"..managers.localization:text("dialog_weapon_cosmetics_remove", {
		cosmetic = skin_params.name
	})
	menu_message = menu_message.."\n\n"..managers.localization:text("osa_dialog_ask_keep")
	local menu_options = {
		[1] = {
			text = managers.localization:text("osa_dialog_keep"),
			callback = callback(self, self, "remove_final", {
				keep = true,
				skin_params = skin_params,
				data = params.data,
				_callback = params._callback
			})
		},
		[2] = {
			text = managers.localization:text("osa_dialog_remove"),
			callback = callback(self, self, "remove_final", {
				keep = false,
				skin_params = skin_params,
				data = params.data,
				_callback = params._callback
			})
		},
		[3] = {
			text = managers.localization:text("dialog_cancel"),
			is_cancel_button = true
		}
	}
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Execute after parameters have been set
function OSA:remove_final(params)
	--Set State
	self._state_remove.keep = params.keep
	self._state_remove.ready = true--Flag to indicate to use OSA settings when applying skin
	--Execute Callback
	params._callback()
end
