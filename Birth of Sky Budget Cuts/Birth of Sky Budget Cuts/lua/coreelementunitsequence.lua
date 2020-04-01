dofile(ModPath .. "lua/setup.lua")

core:module("CoreElementUnitSequence")
core:import("CoreMissionScriptElement")
core:import("CoreCode")
core:import("CoreUnit")

ElementUnitSequence = ElementUnitSequence or class(CoreMissionScriptElement.MissionScriptElement)

--Print message after crate is opened
local orig_ElementUnitSequence_on_executed = ElementUnitSequence.on_executed
function ElementUnitSequence:on_executed(...)
	local BOSBC = _G.BOSBC
	local ChatManager = _G.ChatManager
	if Global.game_settings and not Network:is_client() and BOSBC:check() then
		local level_id = Global.game_settings.level_id
		--100076 enable_parachutes_interaction
		if level_id == "pbr2" and self._id == 146976 then
			if not BOSBC._opened then
				BOSBC._opened = true
				if BOSBC._empty then
					--No chutes message
					for _, message in ipairs(BOSBC._empty_message) do
						local message_localized = managers.localization:text(message)
						managers.chat:send_message(ChatManager.GAME, managers.network:session():local_peer(), message_localized)
					end
				else
					--Normal message
					for _, message in ipairs(BOSBC._open_message) do
						local message_localized = managers.localization:text(message)
						managers.chat:send_message(ChatManager.GAME, managers.network:session():local_peer(), message_localized)
					end
				end
				--100075 all_players_have_parachutes_link
				BOSBC:EMS(146975)
			end
		end
	end
	orig_ElementUnitSequence_on_executed(self, ...)
end
