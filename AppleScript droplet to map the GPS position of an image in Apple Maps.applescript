-- This script, when saved as an application, uses ExifTool by Phil Harvey (a free and open-source command-line application) to extract the GPS position from an image's EXIF data and then displays that position in Apple Maps. In other words, run the app by clicking on it and choosing an image file or else by dragging an image file onto the app, and if the image has a GPS position in its EXIF data then Maps.app will open with that position as a dropped pin. If multiple files are dropped onto the app, only the first item is processed. This script assumes that exiftool is installed at /opt/local/bin/exiftool. If exiftool is installed elsewhere, change the property exiftool_path to the proper path.

-- path to exiftool:
property exiftool_path : "/opt/local/bin/exiftool"

on run
	try
		tell application "System Events"
			activate
			set chosen_file to choose file with prompt "Choose an image to display its GPS position (if it has one) in Apple Maps:" of type "public.image"
		end tell
		exifGPS(chosen_file)
	end try
end run

on open dragged_items
	exifGPS(dragged_items)
end open

on exifGPS(item_list)
	try
		set item_list to item_list as list
		set first_file to the first item in item_list
		set file_path to (the POSIX path of first_file as string)
		set shell_script to exiftool_path & " -f -n -p '$gpslatitude,$gpslongitude' " & quoted form of file_path
		set gps_position to (do shell script shell_script) as string
		if gps_position is not "" then
			if gps_position is not "-,-" then
				open location "http://maps.apple.com/?ll=" & gps_position
			end if
		end if
	end try
end exifGPS
