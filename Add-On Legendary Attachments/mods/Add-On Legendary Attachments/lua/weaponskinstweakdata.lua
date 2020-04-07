dofile(ModPath .. "lua/setup.lua")

--Clone skin patterns for addon parts
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "AOLA_post_BlackMarketTweakData__init_weapon_skins", function(self)
	if not AOLA.missing_dependency then
		for _, skin in pairs(self.weapon_skins) do
			if skin.parts then
				for skin_id, parts in pairs(AOLA._gen_1_mods) do
					for _, part_id in pairs(parts) do
						if skin.parts[part_id] then
							skin.parts[part_id.."_addon"] = deep_clone(skin.parts[part_id])
						end
					end
				end
			end
		end
	end
end)
