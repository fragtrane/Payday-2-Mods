dofile(ModPath .. "lua/setup.lua")

local ids_unit = Idstring("unit")

--Changed one line to use attachments when opening safe
function MenuSceneManager:load_safe_result_content(result, ready_clbk)
	local item_data = (tweak_data.economy[result.category] or tweak_data.blackmarket[result.category])[result.entry]
	self._safe_result_content_data = {
		result = result,
		item_data = item_data,
		ready_flags = {},
		ready_clbk = ready_clbk
	}

	if result.category == "weapon_skins" then
		local weapon_id = item_data.weapon_id or item_data.weapons[1]
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
		--Changed this line, use legacy_blueprint
		local blueprint = item_data.legacy_blueprint or deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
		local weapon_name = Idstring(tweak_data.weapon.factory[factory_id].unit)
		self._safe_result_content_data.weapon_name = weapon_name
		self._safe_result_content_data.factory_id = factory_id
		self._safe_result_content_data.ready_flags.parts_ready = false
		self._safe_result_content_data.ready_flags.weapon_ready = false

		managers.dyn_resource:load(ids_unit, weapon_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_set_safe_result_ready_flag", "weapon_ready"))

		local parts = managers.weapon_factory:preload_blueprint(factory_id, blueprint, false, false, callback(self, self, "_safe_result_parts_loaded"), false)
	elseif result.category == "armor_skins" then
		self._safe_result_content_data.armor_id = result.entry

		self:_check_safe_result_content_loaded()

		local rarity_data = tweak_data.economy.rarities[item_data.rarity] or {}
		local random_ang = 15
		local pos = self._scene_templates.safe.camera_pos + (self._scene_templates.safe.target_pos - self._scene_templates.safe.camera_pos):normalized() * 310 + math.UP * -120
		local ang = Rotation(180 + math.random(-random_ang, random_ang), 0, 0)
		local unit_name = tweak_data.blackmarket.characters[managers.blackmarket:equipped_character()].menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, ang)

		self:_set_character_unit_pose(rarity_data.armor_sequence or "cvc_var1", unit)
		unit:base():set_character_name(self._character_unit:base():character_name())
		unit:base():set_mask_id(self._character_unit:base():mask_id())
		unit:set_visible(false)

		self._economy_character = unit

		self._economy_character:set_rotation(Rotation(180, 0, 0))

		self._safe_result_content_data.ready_flags.armor_ready = false
		local armors = managers.blackmarket:get_sorted_armors()

		self:set_character_armor(armors[#armors], unit)
		self:set_character_player_style("none", "default", unit)
		managers.menu_scene:preview_character_skin(result.entry, self._economy_character, {
			done = callback(self, self, "_set_safe_result_ready_flag", "armor_ready")
		})
	end
end
