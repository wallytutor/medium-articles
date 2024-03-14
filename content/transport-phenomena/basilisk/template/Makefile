CODENAME := game
QCCOPTS  := -O2 -Wall


all: $(CODENAME) 
	./$(CODENAME)

$(CODENAME): app.c
	qcc $(QCCOPTS) app.c -o $(CODENAME) -lm

clean:
	rm -rf $(CODENAME) *.gif

