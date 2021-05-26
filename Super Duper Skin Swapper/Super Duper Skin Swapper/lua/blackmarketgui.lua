dofile(ModPath .. "lua/setup.lua")

--Highlighting, mostly just copied
local orig_BlackMarketGuiTabItem_mouse_moved = BlackMarketGuiTabItem.mouse_moved
function BlackMarketGuiTabItem:mouse_moved(x, y)
	if alive(self._tab_filters_panel) then
		self._tab_filters_highlighted = self._tab_filters_highlighted or {}
		local used = false
		local pointer = "arrow"
		for _, child in ipairs(self._tab_filters_panel:children()) do
			if child:inside(x, y) then
				if not self._tab_filters_highlighted[_] then
					self._tab_filters_highlighted[_] = true
					child:set_color(tweak_data.screen_colors.button_stage_2)
					managers.menu_component:post_event("highlight")
				end
			elseif self._tab_filters_highlighted[_] then
				self._tab_filters_highlighted[_] = false
				child:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end
	return orig_BlackMarketGuiTabItem_mouse_moved(self, x, y)
end

--Double click always previews skin
local orig_BlackMarketGui_press_first_btn = BlackMarketGui.press_first_btn
function BlackMarketGui:press_first_btn(button)
	--Preview takes precendence always
	if SDSS._settings.sdss_fast_preview and button == Idstring("0") then
		if self._btns and self._btns.wcc_preview then
			local btn = self._btns.wcc_preview
			if btn:visible() and btn._data.callback then
				managers.menu_component:post_event("menu_enter")
				btn._data.callback(self._slot_data, self._data.topic_params)
				return true
			end
		end
	end
	
	return orig_BlackMarketGui_press_first_btn(self, button)
end

--Handle clicking filters button
local orig_BlackMarketGuiTabItem_mouse_pressed = BlackMarketGuiTabItem.mouse_pressed
function BlackMarketGuiTabItem:mouse_pressed(button, x, y)
	if button == Idstring("0") and alive(self._tab_filters_panel) and self._tab_filters_panel:inside(x, y) then
		for _, child in ipairs(self._tab_filters_panel:children()) do
			if child:inside(x, y) then
				local child_name = child:name()
				SDSS:generic_filter_button_handler(child_name)
				return
			end
		end
	end
	
	return orig_BlackMarketGuiTabItem_mouse_pressed(self, button, x, y)
end

--Update to check if we are inside the filters button
local orig_BlackMarketGuiTabItem_inside = BlackMarketGuiTabItem.inside
function BlackMarketGuiTabItem:inside(x, y)
	--Tempfix, also check visible
	if alive(self._tab_filters_panel) and self._tab_filters_panel:visible() and self._tab_filters_panel:inside(x, y) then
		for _, child in ipairs(self._tab_filters_panel:children()) do
			if child:inside(x, y) then
				return 1
			end
		end
	end
	
	return orig_BlackMarketGuiTabItem_inside(self, x, y)
end

--Set filter button visibility
Hooks:PreHook(BlackMarketGuiTabItem, "refresh", "sdss_post_BlackMarketGuiTabItem_refresh", function(self)
	if alive(self._tab_filters_panel) then
		self._tab_filters_panel:set_visible(self._selected)
	end
end)

--Page number scaling and filter options
Hooks:PostHook(BlackMarketGuiTabItem, "init", "sdss_post_BlackMarketGuiTabItem_init", function(self, ...)
	--Check if we are on weapon skins page
	if self._name == "weapon_cosmetics" then
		--Check if there is a pages panel and scaling is enabled
		if SDSS._settings.sdss_page_number_scaling and self._tab_pages_panel then
			--Limit to 35 pages, otherwise do nothing
			--Might need to lower this a bit if someone has a metric fuckton of pages
			--But they should really just use duplicate hiding in that case
			--2.2 use slider setting
			local max_pages = SDSS._settings.sdss_page_buttons_max
			--Check if pages panel is too long
			--n_buttons is pages + 2 (because there is also a left arrow and right arrow button)
			local n_buttons = self._tab_pages_panel.num_children and self._tab_pages_panel:num_children()
			if n_buttons and n_buttons > (max_pages + 2) then
				local n_pages = n_buttons - 2
				--Do minus one because we always have to include page 1 so that's one less page we can use
				local step = math.ceil(n_pages/(max_pages - 1))
				
				local prev_item
				for i, child in ipairs(self._tab_pages_panel:children()) do
					if i == 1 then
						--Left arrow is always first item, always show
						prev_item = child
					elseif i == 2 then
						--Always show page 1
						child:set_left(prev_item:right() + 6)
						prev_item = child
					else
						--Page number is i-1 because first index is the left arrow
						local page = i - 1
						--If not on last page
						if page < n_pages then
							if page % step == 0 then
								--Only show steps
								child:set_left(prev_item:right() + 6)
								prev_item = child
							else
								--Hide. Set visible doesn't work because, it just makes it invisible but you can still click on it.
								child:set_width(0)
								child:set_height(0)
							end
						else
							--Always include last page and right arrow
							child:set_left(prev_item:right() + 6)
							prev_item = child
						end
					end
				end
				self._tab_pages_panel:set_w(prev_item:right())
				self._tab_pages_panel:set_right(self._grid_panel:right())
			end
		end
		
		--Filter buttons
		if SDSS._settings.sdss_enable_filters then
			local small_font = tweak_data.menu.pd2_small_font
			local small_font_size = tweak_data.menu.pd2_small_font_size
			--Make Panel
			self._tab_filters_panel = self._panel:panel({
				visible = false,--If we don't set this to false at the start, the button becomes visible again after we apply or preview a weapon mod
				w = self._grid_panel:w(),
				h = small_font_size
			})
			
			--Button Testing
			local prev_button
			local button_list = {
				"sdss_filter_button_reset",
				"sdss_filter_button_unowned",
				"sdss_filter_button_safe",
				"sdss_filter_button_rarity",
				"sdss_filter_button_quality",
				"sdss_filter_button_weapon"
			}
			for _, button_name in ipairs(button_list) do
				local button = self._tab_filters_panel:text({
					name = button_name,
					vertical = "center",
					align = "center",
					text = managers.localization:text(button_name),
					font = small_font,
					font_size = small_font_size,
					color = tweak_data.screen_colors.button_stage_3
				})
				local _, _, tw, th = button:text_rect()
				button:set_size(tw, th)
				if prev_button then
					button:set_left(prev_button:right() + 15)
				end
				prev_button = button
			end
			
			--If pages panel, set 2 units below
			--If no pages panel, set 2 units below weapon mods
			local top
			if self._tab_pages_panel then
				top = self._tab_pages_panel:bottom() + 2
			else
				top = self._grid_panel:bottom() + 2
			end
			
			self._tab_filters_panel:set_top(top)
			self._tab_filters_panel:set_w(prev_button:right())
			self._tab_filters_panel:set_right(self._grid_panel:right())
		end
	end
end)

--Based on OSA hijack
--Hijack preview and open our menu if preview is enabled
local orig_BlackMarketGui_preview_cosmetic_on_weapon_callback = BlackMarketGui.preview_cosmetic_on_weapon_callback
function BlackMarketGui:preview_cosmetic_on_weapon_callback(data)
	if SDSS._settings.sdss_preview_wear then
		--Make a callback to apply the skin
		SDSS._state = {}
		SDSS._state.yes_clbk = callback(self, self, "sdss_preview_cosmetic_on_weapon_callback", data)
		--Pass all of the data so we can also override the wear
		SDSS:weapon_wear_handler(data)
		return
	end
	orig_BlackMarketGui_preview_cosmetic_on_weapon_callback(self, data)
end
--Do original preview function and cleanup afterwards
function BlackMarketGui:sdss_preview_cosmetic_on_weapon_callback(data)
	orig_BlackMarketGui_preview_cosmetic_on_weapon_callback(self, data)
	SDSS._state = nil
end

--New in v2.1
--Hide attachments the proper way lmao.
Hooks:PreHook(BlackMarketGui, "populate_mods", "sdss_pre_BlackMarketGui_populate_mods", function(self, data)
	if not SDSS._settings.sdss_allow_variants then
		--Hide Anarcho Barrel on Akimbo
		if data.prev_node_data and data.prev_node_data.name == "x_judge" and data.name == "barrel" then
			for index, mod_t in ipairs(data.on_create_data or {}) do
				if mod_t[1] == "wpn_fps_pis_judge_b_legend" then
					table.remove(data.on_create_data, index)
				end
			end
		end
		--Hide Anarcho Grip on Akimbo
		if data.prev_node_data and data.prev_node_data.name == "x_judge" and data.name == "grip" then
			for index, mod_t in ipairs(data.on_create_data or {}) do
				if mod_t[1] == "wpn_fps_pis_judge_g_legend" then
					table.remove(data.on_create_data, index)
				end
			end
		end
		--Hide Alamo Dallas Barrel on Akimbo
		if data.prev_node_data and data.prev_node_data.name == "x_p90" and data.name == "slide" then
			for index, mod_t in ipairs(data.on_create_data or {}) do
				if mod_t[1] == "wpn_fps_smg_p90_b_legend" then
					table.remove(data.on_create_data, index)
				end
			end
		end
	end
end)

--New in v2.0
--Set default weapon color wear, paint scheme, pattern scale when equipping weapon color
Hooks:PreHook(BlackMarketGui, "equip_weapon_color_callback", "sdss_pre_BlackMarketGui_equip_weapon_color_callback", function(self, data)
	--Set wear if setting is not "off"
	local wear = SDSS:get_multi_name("sdss_color_wear")
	if wear ~= "off" then
		data.cosmetic_quality = wear
	end
	
	--Set paint scheme, shift index by 1 because first option is "off"
	if SDSS._settings.sdss_paint_scheme > 1 then
		data.cosmetic_color_index = SDSS._settings.sdss_paint_scheme - 1
	end
	
	--Set pattern scale, shift index by 1 because first option is "off"
	--No restart required when equipping a weapon color
	--When changing from a weapon color which does not have pattern scale to one that does, the default weapon scale in BlackMarketTweakData is used.
	--We also overwrite that value in weaponskinstweakdata.lua (for that one a restart is required)
	--Actually we don't do that anymore, because that also affects some skins and not just weapon colors
	if SDSS._settings.sdss_pattern_scale > 1 then
		data.cosmetic_pattern_scale = SDSS._settings.sdss_pattern_scale - 1
	end
end)

--New in v2.0
--Also apply settings when previewing a weapon color
Hooks:PreHook(BlackMarketGui, "preview_cosmetic_on_weapon_callback", "sdss_pre_BlackMarketGui_preview_cosmetic_on_weapon_callback", function(self, data)
	if data.is_a_color_skin then
		--Not sure why but this overwrites the preview wear option that we set in the dialog
		--So check preview wear is off before doing this
		local wear = SDSS:get_multi_name("sdss_color_wear")
		if wear ~= "off" and not SDSS._settings.sdss_preview_wear then
			if data.is_a_color_skin then
				data.cosmetic_quality = wear
			end
		end
		
		if SDSS._settings.sdss_paint_scheme > 1 then
			data.cosmetic_color_index = SDSS._settings.sdss_paint_scheme - 1
		end
		
		if SDSS._settings.sdss_pattern_scale > 1 then
			data.cosmetic_pattern_scale = SDSS._settings.sdss_pattern_scale - 1
		end
	end
end)

--Refresh icons after opening weapon modification menu
--0.1 too fast sometimes, better 0.25 to be safe
Hooks:PostHook(BlackMarketGui, "_open_crafting_node", "sdss_post_BlackMarketGui__open_crafting_node", function()
	--Tempfix, set default weapon color here
	SDSS:set_default_weapon_color()
	
	DelayedCalls:Add("sdss_icon_refresh_1", 0.25, function()
		--Don't reload if not in crafting anymore
		if managers.menu_scene and managers.menu_scene:get_current_scene_template() == "blackmarket_crafting" then
			local bmg = managers.menu_component._blackmarket_gui
			bmg:reload()
		end
	end)
end)

--Add mod icons to legendary parts
--Copied from OSA v3.0: optimized, checks if we are looking at the right weapon first
Hooks:PostHook(BlackMarketGui, "populate_mods", "sdss_post_BlackMarketGui_populate_mods", function(self, data)
	if data.prev_node_data and data.prev_node_data.name then
		--Check if we are looking at a weapon with legendary mods
		for weapon_id, skin_id in pairs(SDSS._gen_1_weapons) do
			if weapon_id == data.prev_node_data.name then
				--Add icons to the legendary parts
				local parts_tweak_data = tweak_data.weapon.factory.parts
				for index, _ in ipairs(data) do
					local mod_name = data[index].name
					if mod_name and parts_tweak_data[mod_name] and parts_tweak_data[mod_name].is_legendary_part then
						data[index].bitmap_texture = SDSS._gen_1_folders[skin_id]
					end
				end
				--Already found the right weapon, break
				break
			end
		end
	end
end)

--Clear useless/misleading stats of skins from weapon modification menu
--Only affects first generation legendaries, other skins do not show anything since their default_blueprint was completely removed
Hooks:PreHook(BlackMarketGui, "update_info_text", "sdss_pre_BlackMarketGui_update_info_text", function(self)
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	if identifier == self.identifiers.weapon_cosmetic then
		slot_data.comparision_data = nil
	end
end)
Hooks:PostHook(BlackMarketGui, "update_info_text", "sdss_post_BlackMarketGui_update_info_text", function(self)
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	if identifier == self.identifiers.weapon_cosmetic then
		self._stats_panel:hide()
	end
end)

--Mini skin icon in corner when a weapon with a swapped skin is selected
Hooks:PostHook(BlackMarketGui, "populate_weapon_category_new", "sdss_post_BlackMarketGui_populate_weapon_category_new", function(self, data)
	local category = data.category
	local crafted_category = managers.blackmarket:get_crafted_category(category) or {}
	
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local max_rows = tweak_data.gui.WEAPON_ROWS_PER_PAGE or 3
	max_items = max_rows * (data.override_slots and data.override_slots[1] or 3)
	
	for i = 1, max_items, 1 do
		local slot = data[i].slot
		if slot and crafted_category[slot] and crafted_category[slot].cosmetics and crafted_category[slot].cosmetics.id then
			local crafted = crafted_category[slot]
			local weapon_id = crafted.weapon_id
			local id = crafted.cosmetics.id
			local weapon_skin = tweak_data.blackmarket.weapon_skins[id]
			--BeardLib universals are now weapon colors
			if weapon_skin and not weapon_skin.is_a_color_skin then
				local found_weapon = (weapon_skin.weapon_ids and table.contains(weapon_skin.weapon_ids, weapon_id)) or (weapon_skin.weapon_id and weapon_skin.weapon_id == weapon_id)
				if weapon_skin.use_blacklist then
					found_weapon = not found_weapon
				end
				if not found_weapon then
					local guis_catalog = "guis/"
					local bundle_folder = weapon_skin.texture_bundle_folder
					if bundle_folder then
						guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
					end
					local texture_name = weapon_skin.texture_name or tostring(id)
					local path = "weapon_skins/"
					local texture_path = guis_catalog .. path .. texture_name
					
					local icon_list = managers.menu_component:create_weapon_mod_icon_list(crafted.weapon_id, category, crafted.factory_id, slot)
					data[i].mini_icons = data[i].mini_icons or {}
					table.insert(data[i].mini_icons, {
						stream = true,
						h = 24,--Scale down
						layer = 0,
						w = 48,--Scale down
						right = 0,--Move left
						texture = texture_path,
						bottom = math.floor((#icon_list - 1) / 11) * 25 + 24
					})
				end
			end
		end
	end
end)
