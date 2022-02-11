# Historical Air Photo Structure From Motion

## Prepare Photos:

-   Coordinates should be stored in a file called gpsPoints.csv coloumn with the following columns: (Order of coloumns does not matter, extra coloumns are simply ignored)

    -   PhotoNumb:\<Image Base Name\>

    -   PointYDec:\<Latitude dd\>

    -   PointXDec:\<Longitude dd\>

    -   Flight_Alt:\<Camera altitude in m\>

-   Download EXIFTool from <https://exiftool.org/>

    -   After downloading extract zip and rename exiftool(-k).exe to exiftool.exe

-   Open the PowerShell Script scripts/prep_photos.ps1

    -   Modify lines 1 & 5, if your files are not jpg or use a different separator than space " " between roll and frame adjust lines 11 & 12.

    -   As an administrator open Group Policy Editor and enable { Computer Configuration \> Policies \> Administrative Templates \> Windows Components \> Windows PowerShell \> Turn on script execution } and set the Policy to Unrestricted. \*(After running script you may wish to set this back to disabled or a more restrictive policy).

    -   Run the PowerShell Script

-   (Optional) Enhance photos with Photoshop, there is an example action for Image Processor in the Photoshop sub-directory of particular use is the "Haze Removal" tool integrated into Adobe Camera Raw.

## Process in Agisoft Metashape Pro

Ensure you have version 1.8.1 as a minimum before proceeding, version 1.7.x was incapable of achieving suitable alignment.

-   Load photos either working with a single roll at a time, or placing rolls into separate chunks.

-   Mask Photos

    -   In the photos panel (if not visible: View \> Photos), enable show masks to make it easier to track progress \
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-24E6221D.png)

    -   Select the photo area using the selection tools, it is important that the fiducials be completely removed. The Rectangle is the fast way, the Intelligent Scissors will preserve more photo in some cases (see example below). \
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-C1591BAD.png)

    -   Right Click inside the selected area and "Invert Selection"\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-4FEC6686.png)

    -   Right Click in the new selected area, and "Add Selection"\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-CE5EBC40.png)

    -   You should now see a mask with the photo in white, repeat for all photos.\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-09EA5BF0.png)

-   Align Photos

    -   Start a Medium Accuracy, with these photo-sets a higher setting is not necessarily better. If you need to run again Make sure to select Reset current alignment on subsequent runs. Additionally under Advanced increase the Key point and Tie point limits\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-D7C3196B.png)

    -   To check results enable the basemap\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-B9F59A75.png)\
        We want to find an alignment where the blue camera is above the photos, and relatively close to the surface. \
        \
        Bad Alignment (Cameras below point cloud):\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-A46E2D71.png)\
        Bad Alignment (Alignment off Axis):\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-68043A63.png)\
        Acceptable (Still a little off Axis but likely as good as it will get):\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-CDBCE175.png)

-   Build Dense Cloud

    -   Calculate Dense Cloud at "Ultra High" using "Moderate" depth filtering, and "Calculate Point Confidence"

    -   Filter the Dense Cloud (Expect to see a 50% reduction in number of points)

        -   Tools \> Dense Cloud \> Filter by Confidence \| Min: 0, Max: 1

        -   Draw a selection box over all visible points, and press delete

        -   Tools \> Dense Cloud \> Reset Filter to see what is left

-   Build DEM

    -   Pick a projected coordinate reference system otherwise defaults are good. (If you are planning to share via web map such as <https://arc.gis.unbc.ca> use EPSG:3857 (Pseudo Web Mercator).

    -   If the Alignment and Filtering were successful the output should have crisp edges:\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-DD81BAC6.png)

-   Build Orthomosaic

    -   Default settings are good, export as TIFF make sure Alpha channel is enabled.\
        ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-8FA1A547.png)

## Georeference output

Due to the poor quality of the GPS (and off axis alignment) the exported TIFF is close to the correct location but not quite right. This can be done in either QGIS or ArcGIS Pro, ArcGIS Pro is recommended for it's ease of use and generally better compatibility with the exports from Metashape (QGIS is more likely to understand the CRS, ArcGIS is more likely to render correctly, the CRS is easier to correct).

-   [***Before***]{.ul} adding the image to an ArcGIS Pro Map, navigate to the file in the catalog pane, right click for properties, click the globe by Spatial Reference, and set it to the same EPSG code you used in Metashape.\
    ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-183AD94C.png)\
    ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-A32BE5E0.png)

-   Set the base map to imagery

-   Go to Imagery \> Georeference

    -   Manual:

        -   Add control-points clicking a feature on the orthomosaic, hiding it, clicking the same feature on the base map, then show the ortho again. Repeat a minimum of 10 points that should be spread evenly and as far apart as possible on the image

            -   Bridges are a good target as they are easy to spot and generally do not move

        -   Good Control Point Layout![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-9E6D8E0E.png)\

        -   Misplaced Control Point:\
            If there is a misplaced point, it should be removed, this image is identical to the one above except with an extra poorly placed point, notice how you can now see green targets as the alignment could not pull points to their proper place the Ground Control Point Table allows you to toggle points on and off to troubleshoot alignment issues.\
            ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-FF6ABA82.png)\
            ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-E3EABFBD.png)

        -   Under Transformation Try both "Spline" (option not available until you have 10 GCPs) and "Adjust"

            -   A great way to check quality is to set the orthomsaic to 50% and look for ghosting on roads\
                \
                Good:\
                ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-EE018491.png)\
                \
                Bad:\
                ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-B15DBF2E.png)

        -   If the preview looks good, press Save to overwrite the file

    -   Automatic (If you already have a referenced image with the same coverage) :

        -   Make sure pre existing image is enabled, and directly below the new image in the Drawing Order.

        -   Press "Auto Georeference", if it aligns well you may simply save and your are done.

        -   If it does not align well and there is no obvious quick fix (ie remove a couple particularly far points, or add a point to an edge that had none detects) the best course of action is to delete all control points and perform the manual georeference process. The tightly packed control points of auto can cause strange warping when combined with manual points.

-   Finish Up: After you save your referenced changes right click on the TIFF in catalog and build pyramids and calculate statistics to provide optimal performance when sharing imagery. \
    ![](https://raw.githubusercontent.com/unbc-gis/HistoricalAirPhotos/main/screenshots/paste-859FB561.png)
