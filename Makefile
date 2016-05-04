.PHONY: all test clean

test:
	cd ibmjava/tests && ./buildAll.sh input.txt
