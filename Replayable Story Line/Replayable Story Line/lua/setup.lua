--Don't do setup twice
if _G.RSL then
	return
end

--Set up variables
_G.RSL = _G.RSL or {}
RSL._mod_path = ModPath

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "rsl_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(RSL._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "rsl_hook_MenuManagerInitialize", function(menu_manager)	
	MenuCallbackHandler.rsl_callback_button = function(self, item)
		if item:name() == "rsl_reset_story" then
			RSL:reset_story_button()
		end
	end
	
	MenuHelper:LoadFromJsonFile(RSL._mod_path.."menu/options.txt", RSL, RSL._settings)
end)

--Reset story line button
function RSL:reset_story_button()
	local menu_title = managers.localization:text("rsl_dialog_title")
	local menu_message = managers.localization:text("rsl_dialog_reset_confirm")
	local menu_options = {
		[1] = {
			text = managers.localization:text("dialog_yes"),
			callback = callback(self, self, "reset_story_button_callback")--RSL.reset_story_callback
		},
		[2] = {
			text = managers.localization:text("dialog_no"),
			is_cancel_button = true
		}
	}
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Reset story line button callback
function RSL:reset_story_button_callback()
	managers.story:reset_all()
	local menu_title = managers.localization:text("rsl_dialog_title")
	local menu_message = managers.localization:text("rsl_dialog_reset_done")
	local menu_options = {
		[1] = {
			text = managers.localization:text("dialog_ok"),
			is_cancel_button = true
		}
	}
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end
