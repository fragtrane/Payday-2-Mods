--Don't do setup twice
if _G.BOSBC then
	return
end

--Set up variables
_G.BOSBC = _G.BOSBC or {}
BOSBC._mod_path = ModPath
BOSBC._save_path = SavePath
BOSBC._save_name = "bosbc_settings.txt"
BOSBC._settings = {
	bosbc_normal = true,
	bosbc_hard = true,
	bosbc_very_hard = true,
	bosbc_overkill = true,
	bosbc_mayhem = true,
	bosbc_death_wish = true,
	bosbc_death_sentence = true,
	bosbc_sp = false--Enable in single player
}
BOSBC._empty = false--Crate empty
BOSBC._opened = false--Crate opened
BOSBC._landed = false--Landed
BOSBC._picked_up = {}
--Announcement message(s) when player joins lobby
BOSBC._announce_message = {
	"bosbc_announce_message_1"
}
--Chat message(s) when crate is opened and not empty
BOSBC._open_message = {
	"bosbc_open_message_1"
}
--Chat message(s) when crate is empty
BOSBC._empty_message = {
	"bosbc_empty_message_1",
	"bosbc_empty_message_2"
}

--JSON encode helper
function BOSBC:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function BOSBC:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function BOSBC:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function BOSBC:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Load settings
local save_exists = io.open(BOSBC._save_path..BOSBC._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	BOSBC:load_settings()
else
	BOSBC:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "bosbc_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(BOSBC._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "bosbc_hook_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.bosbc_callback_toggle = function(self, item)
		BOSBC._settings[item:name()] = item:value() == "on"
	end
	
	MenuCallbackHandler.bosbc_callback_save = function(self, item)
		BOSBC:save_settings()
	end
	
	MenuHelper:LoadFromJsonFile(BOSBC._mod_path.."menu/options.txt", BOSBC, BOSBC._settings)
end)

--Delete chute by ID
function BOSBC:remove_chute(chute_id)
	--Just in case
	if not managers.platform or managers.platform:presence() ~= "Playing" then
		return
	end
	--Chute positions as strings, from left to right
	local position_strings = {
		[1] = "Vector3(454.075, -4559.75, 46268.6)",
		[2] = "Vector3(458.04, -4591.75, 46268.6)",
		[3] = "Vector3(455.04, -4624.75, 46268.6)",
		[4] = "Vector3(458.04, -4655.75, 46268.6)"
	}
	--Delete unit with matching position string
	local unit_list = World:find_units_quick("all")
	for _, unit in ipairs(unit_list) do
		if tostring(unit:name()) == tostring(Idstring("units/pd2_dlc_jerry/pickups/gen_pku_parachute/gen_pku_parachute")) then
			if tostring(unit:position()) == position_strings[chute_id] then
				World:delete_unit(unit)
				break
			end
		end
	end
end

--Delete chute after picked up so it can't respawn
function BOSBC:remove_picked_up()
	local unit_list = World:find_units_quick("all")
	for _, unit in ipairs(unit_list) do
		if tostring(unit:name()) == tostring(Idstring("units/pd2_dlc_jerry/pickups/gen_pku_parachute/gen_pku_parachute")) then
			if table.contains(self._picked_up, tostring(unit:position())) then
				World:delete_unit(unit)
			end
		end
	end
end

--Execute mission script function
function BOSBC:EMS(id)
	local element = managers.mission:get_element_by_id(id)
	if element then
		element:on_executed(managers.player:player_unit())
	end
end

--Check settings function
function BOSBC:check()
	local sp = Global.game_settings.single_player
	if sp and not self._settings.bosbc_sp then
		return false
	end
	
	local dif = Global.game_settings.difficulty
	if dif == "normal" and self._settings.bosbc_normal then
		return true
	elseif dif == "hard" and self._settings.bosbc_hard then
		return true
	elseif dif == "overkill" and self._settings.bosbc_very_hard then
		return true
	elseif dif == "overkill_145" and self._settings.bosbc_overkill then
		return true
	elseif dif == "easy_wish" and self._settings.bosbc_mayhem then
		return true
	elseif dif == "overkill_290" and self._settings.bosbc_death_wish then
		return true
	elseif dif == "sm_wish" and self._settings.bosbc_death_sentence then
		return true
	end
	
	return false
end
