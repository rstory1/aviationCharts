#!/bin/bash
set -eu                # Always put this in Bourne shell scripts
IFS="`printf '\n\t'`"  # Always put this in Bourne shell scripts

#Get command line parameters
originalRastersDirectory="$1"
destinationRoot="$2"
chartType="$3"

if [ "$#" -ne 3 ] ; then
  echo "Usage: $0 SOURCE_DIRECTORY destinationRoot chartType" >&2
  exit 1
fi


#For files that have a version in their name, this is where the links to the lastest version
#will be stored (step 1)
linkedRastersDirectory="$destinationRoot/sourceRasters/$chartType/"

#Where expanded rasters are stored (step 2)
expandedRastersDirectory="$destinationRoot/expandedRasters/$chartType/"

#Where clipped rasters are stored (step 3)
clippedRastersDirectory="$destinationRoot/clippedRasters/$chartType/"

#Where the polygons for clipping are stored
clippingShapesDirectory="$destinationRoot/clippingShapes/$chartType/"



if [ ! -d $originalRastersDirectory ]; then
    echo "$originalRastersDirectory doesn't exist"
    exit 1
fi

if [ ! -d $linkedRastersDirectory ]; then
    echo "$linkedRastersDirectory doesn't exist"
    exit 1
fi

if [ ! -d $expandedRastersDirectory ]; then
    echo "$expandedRastersDirectory doesn't exist"
    exit 1
fi

if [ ! -d $clippedRastersDirectory ]; then
    echo "$clippedRastersDirectory doesn't exist"
    exit 1
fi


cd $originalRastersDirectory
#Ignore unzipping errors
set +e
#Unzip all of the charts
echo Unzipping $chartType files
unzip -qq -u -j "*.zip" "*.tif"
#Restore quit on error
set -e

#Remove current links if any exist
#FILTER will be empty if no .tifs
FILTER=$(find $linkedRastersDirectory/ -type l \( -name "*.tif" \) )

if [[ ! -z ${FILTER} ]]; then
    echo "Deleting $chartType  links"
#     echo $FILTER
    rm $FILTER
fi

#Link latest revision of chart as a base name
echo Linking $chartType files
shopt -s nullglob	
for f in *.tif
do
	#Replace spaces in name with _
	newName=($(printf $f | sed 's/\s/_/g'))

	#Strip off the series number
	newName=($(printf $newName | sed --regexp-extended 's/_[0-9]+\./\./ig'))

	#If names are sorted properly, this will link latest version
	#BUG TODO make the preference of latest revision explicit
# 	echo "Linking $f -> $linkedRastersDirectory/$newName"
	ln -s -f -r "$f" $linkedRastersDirectory/$newName
	touch -h -r "$f" $linkedRastersDirectory$newName
done