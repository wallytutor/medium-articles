// app.c
#define REFINE_BIQUADRATIC 0

#include "grid/bitree.h"

void write_level(scalar * list, const char * fname)
{
    FILE * fp = fopen(fname, "w");

    for (int l = 0; l <= depth(); l++)
    {
        fprintf(fp, "# %d\n", l);

        foreach_level (l, serial)
        {
            fprintf(fp, "%d\t%g\t", l, x);

            for (scalar s in list)
            {
                    fprintf(fp, "%g\t", s[]);
            }
            fputc('\n', fp);
        }

        fputc('\n', fp);
        fputc('\n', fp);
    }

    fclose(fp);
}

int main() {
    init_grid (128);
    periodic(right);
    size(2);

    scalar s[], w[], s2[];

#if REFINE_BIQUADRATIC
    for (scalar i in {s, w, s2})
    {
        i.refine = i.prolongation = refine_biquadratic;
    }
#endif

    foreach()
    {
        s[] = sin(2*pi*x) + 0.4*sin(15*pi*x)*max(sin(2*pi*x), 0);
    }

    // PART 1: wavelet transform
    wavelet(s, w);
    inverse_wavelet(s2, w);
    
    foreach()
    {
        assert(fabs (s2[] - s[]) < 1e-12);
    }

    write_level({s, w}, "part-01-wavelet-transform.csv");

    // PART 2: low-pass filtering
    for (int l = 5; l <= 6; l++)
    {
        foreach_level (l)
        {
            w[] *= (x <= 1);
        }
        boundary_level ({w}, l);
    }

    inverse_wavelet (s2, w);
    write_level ({s2, w}, "part-02-low-pass-filter.csv");

    // PART 3: high-pass filtering
    wavelet(s, w);
    
    for (int l = 0; l < 5; l++)
    {
        foreach_level(l)
        {
            w[] = 0.0;
        }
        boundary_level({w}, l);
    }
  
    inverse_wavelet(s2, w);
    write_level({s2, w}, "part-03-high-pass-filter.csv");

    // PART 4: mesh adaptation
    wavelet(s, w);
    unrefine(fabs(w[]) < 0.1);
    write_level({s, w}, "part-04-mesh-adaptation.csv");

    system("gnuplot post.plt");
}

