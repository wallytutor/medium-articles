CODENAME := ginzburg_landau
QCCOPTS  := -O2 -Wall
RESULTS  := *.ppm *.gif *.png *.mp4


all: $(CODENAME) 
	./$(CODENAME)

$(CODENAME): app.c *.h
	qcc $(QCCOPTS) app.c -o $(CODENAME) -lm

clean:
	rm -rf $(CODENAME) $(RESULTS)

