dofile(ModPath .. "lua/setup.lua")

--Check dependencies and assets on startup
--Open web browser: https://forum.cockos.com/showthread.php?t=171026
Hooks:PostHook(MenuMainState, "at_enter", "AOLA_post_MenuMainState_at_enter", function(self, ...)
	local has_superblt = AOLA:check_superblt()
	local has_beardlib = AOLA:check_beardlib()
	
	if not (has_superblt and has_beardlib) then
		local menu_title = managers.localization:text("aola_dialog_title")
		local menu_message = managers.localization:text("aola_dialog_missing_dependency")
		local open_links
		if has_superblt then
			--Needs BeardLib
			menu_message = menu_message.."\n\n"..managers.localization:text("aola_dialog_requires_beardlib")
			open_links = function()
				os.execute("cmd /c start https://modworkshop.net/mod/14924")
			end
		elseif has_beardlib then
			--Needs SuperBLT
			menu_message = menu_message.."\n\n"..managers.localization:text("aola_dialog_requires_superblt")
			open_links = function()
				os.execute("cmd /c start https://superblt.znix.xyz/")
			end
		else
			--Need both
			menu_message = menu_message.."\n\n"..managers.localization:text("aola_dialog_requires_superblt")
			menu_message = menu_message.."\n\n"..managers.localization:text("aola_dialog_requires_beardlib")
			open_links = function()
				os.execute("cmd /c start https://superblt.znix.xyz/")
				os.execute("cmd /c start https://modworkshop.net/mod/14924")
			end
		end
		--Dialog menu
		AOLA:dl_menu(menu_title, menu_message, "aola_dialog_open_links", open_links)
	else
		--If SuperBLT and BeardLib installed, check if assets have been downloaded yet
		local has_assets = AOLA:check_assets()
		
		--If not has assets, check legacy assets
		local migrated = false
		if not has_assets then
			migrated = AOLA:migrate_legacy_assets()
		end
		
		--If no assets and not migrated, go download assets
		if not has_assets and not migrated then
			local menu_title = managers.localization:text("aola_dialog_title")
			local menu_message = managers.localization:text("aola_dialog_missing_assets")
			--Wait until updates are done checking to open download manager
			local go_to_updates = function()
				Hooks:PostHook(BLTModManager, "clbk_got_update", "AOLA_post_BLTModManager_clbk_got_update", function(self, ...)
					local still_checking = false
					for _, mod in ipairs( self:Mods() ) do
						if mod:IsCheckingForUpdates() then
							still_checking = true
							break
						end
					end

					if not still_checking then
						managers.menu:open_node( "blt_download_manager" )
						Hooks:RemovePostHook("AOLA_post_BLTModManager_clbk_got_update")
					end
				end)
			end
			AOLA:dl_menu(menu_title, menu_message, "aola_dialog_goto_dl", go_to_updates)
		end
	end
end)
