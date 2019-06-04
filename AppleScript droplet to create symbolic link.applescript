on run
	try
		tell application "System Events"
			activate
			set the_choice to (display dialog "Do you want to link file(s) or folder(s)?" buttons {"Cancel", "Files", "Folders"} default button "Folders" cancel button "Cancel" with title "Create Symbolic Link")
			if the button returned of the_choice is "Files" then set opened_items to (choose file with prompt "Choose file(s) to link:" with multiple selections allowed)
			if the button returned of the_choice is "Folders" then set opened_items to (choose folder with prompt "Choose folder(s) to link:" with multiple selections allowed)
		end tell
		open opened_items
	end try
end run

on open dragged_items
	try
		tell application "System Events"
			activate
			choose folder with prompt "Where to make the symbolic link(s)?"
			set target_folder to the POSIX path of the result
		end tell
		repeat with this_item in dragged_items
			set item_info to info for this_item
			set type_identifier to type identifier of (item_info & {type identifier:"unknown"}) -- if there's no type identifier field in item_info then use "unknown"
			if type_identifier is not "com.apple.web-internet-location" then -- ignore .webloc files since AppleScript treats those as URLs instead of as files
				set item_path to the POSIX path of this_item
				if text -1 of item_path is "/" then set item_path to text 1 thru -2 of item_path
				do shell script "ln -s " & quoted form of item_path & space & quoted form of target_folder
			end if
		end repeat
	end try
end open
