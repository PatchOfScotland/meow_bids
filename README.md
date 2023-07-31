# meow_bids
An example scientific MEOW pipeline, using BIDS neuroimaging data. This example 
will send notifications to a localy hosted email server that can be started 
with:

    sudo python3 -m smtpd -c DebuggingServer -n localhost:1025

The workflow itself can be started with:

    python3 setup_meow_workflow.py

Comments have been added to setup_meow_workflow.py, explaining the workflow 
process

Note that software installs found in notes.md will need to be followed before 
workflow will run.