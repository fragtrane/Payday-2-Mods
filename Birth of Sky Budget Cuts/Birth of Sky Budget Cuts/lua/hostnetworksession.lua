dofile(ModPath .. "lua/setup.lua")

--Announcement message, based on TdlQ's Announcer
Hooks:PostHook(HostNetworkSession, "on_peer_sync_complete", "bosbc_post_HostNetworkSession_on_peer_sync_complete", function(self, peer, peer_id)
	if Global.game_settings and Global.game_settings.level_id == "pbr2" and Network:is_server() and BOSBC:check() and not BOSBC._landed then
		local peer_id = peer:id()
		DelayedCalls:Add("bosbc_delayed_announce_" .. tostring(peer_id), 1, function()
			local peer2 = managers.network:session() and managers.network:session():peer(peer_id)
			if peer2 then
				for _, message in ipairs(BOSBC._announce_message) do
					local message_localized = managers.localization:text(message)
					peer2:send("send_chat_message", ChatManager.GAME, message_localized)
				end
			end
		end)
	end
end)
