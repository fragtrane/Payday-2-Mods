dofile(ModPath .. "lua/setup.lua")


--When a skin is previewed, call the OSA skin menu
function BlackMarketGui:preview_cosmetic_on_weapon_callback(data)
	if OSA._settings.osa_preview then
		local _callback = callback(self, self, "osa_preview_cosmetic_on_weapon_callback", data)
		OSA:preview_skin_menu({data = data, _callback = _callback})
	else
		self:osa_preview_cosmetic_on_weapon_callback(data)
	end
end

--New preview skin call
function BlackMarketGui:osa_preview_cosmetic_on_weapon_callback(data)
	if OSA._state_preview.ready then
		managers.blackmarket:osa_view_weapon_with_cosmetics(data.category, data.slot, {
			id = data.cosmetic_id,
			quality = data.cosmetic_quality
		}, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
		OSA._state_preview.ready = false
	else
		managers.blackmarket:view_weapon_with_cosmetics(data.category, data.slot, {
			id = data.cosmetic_id,
			quality = data.cosmetic_quality
		}, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data())
	end
	self:reload()
end

--This function also uses _equip_weapon_cosmetics_callback
--Not sure if/when it is used, use the original _equip_weapon_cosmetics_callback if it happens
local orig_BlackMarketGui_buy_equip_weapon_cosmetics_callback = BlackMarketGui.buy_equip_weapon_cosmetics_callback
function BlackMarketGui:buy_equip_weapon_cosmetics_callback(data)
	local title = managers.localization:text("osa_dialog_title")
	local desc = "Error Code 01. If you see this message, please let me know."
	OSA:ok_menu(title, desc, false, false)
	OSA._buy_equip_flag = true
	orig_BlackMarketGui_buy_equip_weapon_cosmetics_callback(self, data)
end

--When a skin is applied, call the OSA skin menu instead
function BlackMarketGui:equip_weapon_cosmetics_callback(data)
	local _callback = callback(self, self, "_equip_weapon_cosmetics_callback", data)
	OSA:apply_skin_menu({data = data, _callback = _callback})
end

--Modified apply skin call
local orig_BlackMarketGui__equip_weapon_cosmetics_callback = BlackMarketGui._equip_weapon_cosmetics_callback
function BlackMarketGui:_equip_weapon_cosmetics_callback(data)
	self._item_bought = true
	local instance_id = data.name
	
	if data.equip_weapon_cosmetics then
		instance_id = data.equip_weapon_cosmetics.instance_id
	end
	
	managers.menu_component:post_event("item_buy")
	
	--Catch errors
	if OSA._buy_equip_flag then
		managers.blackmarket:on_equip_weapon_cosmetics(data.category, data.slot, instance_id)
		OSA._buy_equip_flag = false
	elseif not OSA._state_apply.ready then
		local title = managers.localization:text("osa_dialog_title")
		local desc = "Error Code 02. If you see this message, please let me know."
		OSA:ok_menu(title, desc, false, false)
		managers.blackmarket:on_equip_weapon_cosmetics(data.category, data.slot, instance_id)
	else
		managers.blackmarket:osa_on_equip_weapon_cosmetics(data.category, data.slot, instance_id)
		OSA._state_apply.ready = false
	end
	
	self:reload()
end

--When a skin is removed, call the OSA skin menu instead
function BlackMarketGui:remove_weapon_cosmetics_callback(data)
	local _callback = callback(self, self, "_remove_weapon_cosmetics_callback", data)
	OSA:remove_skin_menu({data = data, _callback = _callback})
end

--Modified remove skin call
function BlackMarketGui:_remove_weapon_cosmetics_callback(data)
	self._item_bought = true
	
	managers.menu_component:post_event("item_buy")
	
	--Catch errors
	if not OSA._state_remove.ready then
		local title = managers.localization:text("osa_dialog_title")
		local desc = "Error Code 03. If you see this message, please let me know."
		OSA:ok_menu(title, desc, false, false)
		managers.blackmarket:on_remove_weapon_cosmetics(data.category, data.slot)
	else
		managers.blackmarket:osa_on_remove_weapon_cosmetics(data.category, data.slot)
		OSA._state_remove.ready = false
	end
	
	self:reload()
end

--Add mod icons to legendary parts
local orig_BlackMarketGui_populate_mods = BlackMarketGui.populate_mods
function BlackMarketGui:populate_mods(data)
	orig_BlackMarketGui_populate_mods(self, data)
	local parts_tweak_data = tweak_data.weapon.factory.parts
	for index, _ in ipairs(data) do
		local mod_name = data[index].name
		if mod_name and parts_tweak_data[mod_name] and parts_tweak_data[mod_name].is_legendary_part then
			local set = false
			for skin, parts in pairs(OSA._gen_1_mods) do
				for _, part_id in pairs(parts) do
					if mod_name == part_id then
						data[index].bitmap_texture = OSA._gen_1_folders[skin]
						set = true
						break
					end
				end
				if set then
					break
				end
			end
		end
	end
end
