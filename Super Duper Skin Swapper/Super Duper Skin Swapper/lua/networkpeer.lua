dofile(ModPath .. "lua/setup.lua")

--Prevent false-positives in the anti-piracy detection. default_blueprint was removed so legacy_blueprint needs to be checked.
local orig_NetworkPeer__verify_content = NetworkPeer._verify_content
function NetworkPeer:_verify_content(item_type, item_id)
	--Original result. Dummy mods will be flagged as well.
	local result = orig_NetworkPeer__verify_content(self, item_type, item_id)
	--If a weapon mod is not okay, check legacy blueprint to see if it is included.
	--Check both primary and secondary.
	if not result and item_type == "weapon_mods" then
		--If dummy mod, change name to real mod
		local is_dummy = false
		local dummy_mods = {
			"wpn_fps_smg_p90_b_legend_dummy",
			"wpn_fps_pis_judge_b_legend_dummy",
			"wpn_fps_pis_judge_g_legend_dummy"
		}
		if table.contains(dummy_mods, item_id) then
			item_id = item_id:sub(1, -7)
			is_dummy = true
		end
		--Check if mod is in legacy_blueprint
		local we_good = true
		local outfit = self:blackmarket_outfit()
		for item_type, item in pairs(outfit) do
			if item_type == "primary" or item_type == "secondary" then
				if table.contains(item.blueprint, item_id..(is_dummy and "_dummy" or "")) then
					local skin_blueprint = item.cosmetics and tweak_data.blackmarket.weapon_skins[item.cosmetics.id].legacy_blueprint or {}
					if not table.contains(skin_blueprint, item_id) then
						we_good = false
						break
					end
				end
			end
		end
		return we_good
	end
	--Otherwise just return result
	return result
end
