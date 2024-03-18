set terminal png size 900,500

maxlevel = 6
spacing = 1.5

set ytics -maxlevel,1,0
set xlabel 'x'
set ylabel 'Level'
set grid ytics ls 0
set samples 500

max(a, b) = a > b ? a : b
f(x) = sin(2.0*pi*x)+0.4*sin(15.0*pi*x)*max(sin(2.0*pi*x), 0);

###################################################################
# PART 1:
###################################################################

FILE = "part-01-wavelet-transform.csv"
FOUT = "part-01-wavelet-transform.png"
set output FOUT
set multiplot layout 1,2

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($3/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($4/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

unset multiplot

###################################################################
# PART 2:
###################################################################

FILE = "part-02-low-pass-filter.csv"
FOUT = "part-02-low-pass-filter.png"
set output FOUT
set multiplot layout 1,2

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($3/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($4/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

unset multiplot

###################################################################
# PART 3:
###################################################################

FILE = "part-03-high-pass-filter.csv"
FOUT = "part-03-high-pass-filter.png"
set output FOUT
set multiplot layout 1,2

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($3/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($4/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

unset multiplot

###################################################################
# PART 4:
###################################################################

FILE = "part-04-mesh-adaptation.csv"
FOUT = "part-04-mesh-adaptation.png"
set output FOUT
set multiplot layout 1,2

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($3/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

plot for [i=0:maxlevel]                             \
  FILE index i u 2:($4/spacing - i) w p t '' lt 7, \
  for [i=0:maxlevel] f(x)/spacing - i t '' lt 1

unset multiplot

