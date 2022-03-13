-- This script takes rich text from the clipboard in Rich Text Format (RTF), converts the text to Markdown using Apple's Cocoa text system and Pandoc, and then pastes the Markdown-formatted plain text into the active field or window. The script informs the user if what's on the clipboard is not RTF. Pandoc must be installed first from https://pandoc.org

on run
	set clipboard_is_rtf to true
	try
		the clipboard as "RTF "
	on error
		set clipboard_is_rtf to false
		beep
		display dialog "What's on the clipboard is not RTF!" buttons {"OK"} default button {"OK"}
	end try
	if clipboard_is_rtf then
		do shell script "LANG=en_US.UTF-8 osascript -l AppleScript -e 'the clipboard as \"RTF \"' | perl -ne 'print chr foreach unpack(\"C*\",pack(\"H*\",substr($_,11,-3)))' | /usr/bin/textutil -inputencoding utf-8 -stdin -stdout -format rtf -convert html | /usr/local/bin/pandoc -f html -t markdown_strict-raw_html --wrap=preserve | perl -pe 's/\\\\\\[/[/g;' -pe 's/\\\\\\]/]/g;' | perl -0777 -pe 's/\\n\\n/  \\n/g;' | perl -0777 -pe 's/  \\n    \\n/\\n\\n/g;' | LANG=en_US.UTF-8 pbcopy ; osascript -l AppleScript -e 'tell application \"System Events\" to keystroke \"v\" using command down'"
		-- gets the clipboard as hex-encoded RTF from AppleScript since "pbpaste -Prefer rtf" never returns RTF as it should; then uses a perl command from https://stackoverflow.com/a/2548429 to transform AppleScript output to (non-hex-encoded) raw RTF; then uses textutil to transform RTF to HTML since textutil is more accurate than pandoc when converting Apple's Cocoa RTF that I want to convert; then uses pandoc to transform HTML to markdown_strict (and without raw_html since textutil produces extra HTML elements that I don't want in the output); then uses perl to remove backslash-escapes from square brackets and to remove extra linebreaks that are generally present due to the "Preserve white space" option in TextEdit, which produces much of the RTF that I want to convert; then puts the markdown on the clipboard and pastes it with command-v
	end if
end run
