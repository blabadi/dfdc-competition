cd ./part_23/dfdc_train_part_23/
for f in $(find . -type d -empty); do
	F=${f:2}
	ffmpeg -hide_banner -loglevel panic -i ${F}.mp4 -r 0.3 "${F}/${F}_%03d.jpg"
done
