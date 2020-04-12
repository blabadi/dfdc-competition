if [ -z "$1" ]
  then
    echo "No part # supplied"
fi

if [ -z "$2" ]
  then
    echo "No short part # supplied"
fi
PART=$1
NUM=$2
cd ~/dfdc/dfdc_ds
mkdir part_$PART || echo dir exists
ZIP_FILE=./part_$PART/dfdc_train_part_$PART.zip
if [ ! -f "$ZIP_FILE" ]; then
	echo "downloading part $PART.."
	aws s3 cp s3://dfdc.noot/dfdc/dfdc_train_part_$PART.zip ./part_$PART
fi
cd part_$PART

echo 'unzipping..'
unzip -n -q dfdc_train_part_$PART.zip

echo 'done fetching and unzipping part'
cd dfdc_train_part_$NUM

echo $(pwd)
page_size=50
count=$(ls *.mp4 | wc -l)
images_count=$((count * 5))
echo "expect $images_count"
pages=$((count / page_size))
last_page=$((count % page_size))
echo found $pages pages

for p in $(seq 1 $pages); do
        echo "processing page $p"
       	OFFSET=$((p * page_size))
        ~/dfdc/dfdc_ds/fp.sh $p $OFFSET $page_size > fp.log 2>&1 &
	echo "submitted $p"
done

echo doing last page of $last_page files
for f in $(ls *.mp4 | sort | tail -n $last_page); do
        mkdir ${f%.*}
        ffmpeg -i $f -r 0.3 "${f%.*}/${f%.*}_%03d.jpg" > /dev/null 2>&1
done


# wait all bg to be done before exiting 
wait

echo "done processing"

echo "checking missed videos (ffmpeg failed):"
find . -type d -empty

# fix missed videos if any
for f in $(find . -type d -empty); do
        F=${f:2}
        ffmpeg -i ${F}.mp4 -r 0.3 "${F}/${F}_%03d.jpg" > /dev/null 2>&1
done

echo "checking again"
find . -type d -empty

# clean up the videos 
rm *.mp4
rm fp.log
rm ~/dfdc/dfdc_ds/part_$PART/dfdc_train_part_$PART.zip

# check the count of images [ num videos * 5 frames per vid ] == what we got
final_count=$(find . -type f -name "*.jpg" | wc -l)
echo "DONE !! result files: $final_count vs expected: $images_count"
