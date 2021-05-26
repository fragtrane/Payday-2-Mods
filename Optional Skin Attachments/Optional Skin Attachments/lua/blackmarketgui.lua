dofile(ModPath .. "lua/setup.lua")

--Tempfix, set default weapon color after opening weapon modification menu
Hooks:PostHook(BlackMarketGui, "_open_crafting_node", "osa_post_BlackMarketGui__open_crafting_node", function()
	OSA:set_default_weapon_color()
end)

--Hide attachments the proper way lmao
Hooks:PreHook(BlackMarketGui, "populate_mods", "osa_pre_BlackMarketGui_populate_mods", function(self, data)
	--Hide Anarcho Barrel on Akimbo
	if data.prev_node_data and data.prev_node_data.name == "x_judge" and data.name == "barrel" then
		for index, mod_t in ipairs(data.on_create_data or {}) do
			if mod_t[1] == "wpn_fps_pis_judge_b_legend" then
				table.remove(data.on_create_data, index)
			end
		end
	end
	--Hide Anarcho Grip on Akimbo
	if data.prev_node_data and data.prev_node_data.name == "x_judge" and data.name == "grip" then
		for index, mod_t in ipairs(data.on_create_data or {}) do
			if mod_t[1] == "wpn_fps_pis_judge_g_legend" then
				table.remove(data.on_create_data, index)
			end
		end
	end
	--Hide Alamo Dallas Barrel on Akimbo
	if data.prev_node_data and data.prev_node_data.name == "x_p90" and data.name == "slide" then
		for index, mod_t in ipairs(data.on_create_data or {}) do
			if mod_t[1] == "wpn_fps_smg_p90_b_legend" then
				table.remove(data.on_create_data, index)
			end
		end
	end
end)

--Add mod icons to legendary parts
--v3.0: optimized, checks if we are looking at the right weapon first
Hooks:PostHook(BlackMarketGui, "populate_mods", "osa_post_BlackMarketGui_populate_mods", function(self, data)
	if data.prev_node_data and data.prev_node_data.name then
		--Check if we are looking at a weapon with legendary mods
		for weapon_id, skin_id in pairs(OSA._gen_1_weapons) do
			if weapon_id == data.prev_node_data.name then
				--Add icons to the legendary parts
				local parts_tweak_data = tweak_data.weapon.factory.parts
				for index, _ in ipairs(data) do
					local mod_name = data[index].name
					if mod_name and parts_tweak_data[mod_name] and parts_tweak_data[mod_name].is_legendary_part then
						data[index].bitmap_texture = OSA._gen_1_folders[skin_id]
					end
				end
				--Already found the right weapon, break
				break
			end
		end
	end
end)

--This function also uses _equip_weapon_cosmetics_callback
--Doesn't ever seem to be used. Pop an error message if it comes up so we can look into it.
Hooks:PreHook(BlackMarketGui, "buy_equip_weapon_cosmetics_callback", "osa_pre_BlackMarketGui_buy_equip_weapon_cosmetics_callback", function(...)
	local title = managers.localization:text("osa_dialog_title")
	local desc = managers.localization:text("osa_dialog_error_01")
	OSA:ok_menu(title, desc, false, false)
end)

--This is the button that calls buy_equip_weapon_cosmetics_callback
--Name is "Buy new weapon" (wtf???)
--[[
wcc_buy_equip_weapon = {
	btn = "BTN_A",
	prio = 1,
	name = "bm_menu_btn_buy_new_weapon",
	callback = callback(self, self, "buy_equip_weapon_cosmetics_callback")
},
]]

--Save the data so we can use it when we apply/remove the skin
--BlackMarketGui:_weapon_cosmetics_callback() will build the params and pass it to managers.menu:show_confirm_weapon_cosmetics(params)
--We will hijack that menu
Hooks:PreHook(BlackMarketGui, "_weapon_cosmetics_callback", "osa_pre_BlackMarketGui__weapon_cosmetics_callback", function(self, data, add, yes_clbk)
	OSA._state = {}
	OSA._state.data = data
	OSA._state.add = add
	OSA._state.yes_clbk = yes_clbk
end)

--Cleanup state after finishing apply/remove
Hooks:PostHook(BlackMarketGui, "_equip_weapon_color_callback", "osa_BlackMarketGui__equip_weapon_color_callback", function()
	OSA._state = nil
end)
Hooks:PostHook(BlackMarketGui, "_equip_weapon_cosmetics_callback", "osa_BlackMarketGui__equip_weapon_cosmetics_callback", function()
	OSA._state = nil
end)
Hooks:PostHook(BlackMarketGui, "_remove_weapon_cosmetics_callback", "osa_BlackMarketGui__remove_weapon_cosmetics_callback", function()
	OSA._state = nil
end)

--Set default weapon color wear, paint scheme, pattern scale when equipping weapon color
Hooks:PreHook(BlackMarketGui, "equip_weapon_color_callback", "osa_pre_BlackMarketGui_equip_weapon_color_callback", function(self, data)
	local wear = OSA:get_multi_name("osa_color_wear")
	if wear ~= "off" then
		data.cosmetic_quality = wear
	end
	
	--Shift index by 1 because first option is "off"
	if OSA._settings.osa_paint_scheme > 1 then
		data.cosmetic_color_index = OSA._settings.osa_paint_scheme - 1
	end
	
	--Shift index by 1 because first option is "off"
	if OSA._settings.osa_pattern_scale > 1 then
		data.cosmetic_pattern_scale = OSA._settings.osa_pattern_scale - 1
	end
end)

--Set default weapon color wear, paint scheme, pattern scale when previewing a weapon color
Hooks:PreHook(BlackMarketGui, "preview_cosmetic_on_weapon_callback", "osa_pre_BlackMarketGui_preview_cosmetic_on_weapon_callback", function(self, data)
	--Check color skin first, because some weapon skins also use pattern scale e.g. CAR-4 Stripe On, 5/7 AP Possessed
	if data.is_a_color_skin then
		--Not sure why but this overwrites the preview wear option that we set in the dialog
		--So check preview wear is off before doing this
		local wear = OSA:get_multi_name("osa_color_wear")
		if wear ~= "off" and not OSA._settings.osa_preview_wear then
			data.cosmetic_quality = wear
		end
		
		--Shift index by 1 because first option is "off"
		if OSA._settings.osa_paint_scheme > 1 then
			data.cosmetic_color_index = OSA._settings.osa_paint_scheme - 1
		end
		
		--Shift index by 1 because first option is "off"
		if OSA._settings.osa_pattern_scale > 1 then
			data.cosmetic_pattern_scale = OSA._settings.osa_pattern_scale - 1
		end
	end
end)

--Hijack preview and open our menu if preview is enabled
local orig_BlackMarketGui_preview_cosmetic_on_weapon_callback = BlackMarketGui.preview_cosmetic_on_weapon_callback
function BlackMarketGui:preview_cosmetic_on_weapon_callback(data)
	if OSA._settings.osa_preview then
		--Make a callback to apply the skin
		OSA._state = {}
		OSA._state.yes_clbk = callback(self, self, "osa_preview_cosmetic_on_weapon_callback", data)
		--Pass all of the data so we can also override the wear
		OSA:weapon_preview_handler(data)
		return
	end
	orig_BlackMarketGui_preview_cosmetic_on_weapon_callback(self, data)
end

--Do original preview function and cleanup afterwards
function BlackMarketGui:osa_preview_cosmetic_on_weapon_callback(data)
	orig_BlackMarketGui_preview_cosmetic_on_weapon_callback(self, data)
	OSA._state = nil
end
