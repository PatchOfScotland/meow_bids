
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

## Get source data
