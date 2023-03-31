#!/bin/bash

###### Setup ------------------------------------------------------------------
# Universal variables
input_base="$HOME/Documents/Research/Datasets/OpenNeuroPET-Phantoms"
int_dir="tmp"
output_base="OpenNeuroPET_phantoms"
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
        mv $i $base/$output_dir/sub-01/ses-01/pet/sub-01_ses-01_pet.json;
    done
    for i in *.nii.gz; do 
        mv $i $base/$output_dir/sub-01/ses-01/pet/sub-01_ses-01_pet.nii.gz;
    done
    cd $base

    # Get an updated dataset description
    cp "$input_base/dataset_description.json" "$output_dir/"

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
input_experiment="sourcedata/SiemensHRRT-NRU"
input_dir=$input_base/$input_experiment
input_v=$input_dir/XCal-Hrrt-2022.04.21.15.43.05_EM_3D.v
int_nii=$int_dir/sub-SiemensHRRTNRU_pet.nii
output_experiment="SiemensHRRT-NRU-XCal-Hrrt"
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
ReconFilterType="none"

finalisation_function

###### NRU - Siemens Biograph -------------------------------------------------
# Experiment variables
input_experiment="sourcedata/SiemensBiographPETMR-NRU"
input_dir=$input_base/$input_experiment
output_experiment="SiemensBiographPETMR-NRU"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer=Siemens \
ManufacturersModelName=Biograph \
InstitutionName="Rigshospitalet, NRU, DK" \
BodyPart=Phantom \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=81.24 \
SpecificRadioactivity=1.3019e+04 \
ModeOfAdministration="infusion" \
AcquisitionMode="list mode" \
FrameTimesStart="[0]" \
FrameDuration=[300] \
ImageDecayCorrected="true" \
ImageDecayCorrectionTime=0 \
DecayCorrectionFactor=[1] \
AttenuationCorrection="MR-corrected" \
InjectionStart=0

finalisation_function

###### Århus University Hospital- - GE Discovery-------------------------------
# Experiment variables
input_experiment="sourcedata/GeneralElectricDiscoveryPETCT-Aarhus"
input_dir=$input_base/$input_experiment
output_experiment="GeneralElectricDiscoveryPETCT-Aarhus"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="General Electric" \
ManufacturersModelName="Discovery" \
InstitutionName="Århus University Hospital, DK" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=25.5 \
SpecificRadioactivity=4.5213e+03 \
ModeOfAdministration="infusion" \
AcquisitionMode="list mode" \
ImageDecayCorrected=True \
ImageDecayCorrectionTime=0 \
AttenuationCorrection="MR-corrected" \
FrameDuration=[1200] \
ReconFilterSize=0 \
ReconFilterType='none' \
FrameTimesStart=[0] \
ReconMethodParameterLabels="[none]" \
ReconMethodParameterUnits="[none]" \
ReconMethodParameterValues="[0]"

finalisation_function

###### Århus University Hospital- - GE Sigma PETMR-----------------------------
# Experiment variables
input_experiment="sourcedata/GeneralElectricSignaPETMR-Aarhus"
input_dir=$input_base/$input_experiment
output_experiment="GeneralElectricSignaPETMR-Aarhus"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="General Electric" \
ManufacturersModelName="Signa PETMR" \
InstitutionName="Århus University Hospital, DK" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=21 \
SpecificRadioactivity=3.7234e+03 \
ModeOfAdministration="infusion" \
FrameDuration=[600] \
FrameTimesStart=[0] \
AcquisitionMode="list mode" \
ImageDecayCorrected="true" \
ImageDecayCorrectionTime=0 \
AttenuationCorrection="MR-corrected" \
ReconFilterType='unknown' \
ReconFilterSize=1 \
ReconMethodParameterLabels="[none, none]" \
ReconMethodParameterUnits="[none, none]" \
ReconMethodParameterValues="[0, 0]"

finalisation_function

###### Amsterdam UMC - Ingenuity PETCT ----------------------------------------
# Experiment variables
input_experiment="sourcedata/PhilipsIngenuityPETCT-AmsterdamUMC"
input_dir=$input_base/$input_experiment
output_experiment="PhilipsIngenuityPETCT-AmsterdamUMC"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="General Electric" \
ManufacturersModelName="Signa PETMR" \
InstitutionName="Århus University Hospital, DK" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=21 \
SpecificRadioactivity=3.7234e+03 \
ModeOfAdministration="infusion" \
FrameDuration=[600] \
FrameTimesStart=[0] \
AcquisitionMode="list mode" \
ImageDecayCorrected="true" \
ImageDecayCorrectionTime=0 \
AttenuationCorrection="MR-corrected" \
ReconFilterType='unknown' \
ReconFilterSize=1 \
ReconMethodParameterLabels="[none, none]" \
ReconMethodParameterUnits="[none, none]" \
ReconMethodParameterValues="[0, 0]"

finalisation_function

###### Amsterdam UMC - Ingenuity PETMR ----------------------------------------
# Experiment variables
input_experiment="sourcedata/PhilipsIngenuityPETMR-AmsterdamUMC"
input_dir=$input_base/$input_experiment
output_experiment="PhilipsIngenuityPETMR-AmsterdamUMC"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="General Electric" \
ManufacturersModelName="Signa PETMR" \
InstitutionName="Århus University Hospital, DK" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=21 \
SpecificRadioactivity=3.7234e+03 \
ModeOfAdministration="infusion" \
FrameDuration=[600] \
FrameTimesStart=[0] \
AcquisitionMode="list mode" \
ImageDecayCorrected="true" \
ImageDecayCorrectionTime=0 \
AttenuationCorrection="MR-corrected" \
ReconFilterType='unknown' \
ReconFilterSize=1 \
ReconMethodParameterLabels="[none, none]" \
ReconMethodParameterUnits="[none, none]" \
ReconMethodParameterValues="[0, 0]"

finalisation_function

###### Amsterdam UMC - Vereos PETCT ----------------------------------------
# Experiment variables
input_experiment="sourcedata/PhillipsVereosPETCT-AmsterdamUMC"
input_dir=$input_base/$input_experiment
output_experiment="PhilipsVereosPETCT-AmsterdamUMC"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="Philips Medical Systems" \
ManufacturersModelName="Vereos PET/CT" \
InstitutionName="AmsterdamUMC,VUmc" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="11C-PIB" \
TracerRadionuclide="C11" \
InjectedRadioactivity=202.5 \
SpecificRadioactivity=2.1791e+04 \
ModeOfAdministration="infusion" \
AcquisitionMode="list mode" \
ImageDecayCorrected="True" \
ImageDecayCorrectionTime=0 \
ReconFilterType="None" \
ReconFilterSize=0 \
AttenuationCorrection="CTAC-SG" \
ScatterCorrectionMethod="SS-SIMUL" \
RandomsCorrectionMethod="DLYD" \
ReconstructionMethod="OSEMi3s15" \
TimeZero="11:40:24"

finalisation_function

###### NIMH Bethesda - Siemens Biograph ---------------------------------------
# Experiment variables
input_experiment="sourcedata/SiemensBiographPETMR-NIMH/AC_TOF"
input_dir=$input_base/$input_experiment
output_experiment="SiemensBiographPETMR-NIMH-AC_TOF"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="Siemens" \
ManufacturersModelName="Biograph - petmct2" \
InstitutionName="NIH Clinical Center, USA" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=44.4 \
SpecificRadioactivity=7.1154e+03 \
ModeOfAdministration="infusion" \
AcquisitionMode="list mode" \
ImageDecayCorrected="True" \
ImageDecayCorrectionTime=0 \
FrameTimesStart=[0] \
FrameDuration=[300] \
AttenuationCorrection="MR-corrected" \
RandomsCorrectionMethod="DLYD" \
ReconFilterSize=1 

finalisation_function

###### NIMH Bethesda - GE Signa -----------------------------------------------
# Experiment variables
input_experiment="sourcedata/GeneralElectricSignaPETMR-NIMH"
input_dir=$input_base/$input_experiment
output_experiment="GeneralElectricSignaPETMR-NIMH"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
TimeZero="14:08:45" \
Manufacturer="GE MEDICAL SYSTEMS" \
ManufacturersModelName="SIGNA PET/MR" \
InstitutionName="NIH Clinical Center, USA" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="Gallium citrate" \
TracerRadionuclide="Germanium68" \
InjectedRadioactivity=1 \
SpecificRadioactivity=23423.75 \
ModeOfAdministration="infusion" \
FrameTimesStart=0 \
AcquisitionMode="list mode" \
ImageDecayCorrected="False" \
FrameTimesStart="[0]" \
ImageDecayCorrectionTime=0 \
ReconFilterType="n/a" \
ReconFilterSize=1 \
ReconMethodParameterLabels="[none, none]" \
ReconMethodParameterUnits="[none, none]" \
ReconMethodParameterValues="[0, 0]"

finalisation_function

###### NIMH Bethesda - GE Advance 2D ------------------------------------------
# Experiment variables
input_experiment="sourcedata/GeneralElectricAdvance-NIMH/2d_unif_lt_ramp"
input_dir=$input_base/$input_experiment
output_experiment="GeneralElectricAdvance-NIMH-2d_unif_lt_ramp"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="GE MEDICAL SYSTEMS" \
ManufacturersModelName="GE Advance" \
InstitutionName="NIH Clinical Center, USA" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=75.8500 \
InjectionStart=0 \
SpecificRadioactivity=418713.8 \
ModeOfAdministration="infusion" \
FrameTimesStart="[0]" \
ImageDecayCorrected='true' \
AcquisitionMode='list mode' \
ImageDecayCorrectionTime="0" \
ScatterCorrectionMethod="Convolution subtraction" \
FrameDuration=[98000] \
ScanStart="0" \
ReconMethodParameterLabels="[none]" \
ReconMethodParameterUnits="[none]" \
ReconMethodParameterValues="[0, 0]"

finalisation_function

###### NIMH Bethesda - GE Advance long trans ----------------------------------
# Experiment variables
input_experiment="sourcedata/GeneralElectricAdvance-NIMH/long_trans"
input_dir=$input_base/$input_experiment
output_experiment="GeneralElectricAdvance-NIMH-long_trans"
output_dir=$output_base/$output_experiment

initialisation_function

# Convert dcm data to bids compatible niix data
dcm2niix4pet $input_dir -d $int_dir --kwargs \
Manufacturer="GE MEDICAL SYSTEMS" \
ManufacturersModelName="GE Advance" \
InstitutionName="NIH Clinical Center, USA" \
BodyPart="Phantom" \
Units="Bq/mL" \
TracerName="FDG" \
TracerRadionuclide="F18" \
InjectedRadioactivity=75.8500 \
InjectionStart=0 \
SpecificRadioactivity=418713.8 \
ModeOfAdministration="infusion" \
FrameTimesStart="[0]" \
ImageDecayCorrected='true' \
AcquisitionMode='list mode' \
ImageDecayCorrectionTime="0" \
ScatterCorrectionMethod="Convolution subtraction" \
FrameDuration=[98000] \
ScanStart="0" \
ReconMethodParameterLabels="[none]" \
ReconMethodParameterUnits="[none]" \
ReconMethodParameterValues="[0, 0]" \
AttenuationCorrection="measured"

finalisation_function

###### Cleanup ----------------------------------------------------------------
# Cleanup working directories
yes | rm -r $int_dir $bids_starter_kit
