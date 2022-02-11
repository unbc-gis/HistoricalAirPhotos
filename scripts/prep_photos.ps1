$root = "<absolute path to folder with airphotos>"

# EXIFTool is available from https://exiftool.org/exiftool-12.40.zip
# After downloading extract zip and rename exiftool(-k).exe to exiftool.exe (The k flag will freeze this script)
$exifTool = "<absolute path>\exiftool.exe"

# Coordinates should be stored in a file called gpsPoints.csv coloumn with the following columns: (Order of coloumns does not matter, extra coloumns are simply ignored)
#{PhotoNumb:<Image Base Name>, PointYDec:<Latitude dd>, PointXDec:<Longitude dd>, Flight_Alt:<Camera altitude in m>}

#Modify file extension, and seperator as needed; the sperator should appear exactly once in file name direcly between roll and frame (default is space)
$extsion = ".jpg"
$seperator = " "
#Geotagged Photos will be in a subfolder called sorted directly under root direcoty

#######################################################################################################################
$photos = Get-ChildItem -Path $root
$coords = Import-Csv -Path "$root\gpsPoints.csv"

foreach ($file in $photos){
    if ($file.Name -like "*$extension") {
        $folder = ($file.Name -Split $seperator, 2)[0]
        echo $file.BaseName
        $path = ($root + "\sorted\$folder")
        If(!(test-path $path))
        {
            New-Item -ItemType Directory -Force -Path $path
        }
        Copy-Item $file.PSPath -Destination "$path\$file"
        
                
        $loc = $($coords | Where-Object {$_.PhotoNumb -eq $file.BaseName})
        
        $lat = $loc.PointYDec
        $lon = $loc.PointXDec
        $alt = $loc.Flight_Alt
        
        echo "$lat, $lon"

        # EXIF standard requires DMS Coordinates no negitive values
        if ([int]$lat -gt 0) {
            $hemisphere = "N"
        }else {
            $meridian = "S"
            $lat = $lat.Substring(1)
        }

        if ($lon > 0) {
            $meridian = "E"
        }
        else {
            $meridian = "W"
            $lon = $lon.Substring(1)
        } 
        echo "$lat$hemisphhere, $lon$meridian, $alt m"

        Start-Process -FilePath $exifTool -ArgumentList "-GPSLongitudeRef=$meridian -GPSLongitude=$lon -GPSLatitudeRef=$hemisphere -GPSLatitude=$lat -GPSAltitude=$alt -overwrite_original ""$path\$file"""
    }
}
