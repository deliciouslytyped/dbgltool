#TODO does this have CWD issues?
usage.h: ../usage usage.mk
	echo 'char* usage =' > usage.h
	cat ../usage | sed -E -e 's/^/"/' -e 's/$$/\\n"/' >> usage.h
	echo ";" >> usage.h
