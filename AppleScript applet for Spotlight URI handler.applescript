(*
Spotlight URI handler: This script, when saved as an application, creates a URI scheme ("spotlight:") that can be used to do a Spotlight search in the Finder from a URL (link) in any macOS application.

INSTRUCTIONS
Save this script from Script Editor as an application (applet), and then use a plain text editor to add the following lines to the "Info.plist" file inside the saved applet (which can be found by control-clicking on the saved applet and selecting "Show Package Contents") after the first occurrence of <dict>:

	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>Spotlight</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>spotlight</string>
			</array>
		</dict>
	</array>

Save the file and move the applet to another location to register the URI with macOS Launch Services.

This script assumes that the search scope preference in the Finder is set to the current folder. In Finder > Preferences... > Advanced, set "When performing a search" to: Search the Current Folder.

USAGE
After the "spotlight:" URI scheme, simply append any text exactly as you would enter it in the search field in the toolbar of Finder windows. For example, all of the following URIs are valid and functionally equivalent:

spotlight:tag:Red -tag:Blue kind:PDF
spotlight:tag:Red NOT tag:Blue AND kind:PDF
spotlight:tag:"Red" NOT tag:"Blue" AND kind:"PDF"

By default (without a searchpath argument) the search scope will be the whole computer. To narrow the search scope to a certain folder, after the "searchpath:" URI scheme append the full POSIX path (not a relative path) and an ampersand and the Spotlight query. There can be no ampersands in the search path unless they are manually encoded as "%26". For example:

spotlight:searchpath:/User/Username/Documents&tag:Red kind:PDF
spotlight:searchpath:/Volumes/Shared Drive&tag:Red kind:PDF

By the way, there are a LOT of Spotlight search keywords that can be used, so searches can be very precise. For example, see: http://www.macconfig.com/en/mac/2014/Unknown_Spotlight_Keywords_2014052001.html

Thanks to the following websites for guidance:
https://www.macosxautomation.com/applescript/linktrigger/
https://apple.stackexchange.com/q/308475
*)

on open location this_URL
	if (text 1 thru 10 of this_URL) is "spotlight:" then
		set the query_text to (text 11 thru -1 of this_URL)
		if (text 1 thru 11 of the query_text) is "searchpath:" then
			set x to the offset of "&" in the query_text
			set the search_path to (text 12 thru (x - 1) of the query_text)
			set the search_path to decodeText(search_path)
			set the query_text to (text from (x + 1) to -1 of the query_text)
			set no_search_path to false
		else
			set no_search_path to true
		end if
		set the query_text to decodeText(query_text)
		tell application "Finder"
			activate
			try
				if no_search_path then
					open computer container
					repeat until (target of front Finder window) is computer container
						delay 0.5
					end repeat
				else
					open ((POSIX file search_path) as alias)
					repeat until ((the target of front Finder window as alias) as text) is (((the POSIX file search_path) as alias) as text)
						delay 0.5
					end repeat
				end if
			on error
				open computer container
				repeat until (target of front Finder window) is computer container
					delay 0.5
				end repeat
			end try
		end tell
		tell application "System Events"
			keystroke "f" using command down
			keystroke query_text
			delay 1.5
			key code 53 -- esc key to dispel drop-down menu
		end tell
	end if
end open location

on decodeChars(these_chars)
	(*
	decodeChars routine copied from https://www.macosxautomation.com/applescript/sbrt/sbrt-08.html
	decode a three-character hex string
*)
	copy these_chars to {indentifying_char, multiplier_char, remainder_char}
	set the hex_list to "123456789ABCDEF"
	if the multiplier_char is in "ABCDEF" then
		set the multiplier_amt to the offset of the multiplier_char in the hex_list
	else
		set the multiplier_amt to the multiplier_char as integer
	end if
	if the remainder_char is in "ABCDEF" then
		set the remainder_amt to the offset of the remainder_char in the hex_list
	else
		set the remainder_amt to the remainder_char as integer
	end if
	set the ASCII_num to (multiplier_amt * 16) + remainder_amt
	return (ASCII character ASCII_num)
end decodeChars

on decodeText(this_text)
	(*
	decodeText routine copied from https://www.macosxautomation.com/applescript/sbrt/sbrt-08.html
	decode text strings using decodeChars routine
*)
	set flag_A to false
	set flag_B to false
	set temp_char to ""
	set the character_list to {}
	repeat with this_char in this_text
		set this_char to the contents of this_char
		if this_char is "%" then
			set flag_A to true
		else if flag_A is true then
			set the temp_char to this_char
			set flag_A to false
			set flag_B to true
		else if flag_B is true then
			set the end of the character_list to my decodeChars(("%" & temp_char & this_char) as string)
			set the temp_char to ""
			set flag_A to false
			set flag_B to false
		else
			set the end of the character_list to this_char
		end if
	end repeat
	return the character_list as string
end decodeText