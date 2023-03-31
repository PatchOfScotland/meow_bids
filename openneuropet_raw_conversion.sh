!/bin/bash

###### Setup ------------------------------------------------------------------
# Universal variables
input_base="/data/bids/PET_Data_raw"
int_dir="tmp"
output_base="/data/bids/OpenNeuroPET_PET_Data_raw"
bids_starter_kit="bids-starter-kit"

# Get clean output
rm -r $output_base

mkdir $int_dir

# Get templates repo and clone pet specific example
git clone git@github.com:bids-standard/bids-starter-kit.git $bids_starter_kit

# Generic function for setting up bids structure and conversion
initialisation_function() {
# Clone pet specific example
mkdir -p $output_dir/sub-01/ses-01/pet
cp -r $bids_starter_kit/templates/sub-01/ses-01/pet $output_dir/sub-01/ses-01/
cp $bids_starter_kit/templates/* $output_dir/
rm -rf $output_dir/sub-01/ses-01/pet/*Full*
mv $output_dir/README.MD $output_dir/README

# Possibly not needed?
rm -rf $output_dir/samples*

base=$(pwd)
# Rename files and delete some more unneeded files
cd $output_dir/sub-01/ses-01/pet
for i in *ShortExample*; do 
    mv "$i" "`echo $i | sed 's/ShortExample//'`"; 
done
mv "sub-01_ses-01_task-_pet.json" "sub-01_ses-01_pet.json"; 
for i in *Autosampler*; do 
    rm $i; 
done
cd $base
}

# Generic function for cleaning and moving bids data into final structure
finalisation_function() {
    # Copy over converted data
    base=$(pwd)
    cd $int_dir
    for i in *.json; do 
        mv $i $output_dir/sub-01/ses-01/pet/sub-01_ses-01_pet.json;
    done
    for i in *.nii.gz; do 
        mv $i $output_dir/sub-01/ses-01/pet/sub-01_ses-01_pet.nii.gz;
    done
    cd $base

    # Get an updated dataset description
    cp "$input_base/publish_to_openneuro/dataset_description.json" "$output_dir/"

    ## Some manual edits to json files
    sed -i 's/"PlasmaAvail": ""/"PlasmaAvail": false/' $output_dir/sub-01/ses-01/pet/sub-01_ses-01_recording-Manual_blood.json
    sed -i 's/"MetaboliteAvail": ""/"MetaboliteAvail": false/' $output_dir/sub-01/ses-01/pet/sub-01_ses-01_recording-Manual_blood.json
    sed -i 's/"MetaboliteMethod": ""/"MetaboliteMethod": "Not used"/' $output_dir/sub-01/ses-01/pet/sub-01_ses-01_recording-Manual_blood.json
    sed -i 's/"MetaboliteRecoveryCorrectionApplied": ""/"MetaboliteRecoveryCorrectionApplied": false/' $output_dir/sub-01/ses-01/pet/sub-01_ses-01_recording-Manual_blood.json
    sed -i 's/"DispersionCorrected": ""/"DispersionCorrected": false/' $output_dir/sub-01/ses-01/pet/sub-01_ses-01_recording-Manual_blood.json
    sed -i 's/"WholeBloodAvail": ""/"WholeBloodAvail": false/' $output_dir/sub-01/ses-01/pet/sub-01_ses-01_recording-Manual_blood.json
}

###### NRU - Siemens HRRT -----------------------------------------------------
# Experiment variables
input_experiment="cimbi36"
input_dir=$input_base/$input_experiment
input_v=$input_dir/Gris_102_19_2skan-2019.04.30.13.04.41_em_3d.v
int_nii=$int_dir/Gris_102_19_2skan-2019.04.30.13.04.41_em_3d.nii
output_experiment="SiemensHRRT-NRU-XCal-HRRT"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
ecatpet2bids $input_v --nifti $int_nii --convert --kwargs \
Manufacturer=Siemens \
ManufacturersModelName=HRRT \
InstitutionName="Rigshospitalet, NRU, DK" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName=FDG \
TracerRadionuclide=F18 \
InjectedRadioactivity=81.24 \
SpecificRadioactivity="1.3019e+04" \
ModeOfAdministration=infusion \
AcquisitionMode="list mode" \
ImageDecayCorrected="true" \
ImageDecayCorrectionTime=0 \
ReconFilterSize=0 \
AttenuationCorrection="10-min transmission scan" \
SpecificRadioactivityUnits="Bq" \
ScanStart=0 \
InjectionStart=0 \
InjectedRadioactivityUnits='Bq' \
ReconFilterType="none" \
PharmaceuticalDoseTime=0

finalisation_function

##### Cleanup ----------------------------------------------------------------
# Cleanup working directories
yes | rm -r $int_dir $bids_starter_kit
