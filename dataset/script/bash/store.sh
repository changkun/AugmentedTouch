for ((i=1; i<17; i++)); do
    if [ $i -lt 10 ]
    then
        mongoimport --db touchmotion --collection info --file '../../data/0'$i'/info.json'
    else
        mongoimport --db touchmotion --collection info --file '../../data/'$i'/info.json'
    fi
done
