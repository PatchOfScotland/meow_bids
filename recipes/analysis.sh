#!/bin/bash

analysing_dir="/home/patch/Documents/Research/Python/meow_bids/meow/analysing"
result_dir="/home/patch/Documents/Research/Python/meow_bids/MRI_data/validation"
dataset=""
base=""

echo "Analysing data in $analysing_dir"

# -----------------------------------------------------------------------------
#bids_dir=
#subject=
# TODO sort out subject
# docker run -it --rm -v $analysing_dir:/data:ro -v $result_dir:/out nipreps/mriqc:latest /data /out participant --participant_label $subject
docker run -it --rm -v $base/$analysing_dir:/data:ro -v $base/$result_dir:/out nipreps/mriqc:latest /data /out participant

# EXAMPLE
#docker run -it --rm -v /data/MRI_data/generated:/data:ro -v /data/MRI_data/analysed:/out nipreps/mriqc:latest /data /out participant --participant_label sub-01
# -----------------------------------------------------------------------------

#rsync -a $analysing_dir $result_dir && rm -r $analysing_dir
touch $result_dir/$dataset/README
