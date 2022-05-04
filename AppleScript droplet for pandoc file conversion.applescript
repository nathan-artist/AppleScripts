property script_title : "AppleScript droplet for pandoc file conversion"
property script_version : "3.3"
property pandoc_version : "2.18"

(*
DISCLAIMER
If you do not agree with the following terms, please do not use, install, modify or redistribute this script. This script is provided on an "AS IS" basis. We make no warranties, express or implied, regarding this script or its use and operation alone or in combination with other products. In no event shall we be liable for any special, indirect, incidental or consequential damages arising in any way out of the use, reproduction, modification and/or distribution of this script, however caused and whether under theory of contract, tort (including negligence), strict liability or otherwise, even if we have been advised of the possibility of such damage.
This script was not created by the creators of pandoc. We created it to fill our own need, which it does well, but it is not an especially robust script. Read the instructions and examine the script carefully before using it, and make backup copies of your files so that you can restore the files in case you make any mistakes.

INSTRUCTIONS
This AppleScript droplet is designed to make and run a shell script that uses pandoc (the "swiss-army knife" for document conversion) to convert one or more files whose icons are dragged onto the droplet icon in the Finder. The script converts multiple input files recursively, instead of concatenating multiple input files as pandoc does when run from the command line. We find this droplet to be much less tedious to use than the command line. To save the script as a droplet, open the script in Script Editor and save the script with file format: Application.

IMPORTANT REQUIREMENTS
Before trying to convert files, make sure that all input files are the same format, such as all markdown files or all html files. This script is designed to convert files of the same format. The script does not check the format of the input files, so it relies on you to accurately specify the format. The droplet only accepts files, not folders; folders are ignored.
Make sure that the character encoding of all input files is UTF-8. If you're not sure of the character encoding, in Terminal.app you can check the character encoding of a file by entering the command: file -I [filename]
This script was written for pandoc 2.16, so if you are using a newer or older version of pandoc you will want to change the list of input formats and output formats in the script to reflect the formats supported by your version of pandoc, and you will want to make sure that the syntax after "do shell script" is correct for your version of pandoc.
Before running the script you must install pandoc either directly from http://pandoc.org or using a package manager such as Fink, Homebrew, or MacPorts.
Before running the script, change the property pandoc_path below to reflect the path of the pandoc command on your computer. In Terminal.app you can check the path of the pandoc command by entering the command: type -a pandoc
*)

property pandoc_path : "/usr/local/bin" -- The folder containing pandoc

-- When the script is run without dragging files onto the droplet:
on run
	choose file with prompt "Which file(s) would you like to convert using Pandoc? If you select multiple files, all must have the same format." with multiple selections allowed
	open result
end run

-- When files are dragged onto the droplet:
on open dropped_files
	set userCanceled to true
	try
		activate
		-- Display a dialog box with a list of input formats and specify one. You can change the default item if you prefer a different one.
		set inputFormats to {"bibtex", "biblatex", "commonmark", "commonmark_x", "creole", "csljson", "csv", "docbook", "docx", "dokuwiki", "endnotexml", "epub", "fb2", "gfm", "haddock", "html", "ipynb", "jats", "jira", "json", "latex", "man", "markdown", "markdown_github", "markdown_mmd", "markdown_phpextra", "markdown_strict", "mediawiki", "muse", "native", "odt", "opml", "org", "ris", "rst", "rtf", "t2t", "textile", "tikiwiki", "twiki", "vimwiki"}
		set inputDialogResult to {choose from list inputFormats with title "Pandoc: Specify input format" with prompt "What is the format of the file(s) to be converted? (Note that markdown_github is deprecated in favor of gfm for GitHub-Flavored Markdown.)" default items "html"}
		set input_format to inputDialogResult as string
		-- Exit if cancel
		if input_format is in inputFormats then
			-- Display a dialog box with a list of output formats and specify one or more. You can change the default item if you prefer a different one.
			set outputFormats to {"asciidoc", "beamer", "bibtex", "biblatex", "commonmark", "commonmark_x", "context", "csljson", "docbook4", "docbook5", "docx", "dokuwiki", "dzslides", "epub2", "epub3", "fb2", "gfm", "haddock", "html4", "html5", "icml", "ipynb", "jats_archiving", "jats_articleauthoring", "jats_publishing", "jira", "json", "latex", "man", "markdown", "markdown_github", "markdown_mmd", "markdown_phpextra", "markdown_strict", "markua", "mediawiki", "ms", "muse", "native", "odt", "opendocument", "opml", "org", "plain", "pdf", "pptx", "revealjs", "rst", "rtf", "s5", "slideous", "slidy", "tei", "texinfo", "textile", "xwiki", "zimwiki"}
			set outputDialogResult to {choose from list outputFormats with title "Pandoc: Specify output format(s)" with prompt "Input format is " & input_format & ". What output format(s) do you want? (Note that markdown_github is deprecated in favor of gfm for GitHub-Flavored Markdown.)" default items "html5" with multiple selections allowed}
			set text item delimiters to space
			set output_format_words to words of (outputDialogResult as text)
			-- Exit if cancel
			if (first item of output_format_words) is in outputFormats then
				set text item delimiters to ", "
				set output_format_list to outputDialogResult as text
				-- Display a dialog box with specified input and output formats, so you can cancel if you made any mistakes and specify more command-line options via a text field. You can change the default answer if you prefer a different one.
				set optionsDialogResult to display dialog "Input format: " & input_format & return & return & "Output format(s): " & output_format_list & return & return & "If you would like to add more command-line options, add them carefully in the field below, for example:" & return & return & "Some reader options:" & return & "--indented-code-classes=CLASSES --default-image-extension=EXTENSION --metadata=KEY[:VAL] --preserve-tabs --tab-stop=NUMBER --track-changes=accept|reject|all --extract-media=DIR --shift-heading-level-by=X, where X=NUMBER-1" & return & return & "Some writer options:" & return & "--data-dir=DIRECTORY --defaults=FILE --standalone --wrap=auto|none|preserve --columns=NUMBER --toc (requires --standalone) --toc-depth=NUMBER --no-highlight --highlight-style=STYLE --resource-path=SEARCHPATH --template=FILE|URL --variable=KEY[:VAL]" & return & return & "Some options affecting specific writers:" & return & "--ascii -atx-headers --reference-links --reference-location=block|section|document --number-sections --number-offset=NUMBER[,NUMBER,...] --top-level-division=default|section|chapter|part --listings --incremental --slide-level=NUMBER --section-divs --email-obfuscation=none|javascript|references --id-prefix=STRING --css=URL --reference-doc=FILE --epub-cover-image=FILE --epub-metadata=FILE --epub-embed-font=FILE --epub-chapter-level=NUMBER --pdf-engine=pdflatex|lualatex|xelatex --pdf-engine-opt=STRING --bibliography=FILE --citeproc|--natbib|--biblatex --csl=FILE" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" default answer "--standalone" with title "Pandoc: Specify other options"
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
				-- Get the path and container and name of each input file
				set file_path to POSIX path of i
				tell application "System Events"
					set file_container to POSIX path of (container of i)
				end tell
				set file_name to the name of file_info
				-- Set the filename extension for each output format.
				repeat with o from 1 to the count of output_format_words
					set output_format to item o of output_format_words
					-- Some output file extensions include hyphenated prefixes because if the user selects multiple formats with the same extension we want to differentiate each format.
					if output_format is "asciidoc" then
						set output_extension to "-asciidoc.txt"
					end if
					if output_format is "beamer" then
						set output_extension to "-beamer.tex"
					end if
					if output_format is "bibtex" then
						set output_extension to ".bib"
					end if
					if output_format is "biblatex" then
						set output_extension to "-biblatex.bib"
					end if
					if output_format is "commonmark" then
						set output_extension to "-commonmark.md"
					end if
					if output_format is "commonmark_x" then
						set output_extension to "-commonmark_x.md"
					end if
					if output_format is "context" then
						set output_extension to "-context.tex"
					end if
					if output_format is "csljson" then
						set output_extension to "-csl.json"
					end if
					if output_format is "docbook4" then
						set output_extension to "-docbook4.xml"
					end if
					if output_format is "docbook5" then
						set output_extension to "-docbook5.xml"
					end if
					if output_format is "docx" then
						set output_extension to ".docx"
					end if
					if output_format is "dokuwiki" then
						set output_extension to "-dokuwiki.txt"
					end if
					if output_format is "dzslides" then
						set output_extension to "-dzslides.html"
					end if
					if output_format is "epub2" then
						set output_extension to "-epub2.epub"
					end if
					if output_format is "epub3" then
						set output_extension to ".epub"
					end if
					if output_format is "fb2" then
						set output_extension to ".fb2"
					end if
					if output_format is "gfm" then
						set output_extension to "-gfm.md"
					end if
					if output_format is "haddock" then
						set output_extension to "-haddock.hs"
					end if
					if output_format is "html4" then
						set output_extension to "-html4.html"
					end if
					if output_format is "html5" then
						set output_extension to ".html"
					end if
					if output_format is "icml" then
						set output_extension to ".icml"
					end if
					if output_format is "jats_archiving" then
						set output_extension to "-jats_archiving.xml"
					end if
					if output_format is "jats_articleauthoring" then
						set output_extension to "-jats_articleauthoring.xml"
					end if
					if output_format is "jats_publishing" then
						set output_extension to "-jats_publishing.xml"
					end if
					if output_format is "jira" then
						set output_extension to "-jira.txt"
					end if
					if output_format is "json" then
						set output_extension to ".json"
					end if
					if output_format is "latex" then
						set output_extension to ".tex"
					end if
					if output_format is "man" then
						set output_extension to ".man"
					end if
					if output_format is "markdown" then
						set output_extension to ".md"
					end if
					if output_format is "markdown_github" then
						set output_extension to "-github.md"
					end if
					if output_format is "markdown_mmd" then
						set output_extension to "-mmd.md"
					end if
					if output_format is "markdown_phpextra" then
						set output_extension to "-phpextra.md"
					end if
					if output_format is "markdown_strict" then
						set output_extension to "-strict.md"
					end if
					if output_format is "markua" then
						set output_extension to "-markua.md"
					end if
					if output_format is "mediawiki" then
						set output_extension to "-mediawiki.txt"
					end if
					if output_format is "ms" then
						set output_extension to ".ms"
					end if
					if output_format is "muse" then
						set output_extension to ".muse"
					end if
					if output_format is "native" then
						set output_extension to ".hs"
					end if
					if output_format is "odt" then
						set output_extension to ".odt"
					end if
					if output_format is "opendocument" then
						set output_extension to ".xml"
					end if
					if output_format is "opml" then
						set output_extension to ".opml"
					end if
					if output_format is "org" then
						set output_extension to ".org"
					end if
					if output_format is "plain" then
						set output_extension to ".txt"
					end if
					if output_format is "pptx" then
						set output_extension to ".pptx"
					end if
					if output_format is "revealjs" then
						set output_extension to "-revealjs.html"
					end if
					if output_format is "rst" then
						set output_extension to ".rst"
					end if
					if output_format is "rtf" then
						set output_extension to ".rtf"
					end if
					if output_format is "s5" then
						set output_extension to "-s5.html"
					end if
					if output_format is "slideous" then
						set output_extension to "-slideous.html"
					end if
					if output_format is "slidy" then
						set output_extension to "-slidy.html"
					end if
					if output_format is "tei" then
						set output_extension to "-tei.xml"
					end if
					if output_format is "texinfo" then
						set output_extension to ".texi"
					end if
					if output_format is "textile" then
						set output_extension to ".textile"
					end if
					if output_format is "xwiki" then
						set output_extension to "-xwiki.txt"
					end if
					if output_format is "zimwiki" then
						set output_extension to "-zimwiki.txt"
					end if
					set new_file_path to file_container & "/" & file_name & "-output" & output_extension
					-- Run pandoc for each output format.
					set shell_script to "export PATH=" & pandoc_path & ":$PATH ; cd " & quoted form of file_container & " ; " & pandoc_path & "/pandoc" & " -f " & input_format & " -t " & output_format & space & more_options & " -o " & quoted form of new_file_path & space & quoted form of file_path
					do shell script shell_script
				end repeat
			end if
		end repeat
	end if
end open
