CODENAME := model
QCCOPTS  := -O2 -Wall
RESULTS  := *.csv *.ppm *.gif *.png *.mp4


all: $(CODENAME) 
	./$(CODENAME)

$(CODENAME): app.c
	qcc $(QCCOPTS) app.c -o $(CODENAME) -lm

clean:
	rm -rf $(CODENAME) $(RESULTS)

