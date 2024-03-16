#pragma once

event life (i++)
{
    foreach()
    {
        int neigh = -a[];
        
        for(int i = -1; i <= 1; i++)
        {
            for(int j = -1; j <= 1; j++)
            {
                neigh += a[i, j];
            }
        }
        
        b[] = a[] ? (neigh == 2 || neigh == 3) : (neigh == 3); 
        age[] = b[]*(age[] + 1); 
    }

    swap(scalar, a, b);
}

