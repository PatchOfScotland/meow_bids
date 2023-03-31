for i in OpenNeuroPET_phantoms/*; do 
    echo $i
    bids-validator $i; 
done