
# NOTES FOR MEOW-BIDS

## INSTALL dcm2niix
    git clone https://github.com/rordenlab/dcm2niix.git
    cd dcm2niix
    mkdir build && cd build
    cmake ..
    make

## INSTALL pypet2bids

    pip install pypet2bids

## RUN CONVERSION

    dcm2niix4pet ~/Documents/Research/Datasets/OpenNeuroPET-Demo_raw/source/SiemensBiographPETMR-NRU -d ~/Documents/Research/Datasets/BIDS/SiemensBiographPETMR-NRU --kwargs TimeZero=ScanStart Manufacturer=Siemens ManufacturersModelName=Biograph InstitutionName="Rigshospitalet, NRU, DK" BodyPart=Phantom Units=Bq/mL TracerName=none TracerRadionuclide=F18 InjectedRadioactivity=81.24 SpecificRadioactivity=13019.23 ModeOfAdministration=infusion FrameTimesStart=0 AcquisitionMode="list mode" ImageDecayCorrected=true ImageDecayCorrectionTime=0 AttenuationCorrection=MR-corrected FrameDuration=300 FrameTimesStart=0

## INSTALL bids-validator

    sudo apt install nodejs
    sudo apt install npm
    npm install -g bids-validator

## REFERENCES
https://www.nature.com/articles/sdata201644
https://static-curis.ku.dk/portal/files/308376588/PET_BIDS_an_extension_to_the_brain.pdf
https://github.com/bids-standard/bids-starter-kit/blob/main/src/tutorials/pet.md
https://reproducibility.stanford.edu/bids-tutorial-series-part-1a/

https://www.nitrc.org
david_marchant
1q2w3e4r5t6y