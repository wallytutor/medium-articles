set terminal png size 800,600
set output "output.png"

set xlabel 'Time'
set ylabel 'Depth'

plot \
    'output.log' using 1:2 with lines title 'min',\
    'output.log' using 1:3 with lines title 'max'
    
