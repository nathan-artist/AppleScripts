property script_title : "AppleScript droplet for pandoc file conversion"
property script_version : "1.1"
property pandoc_version : "1.15.1"

(*
DISCLAIMER
If you do not agree with the following terms, please do not use, install, modify or redistribute this script. This script is provided on an "AS IS" basis. We make no warranties, express or implied, regarding this script or its use and operation alone or in combination with other products. In no event shall we be liable for any special, indirect, incidental or consequential damages arising in any way out of the use, reproduction, modification and/or distribution of this script, however caused and whether under theory of contract, tort (including negligence), strict liability or otherwise, even if we have been advised of the possibility of such damage.
This script was not created by the creators of pandoc. We created it to fill our own need, which it does well, but it is not an especially robust script. Read the instructions and examine the script carefully before using it, and make backup copies of your files so that you can restore the files in case you make any mistakes.

INSTRUCTIONS
This AppleScript droplet is designed to make and run a shell script that uses pandoc (the "swiss-army knife" for document conversion) to convert one or more files whose icons are dragged onto the droplet icon in the OS X Finder. The script converts multiple input files recursively, instead of concatenating multiple input files as pandoc does when run from the command line. We find this droplet to be much less tedious to use than the command line. To save the script as a droplet, open the script in Script Editor and save the script with file format: Application.

IMPORTANT REQUIREMENTS
Before trying to convert files, make sure that all input files are the same format, such as all markdown files or all html files. This script is designed to convert files of the same format. The script does not check the format of the input files, so it relies on you to accurately specify the format. The droplet only accepts files, not folders; folders are ignored.
Make sure that the character encoding of all input files is UTF-8. If you're not sure of the character encoding, in Terminal.app you can check the character encoding of a file by entering the command: file -I [filename]
Make sure that all input files have filename extensions (for example: .html, .rtf). It is OK if the extensions are hidden in the Finder; just make sure that each file has a filename extension, hidden or not. Make sure that there are no periods (except for the period before the extension) in the filenames of the input files. Make sure that there are no quotation marks (or other forbidden characters that would make the shell script fail) in the filenames.
This script was written for pandoc 1.15.1, so if you are using a newer or older version of pandoc you will want to change the list of input formats and output formats in the script to reflect the formats supported by your version of pandoc, and you will want to make sure that the syntax after "do shell script" is correct for your version of pandoc.
Before running the script you must install pandoc either directly from http://pandoc.org or using (our preferred method) a package manager such as Fink, Homebrew, or MacPorts.
Before running the script, change the property pandoc_path below to reflect the path of the pandoc command on your computer. In Terminal.app you can check the path of the pandoc command by entering the command: type -a pandoc
*)

property pandoc_path : "/usr/local/bin/pandoc"

-- When the script is run without dragging files onto the droplet:
on run
	choose file with prompt "Which file(s) would you like to convert using Pandoc? If you select multiple files, all must have the same format." with multiple selections allowed
	open result
end run

-- When files are dragged onto the droplet:
on open dropped_files
	set userCanceled to true
	try
		-- Display a dialog box with a list of input formats and specify one. You can change the default item if you prefer a different one.
		set inputFormats to {"native", "json", "markdown", "markdown_strict", "markdown_phpextra", "markdown_github", "markdown_mmd", "commonmark", "textile", "rst", "html", "docbook", "t2t", "docx", "odt", "epub", "opml", "org", "mediawiki", "twiki", "haddock", "latex"}
		set inputDialogResult to {choose from list inputFormats with title "Pandoc: Specify input format" with prompt "What is the format of the file(s) to be converted?" default items "html"}
		set input_format to inputDialogResult as string
		-- Exit if cancel
		if input_format is in inputFormats then
			-- Display a dialog box with a list of output formats and specify one or more. You can change the default item if you prefer a different one.
			set outputFormats to {"native", "json", "markdown", "markdown_strict", "markdown_phpextra", "markdown_github", "markdown_mmd", "commonmark", "rst", "html", "html5", "latex", "beamer", "context", "man", "mediawiki", "dokuwiki", "textile", "org", "texinfo", "opml", "docbook", "opendocument", "odt", "docx", "haddock", "rtf", "epub", "epub3", "fb2", "asciidoc", "icml", "slidy", "slideous", "dzslides", "revealjs", "s5"}
			set outputDialogResult to {choose from list outputFormats with title "Pandoc: Specify output format(s)" with prompt "Input format is " & input_format & ". What output format(s) do you want?" default items "docx" with multiple selections allowed}
			set {text_delimiters, my text item delimiters} to {my text item delimiters, space}
			set output_format_words to words of (outputDialogResult as text)
			-- Exit if cancel
			if (first item of output_format_words) is in outputFormats then
				set {text_delimiters, my text item delimiters} to {my text item delimiters, ", "}
				set output_format_list to outputDialogResult as text
				-- Display a dialog box with specified input and output formats, so you can cancel if you made any mistakes and specify more command-line options via a text field. You can change the default answer if you prefer a different one.
				set optionsDialogResult to display dialog "Input format: " & input_format & return & return & "Output format(s): " & output_format_list & return & return & "If you would like to add more command-line options, add them in the field below, for example:" & return & return & "Some reader options:" & return & "--parse-raw --smart --old-dashes --base-header-level=NUMBER --indented-code-classes=CLASSES --default-image-extension=EXTENSION --metadata=KEY[:VAL] --normalize --preserve-tabs --tab-stop=NUMBER --track-changes=accept|reject|all --extract-media=DIR" & return & return & "Some writer options:" & return & "--data-dir=DIRECTORY --standalone --no-wrap --columns=NUMBER --toc --toc-depth=NUMBER --no-highlight --highlight-style=STYLE" & return & return & "Some options affecting specific writers:" & return & "--ascii --reference-links --chapters --number-sections --number-offset=NUMBER[,NUMBER,...] --no-tex-ligatures --listings --incremental --slide-level=NUMBER --section-divs --email-obfuscation=none|javascript|references --id-prefix=STRING --css=URL --latex-engine=pdflatex|lualatex|xelatex --latex-engine-opt=STRING --bibliography=FILE" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" default answer "--standalone" with title "Pandoc: Specify other options"
				-- Exit if cancel
				if button returned of optionsDialogResult is "OK" then
					set more_options to text returned of optionsDialogResult
					set userCanceled to false
				end if
			end if
		end if
	end try
	-- Process files dropped onto the applet.
	if userCanceled is false then
		repeat with i in dropped_files
			set the file_info to info for i
			-- Exclude folders.
			if the folder of file_info is false then
				-- Get the path, name, and short name of each input file, assuming there is only one period in the filename.
				set file_path to POSIX path of i
				tell application "System Events"
					set file_container to POSIX path of (container of i)
				end tell
				set file_name to the name of file_info
				set {text_delimiters, my text item delimiters} to {my text item delimiters, "."}
				set file_short_name to first text item of file_name
				-- Set the filename extension for each output format.
				repeat with o from 1 to the count of output_format_words
					set output_format to item o of output_format_words
					if output_format is "native" then
						set output_extension to ".hs"
					end if
					if output_format is "haddock" then
						set output_extension to "-haddock.hs"
					end if
					if output_format is "json" then
						set output_extension to ".json"
					end if
					if output_format is "plain" then
						set output_extension to ".txt"
					end if
					if output_format is "mediawiki" then
						set output_extension to "-mediawiki.txt"
					end if
					if output_format is "dokuwiki" then
						set output_extension to "-dokuwiki.txt"
					end if
					if output_format is "asciidoc" then
						set output_extension to "-asciidoc.txt"
					end if
					if output_format is "markdown" then
						set output_extension to ".md"
					end if
					if output_format is "markdown_strict" then
						set output_extension to "-strict.md"
					end if
					if output_format is "markdown_phpextra" then
						set output_extension to "-phpextra.md"
					end if
					if output_format is "markdown_github" then
						set output_extension to "-github.md"
					end if
					if output_format is "markdown_mmd" then
						set output_extension to "-mmd.md"
					end if
					if output_format is "commonmark" then
						set output_extension to "-commonmark.md"
					end if
					if output_format is "rst" then
						set output_extension to ".rst"
					end if
					if output_format is "html" then
						set output_extension to ".html"
					end if
					if output_format is "html5" then
						set output_extension to "-html5.html"
					end if
					if output_format is "slidy" then
						set output_extension to "-slidy.html"
					end if
					if output_format is "slideous" then
						set output_extension to "-slideous.html"
					end if
					if output_format is "dzslides" then
						set output_extension to "-dzslides.html"
					end if
					if output_format is "revealjs" then
						set output_extension to "-revealjs.html"
					end if
					if output_format is "s5" then
						set output_extension to "-s5.html"
					end if
					if output_format is "latex" then
						set output_extension to ".tex"
					end if
					if output_format is "beamer" then
						set output_extension to "-beamer.tex"
					end if
					if output_format is "context" then
						set output_extension to "-context.tex"
					end if
					if output_format is "rst" then
						set output_extension to ".rst"
					end if
					if output_format is "man" then
						set output_extension to ".man"
					end if
					if output_format is "textile" then
						set output_extension to ".textile"
					end if
					if output_format is "org" then
						set output_extension to ".org"
					end if
					if output_format is "texinfo" then
						set output_extension to ".texi"
					end if
					if output_format is "opml" then
						set output_extension to ".opml"
					end if
					if output_format is "docbook" then
						set output_extension to ".db"
					end if
					if output_format is "opendocument" then
						set output_extension to ".xml"
					end if
					if output_format is "odt" then
						set output_extension to ".odt"
					end if
					if output_format is "docx" then
						set output_extension to ".docx"
					end if
					if output_format is "rtf" then
						set output_extension to ".rtf"
					end if
					if output_format is "epub" then
						set output_extension to ".epub"
					end if
					if output_format is "epub3" then
						set output_extension to "-epub3.epub"
					end if
					if output_format is "fb2" then
						set output_extension to ".fb2"
					end if
					if output_format is "icml" then
						set output_extension to ".icml"
					end if
					-- Run pandoc for each output format.
					set shell_script to pandoc_path & " -f " & input_format & " -t " & output_format & space & more_options & " -o " & "'" & file_container & "/" & file_short_name & "-output" & output_extension & "'" & space & quoted form of file_path
					do shell script shell_script
				end repeat
			end if
		end repeat
	end if
end open
