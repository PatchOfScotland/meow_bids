#!/bin/bash

validating_dir="/home/patch/Documents/Research/Python/meow_bids/MRI_data/validation"
analysing_dir="/home/patch/Documents/Research/Python/meow_bids/meow/analysis"
user_dir="/home/patch/Documents/Research/Python/meow_bids/meow/user"
dataset=""

echo "Validating data in $validating_dir"

bids-validator $validating_dir

valid=$?

if [ $valid == 0 ]
then
    # If valid then send for analysis
    echo "validation passed. Sending for analysis"
    rsync -a $validating_dir $analysing_dir && rm -r $validating_dir
    touch $analysing_dir/$dataset/README
else
    # If invalid then send to user
    echo "bids dataset is not valid. Sending to user"
    rsync -a $validating_dir $user_dir && rm -r $validating_dir
    touch $user_dir/$dataset/README
fi
