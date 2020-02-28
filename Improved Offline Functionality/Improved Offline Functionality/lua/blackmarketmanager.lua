dofile(ModPath .. "lua/setup.lua")

--Block inventory update when offline.
local orig_BlackMarketManager_tradable_update = BlackMarketManager.tradable_update
function BlackMarketManager:tradable_update(tradable_list, remove_missing)
	if not Steam:logged_on() and IOF._settings.iof_inventory then
		return
	end
	
	orig_BlackMarketManager_tradable_update(self, tradable_list, remove_missing)
end

--Heavy Metal achievement (Monkey Wrench)
local orig_BlackMarketManager_has_unlocked_shock = BlackMarketManager.has_unlocked_shock
function BlackMarketManager:has_unlocked_shock()
	if not Steam:logged_on() and IOF._settings.iof_community then
		return IOF._state.sah_11, "bm_menu_locked_shock"
	end
	
	return orig_BlackMarketManager_has_unlocked_shock
end
