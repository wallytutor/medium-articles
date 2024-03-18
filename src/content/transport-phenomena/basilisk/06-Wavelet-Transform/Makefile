CODENAME := wavelet
QCCOPTS  := -O2 -Wall
RESULTS  := *.ppm *.gif *.png *.mp4 *.csv


all: $(CODENAME) 
	./$(CODENAME)

$(CODENAME): app.c
	qcc $(QCCOPTS) app.c -o $(CODENAME) -lm

clean:
	rm -rf $(CODENAME) $(RESULTS)

