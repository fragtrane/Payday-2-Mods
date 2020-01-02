dofile(ModPath .. "lua/setup.lua")

--Update which legendary mods are shown.
Hooks:PostHook(NetworkAccountSTEAM, "_clbk_inventory_load", "osa_post_NetworkAccountSTEAM__clbk_inventory_load", function(self, error, list)
	for skin, part_list in pairs(OSA._gen_1_mods) do
		if OSA:get_multi_name("osa_show_legendary") == "off" then
			--Hide everything if show is off
			for _, part_id in pairs(part_list) do
				tweak_data.blackmarket.weapon_mods[part_id].pcs = nil
			end
		elseif OSA:get_multi_name("osa_show_legendary") == "owned" then
			--Show mods if skin is owned
			if managers.blackmarket:have_inventory_tradable_item("weapon_skins", skin) then
				for _, part_id in pairs(part_list) do
					tweak_data.blackmarket.weapon_mods[part_id].pcs = {}
				end
			else
				for _, part_id in pairs(part_list) do
					tweak_data.blackmarket.weapon_mods[part_id].pcs = nil
				end
			end
		elseif OSA:get_multi_name("osa_show_legendary") == "all" then
			--Otherwise show everything
			for _, part_id in pairs(part_list) do
				tweak_data.blackmarket.weapon_mods[part_id].pcs = {}
			end
		end
	end
end)
