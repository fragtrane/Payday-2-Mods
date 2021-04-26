dofile(ModPath .. "lua/setup.lua")

Hooks:PostHook(EconomyTweakData, "init", "sdss_post_EconomyTweakData_init", function(self, ...)
	if not SDSS._safe_data then
		SDSS._safe_data = {}
		--Loop over safes
		for safe_id, safe in pairs(self.safes) do
			local skin_list
			if safe.name_id and safe.content then
				local content_id = safe.content
				local contents = self.contents[content_id]
				
				--Check if the safe contains weapon skins, add them to the list
				local weapon_skins = contents and contents.contains and contents.contains.weapon_skins
				if weapon_skins then
					skin_list = skin_list or {}
					for _, skin_id in pairs(weapon_skins) do
						table.insert(skin_list, skin_id)
					end
				end
				
				--Check for legendaries
				local legendary_content_ids = contents and contents.contains and contents.contains.contents
				if legendary_content_ids then
					for _, legendary_content_id in pairs(legendary_content_ids) do
						local legendary_contents = self.contents[legendary_content_id]
						local legendary_skins = legendary_contents and legendary_contents.contains and legendary_contents.contains.weapon_skins
						if legendary_skins then
							skin_list = skin_list or {}
							for _, skin_id in pairs(legendary_skins) do
								table.insert(skin_list, skin_id)
							end
						end
					end
				end
				--Safe skin list
				if skin_list then
					SDSS._safe_data[safe_id] = skin_list
				end
			end
		end
	end
end)
