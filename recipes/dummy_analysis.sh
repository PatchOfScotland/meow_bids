#!/bin/bash

analysing_dir="/home/patch/Documents/Research/Python/meow_bids/meow/analysing"
result_dir="/home/patch/Documents/Research/Python/meow_bids/MRI_data/validation"
dataset=""

echo "Analysing data in $analysing_dir"

rsync -a $analysing_dir $result_dir && rm -r $analysing_dir
touch $result_dir/$dataset/README
