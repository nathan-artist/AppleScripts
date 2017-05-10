on run
	try
		tell application "System Events"
			activate
			choose file with prompt "Choose file(s) to link:" with multiple selections allowed
		end tell
		open result
	end try
end run

on open dragged_items
	try
		tell application "System Events"
			activate
			choose folder with prompt "Where to make the symbolic link(s)?"
		end tell
		set target_folder to the POSIX path of the result
		repeat with this_item in dragged_items
			if type identifier of (info for this_item) is not "com.apple.web-internet-location" then
				set item_path to the POSIX path of this_item
				if text -1 of item_path is "/" then set item_path to text 1 thru -2 of item_path
				do shell script "ln -s " & quoted form of item_path & space & quoted form of target_folder
			end if
		end repeat
	end try
end open
