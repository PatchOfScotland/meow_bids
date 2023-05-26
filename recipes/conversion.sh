#!/bin/bash

input_base="$HOME/Documents/Research/Datasets/MRI_data/sourcedata"
int_dir="tmp"
output_base="$HOME/Documents/Research/Python/meow_bids/MRI_data/generated"
bids_starter_kit="bids-starter-kit"

experiment=$(cut -d'/' -f 3 <<<$input_base)
session=$(cut -d'/' -f 4 <<<$input_base)

output_dir="${output_base}/${experiment}"

# Get templates repo and clone pet specific example
mkdir -p $output_dir
git clone git@github.com:bids-standard/bids-starter-kit.git $bids_starter_kit
cp $bids_starter_kit/templates/* $output_dir/

rm -rf $output_dir/samples*
rm $output_dir/README.MD

# Setup experiment description files
echo "This dataset consists of a single subject scanned using MRI (T1-weighted) in the morning, at noon, and in the afternoon." > $output_dir/README

echo "participant_id	weight" > $output_dir/participants.tsv
echo "sub-01	85"             >> $output_dir/participants.tsv

echo "{"                                                              > $output_dir/participants.json
echo "  \"participant_id\":{"                                         >> $output_dir/participants.json
echo "    \"LongName\":\"Participant Id\","                           >> $output_dir/participants.json
echo "    \"Description\":\"label identifying a particular subject\"" >> $output_dir/participants.json
echo "  },"                                                           >> $output_dir/participants.json
echo "  \"weight\":{"                                                 >> $output_dir/participants.json
echo "    \"LongName\":\"Weight\""                                    >> $output_dir/participants.json
echo "  }"                                                            >> $output_dir/participants.json
echo "}"                                                              >> $output_dir/participants.json

echo "{"                                                            > $output_dir/dataset_description.json
echo "    \"BIDSVersion\":\"1.6.0\","                               >> $output_dir/dataset_description.json
echo "    \"License\":\"CCO license\","                             >> $output_dir/dataset_description.json
echo "    \"Name\":\"Martin Norgaard's brain\","                    >> $output_dir/dataset_description.json
echo "    \"Authors\":[\"Martin Norgaard\", \"Martin Norgaard\"],"  >> $output_dir/dataset_description.json
echo "    \"Acknowledgements\":\"Martin Norgaard\","                >> $output_dir/dataset_description.json
echo "    \"HowToAcknowledge\":\"Martin Norgaard\","                >> $output_dir/dataset_description.json
echo "    \"Funding\":[\"0$\"],"                                    >> $output_dir/dataset_description.json
echo "    \"DatasetDOI\":\"\""                                      >> $output_dir/dataset_description.json
echo "}"                                                            >> $output_dir/dataset_description.json

input_experiment_dir=$(cut -d'/' -f -3 <<<$input_base)
sub_dirs=$(find $input_experiment_dir/* -maxdepth 0 -type d)
session_count=0

# Get each session in turn
for sub_dir in $sub_dirs
do
    session_count=$(($session_count+1))
    ses="ses-0$session_count"

    # Clone pet specific example
    mkdir -p "$output_dir/sub-01/${ses}/anat"
    rm -rf "$output_dir/sub-01/${ses}/anat/*Full*"

    dcm2niix4pet $sub_dir -d $int_dir
    # Copy over converted data
    base=$(pwd)
    cd $int_dir
    for i in *.json; do 
        mv $i "$output_dir/sub-01/${ses}/anat/sub-01_${ses}_T1w.json"
    done
    for i in *.nii.gz; do 
        mv $i "$output_dir/sub-01/${ses}/anat/sub-01_${ses}_T1w.nii.gz"
        gzip -d -f "$output_dir/sub-01/${ses}/anat/sub-01_${ses}_T1w.nii.gz"
    done
    cd $base
done


# Cleanup working directories
yes | rm -r $int_dir 
#yes | rm -r $bids_starter_kit

