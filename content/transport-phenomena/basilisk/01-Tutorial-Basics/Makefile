CODENAME := bump
QCCOPTS  := -O2 -Wall


all: $(CODENAME).out 
	./$(CODENAME).out > output.ppm 2> output.log
	gnuplot $(CODENAME).plt

$(CODENAME).out: $(CODENAME).c
	qcc $(QCCOPTS) $(CODENAME).c -o $(CODENAME).out -lm

clean:
	rm -rf $(CODENAME).out output.*

