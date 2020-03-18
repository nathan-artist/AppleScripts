on run
	try
		tell application "System Events"
			activate
			set opened_items to (choose file with prompt "Choose file(s) to link:" with multiple selections allowed)
		end tell
		open opened_items
	end try
end run

on open dragged_items
	try
		set output_string to ""
		repeat with this_item in dragged_items
			tell application "System Events" to set item_URL to URL of this_item
			set item_info to info for this_item
			set item_name to displayed name of item_info
			set item_date to short date string of creation date of item_info
			set item_link to "- <a href=" & quote & item_URL & quote & ">" & item_name & "</a> (" & item_date & ")<br/>" & linefeed
			set output_string to (output_string & item_link)
		end repeat
		do shell script "LANG=en_US.UTF-8 echo " & quoted form of output_string & " | /usr/bin/textutil -inputencoding utf-8 -stdin -stdout -format html -convert rtf | sed 's/fcharset0 Times-Roman/fcharset0 Arial/' | pbcopy -Prefer rtf" -- convert the hyperlinks to rtf using textutil, change the font to Arial using sed (setting the font using textutil didn't work for me), and copy rtf to clipboard
	end try
end open
