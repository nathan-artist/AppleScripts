-- This script takes plain text from the clipboard in Markdown format, converts the text to Rich Text Format (RTF) using Pandoc and Apple's Cocoa text system, and then pastes the rich text into the active field or window. Pandoc must be installed first from https://pandoc.org

on run
	do shell script "LANG=en_US.UTF-8 pbpaste -Prefer txt | /usr/local/bin/pandoc -f markdown-smart -t html | /usr/bin/textutil -inputencoding utf-8 -stdin -stdout -format html -convert rtf | /usr/bin/sed 's/fcharset0 Times-Roman/fcharset0 Arial/' | pbcopy ; osascript -l AppleScript -e 'tell application \"System Events\" to keystroke \"v\" using command down'"
	-- gets the clipboard as text; then uses pandoc to transform markdown to HTML (and without using pandoc's smart typographical conversion); then uses textutil to transform HTML to RTF since I want Apple's Cocoa RTF that textutil produces; then uses sed to change the font to Arial; then puts the rich text on the clipboard and pastes it with command-v
end run