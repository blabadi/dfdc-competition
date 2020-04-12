echo "in page $1" 
for f in $(ls *.mp4 | sort | head -n $2 | tail -n $3); do
	mkdir ${f%.*}
      	ffmpeg -i $f -r 0.3 "${f%.*}/${f%.*}_%03d.jpg" > /dev/null 2>&1
	echo "processed video $f"
done
echo done page $1
