#!/bin/bash

###### Setup ------------------------------------------------------------------
# Universal variables
input_base="/data/MRI_data/sourcedata"
int_dir="tmp"
bids_dir="/data/MRI_data/generated"
bids_starter_kit="bids-starter-kit"
analysis_dir="/data/MRI_data/analysed"

# Get clean output
rm -r $bids_dir

mkdir $int_dir
mkdir -p $bids_dir

# Get templates repo and clone pet specific example
git clone git@github.com:bids-standard/bids-starter-kit.git $bids_starter_kit

###### Setup bids structure and conversion ------------------------------------
cp $bids_starter_kit/templates/* $bids_dir/

# Possibly not needed?
rm -rf $bids_dir/samples*
rm $bids_dir/README.MD

# Setup experiment description files
echo "This dataset consists of a single subject scanned using MRI (T1-weighted) in the morning, at noon, and in the afternoon." > $bids_dir/README
echo "participant_id	weight
sub-01	85" > $bids_dir/participants.tsv
echo -e "{
  \"participant_id\":{
    \"LongName\":\"Participant Id\",
    \"Description\":\"label identifying a particular subject\"
  },
  \"weight\":{
    \"LongName\":\"Weight\"
  }
}" > $bids_dir/participants.json
echo -e "{\"BIDSVersion\":\"1.6.0\",
    \"License\":\"CCO license\",
    \"Name\":\"Martin Norgaard's brain\",
    \"Authors\":[\"Martin Norgaard\", \"Martin Norgaard\"],
    \"Acknowledgements\":\"Martin Norgaard\",
    \"HowToAcknowledge\":\"Martin Norgaard\",
    \"Funding\":[\"0$\"],
    \"DatasetDOI\":\"\"}" > $bids_dir/dataset_description.json

#base=$(pwd)
## Rename files and delete some more unneeded files
#cd $output_dir/sub-01/ses-01/anat
#for i in *ShortExample*; do 
#    mv "$i" "`echo $i | sed 's/ShortExample//'`"; 
#done
#mv "sub-01_ses-01_task-_pet.json" "sub-01_ses-01_pet.json"; 
#for i in *Autosampler*; do 
#    rm $i; 
#done
#cd $base

###### Convert dcm data to bids compatible niix data --------------------------
# Get each session in turn

for i in "3 ses-01" "5 ses-02" "8 ses-03"
do
    set -- $i # convert the "tuple" into the param args $1 $2...

    input_dir=$input_base/$1
    
    # Clone pet specific example
    mkdir -p $bids_dir/sub-01/$2/anat
    rm -rf $bids_dir/sub-01/$2/anat/*Full*

    dcm2niix4pet $input_dir -d $int_dir
    # Copy over converted data
    base=$(pwd)
    cd $int_dir
    for i in *.json; do 
        mv $i $bids_dir/sub-01/$2/anat/sub-01_$2_T1w.json;
    done
    for i in *.nii.gz; do 
        mv $i $bids_dir/sub-01/$2/anat/sub-01_$2_T1w.nii.gz;
        gzip -d $bids_dir/sub-01/$2/anat/sub-01_$2_T1w.nii.gz;
    done
    cd $base

done

###### Cleanup after generation -----------------------------------------------
# Cleanup working directories
yes | rm -r $int_dir $bids_starter_kit

###### Validate the dataset ---------------------------------------------------
bids-validator $bids_dir

valid=$?

if [ $valid == 1 ]
then
    echo "bids dataset is not valid. Aborting analysis"
    exit $valid
fi

###### Run the analysis -------------------------------------------------------
docker run -it --rm -v $bids_dir:/data:ro -v $analysis_dir:/out nipreps/mriqc:latest /data /out participant --participant_label sub-01
