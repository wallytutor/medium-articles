# Additional requirements:
# sudo apt install meshlab

CODENAME := distance_stl
QCCOPTS  := -O2 -Wall
RESULTS  := *.ppm *.gif *.png *.mp4


STATICS  := \
	$(BASILISK)/gl/libfb_tiny.a \
 	$(BASILISK)/gl/libfb_glx.a \
	$(BASILISK)/gl/libfb_osmesa.a \
	$(BASILISK)/gl/libglutils.a

all: $(CODENAME) 
	./$(CODENAME)

$(CODENAME): app.c
	qcc $(QCCOPTS) app.c $(STATICS) -o $(CODENAME) -lm

clean:
	rm -rf $(CODENAME) $(RESULTS)

