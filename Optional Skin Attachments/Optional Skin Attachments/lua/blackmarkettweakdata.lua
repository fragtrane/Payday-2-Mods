dofile(ModPath .. "lua/setup.lua")

--Store tweak_data so it can be used by _init_weapon_skins, based on Super Skin Swapper
Hooks:PreHook(BlackMarketTweakData, "init", "osa_pre_BlackMarketTweakData_init", function(self, tweak_data)
	OSA._td = tweak_data
end)
