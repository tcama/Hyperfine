#!/bin/bash
#
# This code creates a version of the MS-SEG-2016 data where all subjects have been regsitered
# the ADNI_normal_template
#
# Usage: ./scripts/MS_SEG-2016-registration.sh
#
# Thomas Campbell Arnold 
# tcarnold@seas.upenn.edu
# 
# 9/26/2019 - created

TEMPLATE_DIR=./tools/ADNI_normal_atlas/
DATA_DIR=./data/MS-SEG-2016/
OUT_DIR=./data/MS-SEG-2016-registered/

mkdir ${OUT_DIR}

for SUB_DIR in ${DATA_DIR}*/ ; do
    
    SUB=$(basename -- "$SUB_DIR")
    echo "processing: $SUB"
    mkdir ${OUT_DIR}${SUB}/
    
    # Registration of MNI-Atlas to Nick Oasis templat
    antsRegistration \
    --dimensionality 3 \
    --float 0 \
    --output ${OUT_DIR}${SUB}/reg2ADNI_ \
    --interpolation Linear \
    --use-histogram-matching 0 \
    --initial-moving-transform [${TEMPLATE_DIR}T_template0.nii.gz,${SUB_DIR}3DFLAIR.nii.gz,1] \
    --transform Rigid[0.1] \
    --metric MI[${TEMPLATE_DIR}T_template0.nii.gz,${SUB_DIR}3DFLAIR.nii.gz,1,32,Regular,0.25] \
    --convergence [1000x500x250x100,1e-6,10] \
    --shrink-factors 8x4x2x1 \
    --smoothing-sigmas 3x2x1x0vox 
    # --transform Affine[0.1] \
    # --metric MI[${TEMPLATE_DIR}T_template0.nii.gz,${SUB_DIR}3DFLAIR.nii.gz,1,32,Regular,0.25] \
    # --convergence [1000x500x250x100,1e-6,10] \
    # --shrink-factors 8x4x2x1 \
    # --smoothing-sigmas 3x2x1x0vox \
    # --transform SyN[0.1,3,0] \
    # --metric CC[${TEMPLATE_DIR}T_template0.nii.gz,${SUB_DIR}3DFLAIR.nii.gz,1,4] \
    # --convergence [100x70x50x20,1e-6,10] \
    # --shrink-factors 8x4x2x1 \
    # --smoothing-sigmas 3x2x1x0vox

    # transform image to template space
    antsApplyTransforms \
    -d 3 \
    -i ${SUB_DIR}3DFLAIR.nii.gz \
    -o ${OUT_DIR}${SUB}/reg2ADNI_3DFLAIR.nii.gz \
    -t ${OUT_DIR}${SUB}/reg2ADNI_0GenericAffine.mat \
    -r ${TEMPLATE_DIR}T_template0.nii.gz \
    -n Linear
    # -t ${OUT_DIR}reg2ADNI_1Warp.nii.gz \
    
    # transform segmentation to template spacesc
    antsApplyTransforms \
    -d 3 \
    -i ${SUB_DIR}Consensus.nii.gz \
    -o ${OUT_DIR}${SUB}/reg2ADNI_seg.nii.gz \
    -t ${OUT_DIR}${SUB}/reg2ADNI_0GenericAffine.mat \
    -r ${TEMPLATE_DIR}T_template0.nii.gz \
    -n NearestNeighbor
    
done
