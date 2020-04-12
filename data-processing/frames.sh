echo $(pwd)
page_size=100
count=$(ls *.mp4 | wc -l)
pages=$((count / page_size))
last_page=$((count % page_size))
echo found $pages pages

for p in $(seq 1 $pages); do
        OFFSET=$((p * page_size))
	~/dfdc/dfdc_ds/fp.sh $p $OFFSET $page_size > fp.log 2>&1 &
done

echo doing last page of $last_page files
for f in $(ls *.mp4 | sort | tail -n $last_page); do
	mkdir ${f%.*}
        ffmpeg -i $f -r 0.3 "${f%.*}/${f%.*}_%03d.jpg" > /dev/null 2>&1
done

echo 'done'

