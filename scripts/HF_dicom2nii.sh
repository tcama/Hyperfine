#!/bin/bash
#
# This script takes in a subjects folder containing DICOM images for the Hyperfine research group and converts them into nifti files.
#
# Input:    folder for a HF subject from radiology
#
# Usage:    HF_dicom2nii.sh data/832913_Stein_Hyperfine/P001_07.29.19/
#
# Steps:    1. get filename information and make output directory
#			2. unzip main folder and subfolders
#			Process clinical data
#			3. convert files with no extension to dicom files.
#			4. convert dicom to nifti files
#			5. move to output directory
#			Process Hyperfine data
#			6. convert dicom to nifti files
#			7. move to output directory
#
# Output:   structured Nifti data
#
# Thomas Campbell Arnold 
# tcarnold@seas.upenn.edu
#
# 10/7/2019 - created
# 10/16/2019 - currently working for some subjects, but doesn't have useful names for clinical scans. Want to use sequence info from .json file.

#### step 1 ####

# get folder name
filename=$(basename -- "$1")
MAIN_NAME="${filename%/}"

# setup output structure
OUT_DIR=./data/$MAIN_NAME/
mkdir $OUT_DIR

echo $MAIN_NAME
echo $1
echo ${OUT_DIR}

#### step 2 ####

# unzip main folder
unzip -q -d $OUT_DIR $1 

# loop through and unzip subfolder
for folder in $1*.zip
do
	unzip -q -d $OUT_DIR $folder
done

#### NOT CURRENTLY USED ####

# Tries to get useful naming information from files using regex, not currently used/working
for file in $(find $OUT_DIR/*/DICOMDIR/* -type f)
do
	prefix="$(c3d "${file}" -info-full | grep -P -o "(?<=103e =)[ A-Za-z0-9]*")"
	echo $prefix
done

#### CLINICAL IMAGING  ####

#### step 3 ####

# convert and extensionless files into DICOM extensions
for file in $(find $OUT_DIR/*/DICOM/* -type f)
do
	mv ${file} ${file}.dcm
done

#### step 4 ####

# convert DICOM to Nifti
for folder in $(find $OUT_DIR/*/DICOM/* -type d)
do
	var=$(ls ${folder}/*.dcm) # get all dicom files in folder
	N=1 # index of file to read in
	file=$(echo $var | cut -d " " -f $N) # select the first file name
	dcm2niix ${file} # make dicom file
done

#### step 5 ####

# grab Nifti files and put in new folder
N=4
mkdir ${OUT_DIR}/NII/
for file in $(find ${OUT_DIR}*/DICOM/ -regex ".*\.\(nii\|json\)")
do
	date_folder=$(echo $file | cut -d "/" -f $N)
	mkdir ${OUT_DIR}/NII/${date_folder}/
	mv ${file} ${OUT_DIR}/NII/${date_folder}/
	#mv *.nii *.json ${OUT_DIR}${MAIN_NAME}${date_folder}/NII/
	##mv ${file} ${file}.dcm
	#perfix="$(c3d ${file} -info-full | grep -P -o "(?<=0008\|0008\ =\ )[\S]*")"
	#prefix=${prefix//\\/_}
	#echo $prefix
done

#### HYPERFINE ####

#### step 6 ####

# convert DICOM to Nifti
for file in $(find ${OUT_DIR}*/DICOMDIR/* -type f)
do
	#dcm2niix ${file} # Don't understand, but dcm2niix on any single HF image converts all. Results in multiples if looped through all.
	echo ${file}
done
dcm2niix ${file} # Just dcm2niix the last file, should convert all

#### step 7 ####

# grab Nifti files and put in new folder
N=4
for file in $(find ${OUT_DIR}*/DICOMDIR/ -regex ".*\.\(nii\|json\)")
do
	date_folder=$(echo $file | cut -d "/" -f $N)
	mkdir ${OUT_DIR}/NII/${date_folder}/
	mv ${file} ${OUT_DIR}/NII/${date_folder}/
done

## convert and extensionless files into DICOM extensions
#for file in $(find data/P007_9.23.19/*/DICOM/*.nii -type f)
#do
#	date_folder=echo $file | cut -d "/" -f $N
#	mkdir ${OUT_DIR}${MAIN_NAME}${date_folder}/NII/
#	mv ${file} ${OUT_DIR}${MAIN_NAME}${date_folder}/NII/
#	#mv *.nii *.json ${OUT_DIR}${MAIN_NAME}${date_folder}/NII/
#	##mv ${file} ${file}.dcm
#	#perfix="$(c3d ${file} -info-full | grep -P -o "(?<=0008\|0008\ =\ )[\S]*")"
#	#prefix=${prefix//\\/_}
#	#echo $prefix 
#done

# get simple name for each image from dicom
#foo="$(c3d data/P007_9.23.19/patient-P007__20190923T183435Z__5d89103bc2f834.04453144/DICOMDIR/2.25.181304855282563927982948749217359938722.dcm -info-full | grep -P -o "(?<=0008|103e =)[ A-Za-z0-9]*")"

