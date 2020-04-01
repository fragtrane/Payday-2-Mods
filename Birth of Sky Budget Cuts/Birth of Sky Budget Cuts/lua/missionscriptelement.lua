dofile(ModPath .. "lua/setup.lua")

core:import("CoreMissionScriptElement")
core:import("CoreClass")
MissionScriptElement = MissionScriptElement or class(CoreMissionScriptElement.MissionScriptElement)

--Delete parachutes and print notice at start of mission
local orig_MissionScriptElement_on_executed = orig_MissionScriptElement_on_executed or MissionScriptElement.on_executed
function MissionScriptElement:on_executed(...)
	if Global.game_settings and not Network:is_client() and BOSBC:check() then
		local level_id = Global.game_settings.level_id
		--100558 player_spawned
		if level_id == "pbr2" and self._id == 147458 then
			local roll = math.random(100)
			if roll < 10 then
				--10% chance for no chutes
				BOSBC._empty = true
				for chute_id = 1, 4 do
					BOSBC:remove_chute(chute_id)
				end
			else
				--Otherwise ceil(players/2)
				BOSBC._empty = false
				local n_players = managers.network:session():amount_of_players()
				local n_chutes = math.ceil(n_players/2)
				for chute_id = n_chutes+1, 4 do
					BOSBC:remove_chute(chute_id)
				end
			end
			--System message
			for _, message in ipairs(BOSBC._announce_message) do
				local message_localized = managers.localization:text(message)
				managers.chat:_receive_message(1, managers.localization:to_upper_text("menu_system_message"), message_localized, tweak_data.system_chat_color)
			end
		end
	end
	orig_MissionScriptElement_on_executed(self, ...)
end
