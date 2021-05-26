dofile(ModPath .. "lua/setup.lua")

--Tempfix, set default weapon color after opening weapon modification menu
Hooks:PostHook(PlayerInventoryGui, "_open_crafting_node", "osa_post_PlayerInventoryGui__open_crafting_node", function()
	OSA:set_default_weapon_color()
end)
