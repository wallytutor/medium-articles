CODENAME := game
QCCOPTS  := -O2 -Wall


all: $(CODENAME).out 
	./$(CODENAME).out 

$(CODENAME).out: $(CODENAME).c
	qcc $(QCCOPTS) $(CODENAME).c -o $(CODENAME).out -lm

clean:
	rm -rf $(CODENAME).out *.gif

