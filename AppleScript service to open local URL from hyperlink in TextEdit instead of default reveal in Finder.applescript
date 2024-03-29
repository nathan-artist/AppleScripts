-- This script, as part of an Automator service, opens a local URL (to a file or folder) from a hyperlink in TextEdit. TextEdit's default behavior when clicking on a file:/// hyperlink to a local URL is either (1) to bring the file's window to the front if the file has already been opened in the current TextEdit session or else (2) to reveal the file or folder in the Finder. Using this script as a service provides a third option: right-click (or control-click) on the link and then select the service from the pop-up/contextual services menu to open the file or folder directly. Or assign a keyboard shortcut to the service, then right-click (or control-click) on the link, press the escape key, and press the keyboard shortcut to open the file or folder directly. This service works because when you click on a hyperlink in TextEdit, TextEdit selects the link's text area, which the service passes to a temporary file before extracting and opening the hyperlink.
-- To create a service from this script: open Automator; create a new service; set the service to receive rich text in TextEdit (or in any application if you want to use the service outside of TextEdit); add the "New Text File" action to the workflow; change the settings of the "New Text File" action to: file format rich text, save as filename "OpenFileLinksFromRichText.rtf" in location "~/Library/Caches/TemporaryItems/", replacing existing files, with encoding "Unicode (UTF-8)"; add the "Run AppleScript" action to the workflow and select the "Ignore this action's input" checkbox in the "Run AppleScript" action; replace the content of the "Run AppleScript" action with this script (and replace the path to python3 in the script with the path on your machine); save the service.
-- To do: Currently this script only works when there is one hyperlink in the selected text. I want to modify the script so that it is possible to select multiple links to local files in TextEdit and open them in new TextEdit windows, but that would be such an increase in the complexity of the parsing that it would be better to replace the AppleScript with a Python script and use ready-made Python libraries. I don't write complex AppleScripts for the fun of it; I just want an easy way to accomplish a task!

set the_path to (do shell script "/usr/bin/textutil -inputencoding utf-8 -stdout -format rtf -convert html ~/Library/Caches/TemporaryItems/OpenFileLinksFromRichText.rtf | grep -o 'file:///[^\"]*' | /opt/local/bin/python3 -c \"import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));\" | perl -pe 's/&amp;/&/g;' -pe 's/^file:\\/\\///g;' -pe 'chomp'")
-- to extract the POSIX path, gets the clipboard as hex-encoded RTF from AppleScript since "pbpaste -Prefer rtf" never returns RTF as it should; then uses a perl command from https://stackoverflow.com/a/2548429 to transform AppleScript output to (non-hex-encoded) raw RTF; then uses textutil to transform RTF to HTML; then uses grep to extract the local URL; then uses a python command from https://stackoverflow.com/a/21693459 to decode the URL encoding; then uses perl to remove the "file://" prefix and the trailing newline characters
try
	set file_alias to POSIX file the_path as alias -- will fail silently if file does not exist
	do shell script "open " & quoted form of the_path
end try
