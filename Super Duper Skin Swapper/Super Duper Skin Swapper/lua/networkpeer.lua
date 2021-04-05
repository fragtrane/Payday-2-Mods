dofile(ModPath .. "lua/setup.lua")

--Prevent false-positives in the anti-piracy detection.
--As of v2.0 we no longer remove default blueprints so normal weapon mods should not trip the piracy detection.
--However, dummy legendary mods are used when sdss_allow_variants is disabled. Dummy legendary mods are not normally part of the blueprint of legendary weapons and will trip the piracy detection.
--We add the dummy legendary mods to the default blueprints of the corresponding weapon to prevent this from happening.
--As an extra level of redundancy, we also update this function to handle dummy legendary mods in the unlikely event that something goes wrong.
local orig_NetworkPeer__verify_content = NetworkPeer._verify_content
function NetworkPeer:_verify_content(item_type, item_id)
	--Original result.
	local result = orig_NetworkPeer__verify_content(self, item_type, item_id)
	--If a weapon mod is not okay, check default_blueprint to see if it is included.
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
			--DEBUG
			log("SDSS FLAGGED DUMMY MOD: " .. item_id)
			item_id = item_id:sub(1, -7)
			is_dummy = true
		end
		
		--Check if dummy mod is in default_blueprint
		if is_dummy then
			local we_good = true
			local outfit = self:blackmarket_outfit()
			for item_type, item in pairs(outfit) do
				if item_type == "primary" or item_type == "secondary" then
					if table.contains(item.blueprint, item_id.."_dummy") then
						local skin_blueprint = item.cosmetics and tweak_data.blackmarket.weapon_skins[item.cosmetics.id].default_blueprint or {}
						if not table.contains(skin_blueprint, item_id) then
							we_good = false
							break
						end
						log("SDSS VALIDATION OK: " .. item_id)
					end
				end
			end
			return we_good
		end
	end
	--Otherwise just return result
	return result
end
