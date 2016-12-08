-- This script shows a dialog box that asks for a date and then (1) uses the shell command "touch" (see "man touch" for details) to create an empty html file in save_path with that creation date, then (2) sets the file extension of the file to hidden, then (3) changes the file metadata so that it always opens with TextEdit, and then (4) opens the file in TextEdit. Apple's Developer Tools must be installed before using this script so that the Rez and SetFile commands are available. The date input format is the format provided by the "Insert Short Date & Time" command in the free OS X service WordService, which can be downloaded from DEVONtechnologies at http://www.devontechnologies.com/products/freeware.html (of course this script could also be modified to handle any other date format).

-- where the new file will be saved:
property save_path : "/Volumes/Shared Drive/Nathan/Journal/Uncategorized/"

-- resource fork to be appended to the new file; for more info see: https://superuser.com/questions/259248/mac-osx-change-file-association-per-file-on-the-command-line
property set_to_open_file_with_textedit : "<<EOF
data 'usro' (0) {
	$\"0000 001B 2F41 7070 6C69 6361 7469 6F6E\"            /* ..../Application */
	$\"732F 5465 7874 4564 6974 2E61 7070 0000\"            /* s/TextEdit.app.. */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000 0000 0000 0000 0000 0000 0000\"            /* ................ */
	$\"0000 0000\"                                          /* .... */
};

EOF
"

on run
	try
		set the_date to display dialog "Enter date in format YYYY/MM/DD[,] [h]h:mm:ss [AM/PM]" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" default answer "" with title "Create File with Specified Creation Date"
		-- exit if cancel
		if the button returned of the_date is "OK" then
			set date_unparsed to text returned of the_date
			if "," is in date_unparsed then
				-- remove commas from input
				set date_unparsed to replaceText(date_unparsed, ",", "")
			end if
			if text -1 of date_unparsed is in {":", " "} then
				-- trim colon or space from end of input date
				repeat until text -1 of date_unparsed is not in {":", " "}
					set date_unparsed to trimLastChar(date_unparsed)
				end repeat
			end if
			if (text -2 thru -1 of date_unparsed) is "AM" then
				set afternoon to false
				-- trim from end of input date
				repeat until text -1 of date_unparsed is not in {"A", "M", "P", " "}
					set date_unparsed to trimLastChar(date_unparsed)
				end repeat
			else if (text -2 thru -1 of date_unparsed) is "PM" then
				set afternoon to true
				-- trim from end of input date
				repeat until text -1 of date_unparsed is not in {"A", "M", "P", " "}
					set date_unparsed to trimLastChar(date_unparsed)
				end repeat
			end if
			set date_parsed to text 1 thru 4 of date_unparsed -- YYYY
			set date_parsed to (date_parsed & (text 6 thru 7 of date_unparsed)) -- MM
			set date_parsed to (date_parsed & (text 9 thru 10 of date_unparsed)) --DD
			if the length of date_unparsed is 19 then
				-- parse double-digit hour hh
				set date_hour to (text 12 thru 13 of date_unparsed)
				if (date_hour as number) is less than 12 then
					if afternoon is true then
						set date_hour to (date_hour + 12)
					end if
				else if (date_hour as number) is 12 then
					if afternoon is false then
						set date_hour to "00" as string
					end if
				end if
				set date_parsed to (date_parsed & date_hour) -- hh
				set date_parsed to (date_parsed & (text 15 thru 16 of date_unparsed)) -- mm
				set date_parsed to (date_parsed & "." & (text 18 thru 19 of date_unparsed)) -- ss
			else if the length of date_unparsed is 18 then
				-- parse single-digit hour h
				set date_hour to (text 12 of date_unparsed)
				if afternoon is true then
					set date_hour to (date_hour + 12)
				else
					set date_hour to ("0" & date_hour)
				end if
				set date_parsed to (date_parsed & date_hour) -- hh
				set date_parsed to (date_parsed & (text 14 thru 15 of date_unparsed)) -- mm
				set date_parsed to (date_parsed & "." & (text 17 thru 18 of date_unparsed)) -- ss
			end if
			set output_file_path to (save_path & date_parsed & ".html")
			set shell_script to "touch -t " & date_parsed & space & quoted form of output_file_path & " ; setFile -a E " & quoted form of output_file_path & " ; Rez -a -o " & quoted form of output_file_path & space & set_to_open_file_with_textedit & "open -e " & quoted form of output_file_path
			-- create a new empty file, hide its file extension, set the file to open always with TextEdit, and then open the file in TextEdit
			do shell script shell_script
		end if
	end try
end run

on trimLastChar(theText)
	(*
	trimLastChar routine copied from https://stackoverflow.com/questions/32304097/applescript-remove-last-character-in-text-string
	*)
	if length of theText = 0 then
		error "Can't trim empty text." number -1728
	else if length of theText = 1 then
		return ""
	else
		return text 1 thru -2 of theText
	end if
end trimLastChar

on replaceText(someText, oldItem, newItem)
	(*
	replaceText routine copied from https://discussions.apple.com/thread/4588230
	replace all occurrences of oldItem with newItem
	parameters
		someText [text]: the text containing the item(s) to change
		oldItem [text, list of text]: the item to be replaced
		newItem [text]: the item to replace with
	returns [text]: the text with the item(s) replaced
	*)
	set {tempTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, oldItem}
	try
		set {itemList, AppleScript's text item delimiters} to {text items of someText, newItem}
		set {someText, AppleScript's text item delimiters} to {itemList as text, tempTID}
	on error errorMessage number errorNumber -- oops
		set AppleScript's text item delimiters to tempTID
		error errorMessage number errorNumber -- pass it on
	end try
	return someText
end replaceText