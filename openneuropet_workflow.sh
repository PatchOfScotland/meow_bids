#!/bin/bash

###### Setup ------------------------------------------------------------------
# Universal variables
input_base="$HOME/Documents/Research/Datasets/MRI_data/sourcedata"
int_dir="tmp"
output_dir="$HOME/Documents/Research/Python/meow_bids/MRI_data/generated"
bids_starter_kit="bids-starter-kit"

# Get clean output
rm -r $output_dir

mkdir $int_dir
mkdir -p $output_dir

# Get templates repo and clone pet specific example
#git clone git@github.com:bids-standard/bids-starter-kit.git $bids_starter_kit

###### Setup bids structure and conversion ------------------------------------
cp $bids_starter_kit/templates/* $output_dir/

# Possibly not needed?
rm -rf $output_dir/samples*
rm $output_dir/README.MD

# Setup experiment description files
echo "This dataset consists of a single subject scanned using MRI (T1-weighted) in the morning, at noon, and in the afternoon." > $output_dir/README
echo "participant_id	weight
sub-01	85" > $output_dir/participants.tsv
echo -e "{
  \"participant_id\":{
    \"LongName\":\"Participant Id\",
    \"Description\":\"label identifying a particular subject\"
  },
  \"weight\":{
    \"LongName\":\"Weight\"
  }
}" > $output_dir/participants.json
echo -e "{\"BIDSVersion\":\"1.6.0\",
    \"License\":\"CCO license\",
    \"Name\":\"Martin Norgaard's brain\",
    \"Authors\":[\"Martin Norgaard\", \"Martin Norgaard\"],
    \"Acknowledgements\":\"Martin Norgaard\",
    \"HowToAcknowledge\":\"Martin Norgaard\",
    \"Funding\":[\"0$\"],
    \"DatasetDOI\":\"\"}" > $output_dir/dataset_description.json

base=$(pwd)
# Rename files and delete some more unneeded files
cd $output_dir/sub-01/ses-01/anat
for i in *ShortExample*; do 
    mv "$i" "`echo $i | sed 's/ShortExample//'`"; 
done
mv "sub-01_ses-01_task-_pet.json" "sub-01_ses-01_pet.json"; 
for i in *Autosampler*; do 
    rm $i; 
done
cd $base

###### Convert dcm data to bids compatible niix data --------------------------
# Get each session in turn

for i in "3 ses-01" "5 ses-02" "8 ses-03"
do
    set -- $i # convert the "tuple" into the param args $1 $2...

    input_dir=$input_base/$1
    
    # Clone pet specific example
    mkdir -p $output_dir/sub-01/$2/anat
    rm -rf $output_dir/sub-01/$2/anat/*Full*

    dcm2niix4pet $input_dir -d $int_dir
    # Copy over converted data
    base=$(pwd)
    cd $int_dir
    for i in *.json; do 
        mv $i $output_dir/sub-01/$2/anat/sub-01_$2_T1w.json;
    done
    for i in *.nii.gz; do 
        mv $i $output_dir/sub-01/$2/anat/sub-01_$2_T1w.nii.gz;
        gzip -d $output_dir/sub-01/$2/anat/sub-01_$2_T1w.nii.gz;
    done
    cd $base

done

# Get an updated dataset description
#cp "$input_base/dataset_description.json" "$output_dir/"

## Some manual edits to json files
#sed -i 's/"PlasmaAvail": ""/"PlasmaAvail": false/' $output_dir/sub-01/ses-01/anat/sub-01_ses-01_recording-Manual_blood.json
#sed -i 's/"MetaboliteAvail": ""/"MetaboliteAvail": false/' $output_dir/sub-01/ses-01/anat/sub-01_ses-01_recording-Manual_blood.json
#sed -i 's/"MetaboliteMethod": ""/"MetaboliteMethod": "Not used"/' $output_dir/sub-01/ses-01/anat/sub-01_ses-01_recording-Manual_blood.json
#sed -i 's/"MetaboliteRecoveryCorrectionApplied": ""/"MetaboliteRecoveryCorrectionApplied": false/' $output_dir/sub-01/ses-01/anat/sub-01_ses-01_recording-Manual_blood.json
#sed -i 's/"DispersionCorrected": ""/"DispersionCorrected": false/' $output_dir/sub-01/ses-01/anat/sub-01_ses-01_recording-Manual_blood.json
#sed -i 's/"WholeBloodAvail": ""/"WholeBloodAvail": false/' $output_dir/sub-01/ses-01/anat/sub-01_ses-01_recording-Manual_blood.json

###### Cleanup after generation -----------------------------------------------
# Cleanup working directories
#yes | rm -r $int_dir $bids_starter_kit

###### Validate the dataset ---------------------------------------------------
bids-validator $output_dir

valid=$?

if [ $valid == 1 ]
then
    echo "bids dataset is not valid. Aborting analysis"
    exit $valid
fi

