dofile(ModPath .. "lua/setup.lua")

--Prevent false-positives in the anti-piracy detection. default_blueprint was removed so legacy_blueprint needs to be checked.
local orig_NetworkPeer__verify_content = NetworkPeer._verify_content
function NetworkPeer:_verify_content(item_type, item_id)
	--Replace dummy in order to validate Akimbo Kobus 90 and Akimbo Judge
	if item_id == "wpn_fps_smg_p90_b_legend_dummy" then
		item_id = "wpn_fps_smg_p90_b_legend"
	elseif item_id == "wpn_fps_pis_judge_b_legend_dummy" then
		item_id = "wpn_fps_pis_judge_b_legend"
	elseif item_id == "wpn_fps_pis_judge_g_legend_dummy" then
		item_id = "wpn_fps_pis_judge_g_legend"
	end
	--Original result
	local result = orig_NetworkPeer__verify_content(self, item_type, item_id)
	--If a weapon mod is not okay, check legacy blueprint to see if it is included.
	--Check both primary and secondary.
	if not result and tostring(item_type) == "weapon_mods" then
		local we_good = true
		local outfit = self:blackmarket_outfit()
		for item_type, item in pairs(outfit) do
			if item_type == "primary" or item_type == "secondary" then
				if table.contains(item.blueprint, item_id) then
					local skin_blueprint = item.cosmetics and tweak_data.blackmarket.weapon_skins[item.cosmetics.id].legacy_blueprint or {}
					if not table.contains(skin_blueprint, item_id) then
						we_good = false
						--Tempfix: if legendary attachment and not on original gun, ignore.
						--Do this to avoid false positives: if another player has extended their uses_parts table, we will think they are using a legendary part regardless of what they are actually using.
						if item_id == "wpn_fps_pis_deagle_b_legend" and item.factory_id ~= "wpn_fps_pis_deagle" then
							we_good = true
						elseif item_id == "wpn_fps_pis_1911_g_legendary" and item.factory_id ~= "wpn_fps_x_1911" then
							we_good = true
						elseif item_id == "wpn_fps_pis_1911_fl_legendary" and item.factory_id ~= "wpn_fps_x_1911" then
							we_good = true
						end
						--Break if invalid mod
						if not we_good then
							break
						end
					end
				end
			end
		end
		return we_good
	end
	--Otherwise just return result
	return result
end
