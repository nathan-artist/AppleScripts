-- This script for Scrivener 2 runs the menu commands "Sync with External Folder Now" and "Compile..." so that both can be done with one command. It presumes that "Sync with External Folder" has already been run at least once to set the necessary sync settings. Since the script uses GUI scripting, the Accessibility API must be enabled in OS X 10.8 Mountain Lion and earlier, or it must be specifically enabled for Scrivener in OS X 10.9 Mavericks and later. For more information on enabling GUI scripting see, for example: http://www.macosautomation.com/mavericks/guiscripting/

global compile_button_available
global compile_menu_item_available
global sheet_closed
global quick_sync_enabled
global the_focused_window

on run
	set quick_sync_enabled to false
	set sheet_closed to false
	if application "Scrivener" is running then
		-- exit if Scrivener is not running, else activate Scrivener
		tell application "Scrivener" to activate
		try
			tell application "System Events" to tell process "Scrivener" to set the_focused_window to the value of attribute "AXFocusedWindow"
		end try
		if quickSyncIsEnabled() then
			-- exit if quick sync is not enabled for current document
			if sheetIsClosed() then
				-- exit if a sheet is already open in the focused window
				try
					tell application "System Events" to tell process "Scrivener" to click menu item "with External Folder Now" of its menu of menu item "Sync" of its menu of menu bar item "File" of menu bar 1
				end try
				set compile_menu_item_available to false
				repeat until compile_menu_item_available
					-- wait until the sync sheet closes
					set compile_menu_item_available to sheetIsClosed()
				end repeat
				try
					tell application "System Events" to tell process "Scrivener" to click menu item "Compile..." of its menu of menu bar item "File" of menu bar 1
				end try
				set compile_button_available to false
				repeat until compile_button_available
					-- wait until we have a compile button to click
					try
						tell application "System Events" to tell process "Scrivener"
							if the value of attribute "AXTitle" of the button "Compile" of sheet 1 of the_focused_window is "Compile" then set compile_button_available to true
						end tell
					end try
				end repeat
				try
					tell application "System Events" to tell process "Scrivener" to click button "Compile" of sheet 1 of the_focused_window
				end try
			end if
		end if
	end if
end run

on sheetIsClosed()
	try
		tell application "System Events" to tell process "Scrivener"
			if the value of attribute "AXRole" of the_focused_window is not "AXSheet" then set sheet_closed to true
		end tell
	end try
	return sheet_closed
end sheetIsClosed

on quickSyncIsEnabled()
	try
		tell application "System Events" to tell process "Scrivener"
			if the value of attribute "AXEnabled" of menu item "with External Folder Now" of its menu of menu item "Sync" of its menu of menu bar item "File" of menu bar 1 is {{true}} then set quick_sync_enabled to true
		end tell
	end try
	return quick_sync_enabled
end quickSyncIsEnabled
