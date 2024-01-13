# -*- coding: utf-8 -*-
import numpy as np
import pandas as pd


if __name__ == "__main__":
    xname = "x-coordinate"
    Tname = "temperature"

    opts = dict(
        usecols=[xname, Tname],
        low_memory=False,
        skipinitialspace=True
    )
    data  = pd.read_csv("solution.csv", **opts)

    bins = pd.cut(data[xname], np.linspace(0, 10, 1000))
    post = data.groupby(bins)[[xname, Tname]].mean()
    post.reset_index(drop=True, inplace=True)

    post.to_csv("postprocess.dat", index=False, sep="\t",
                header=None, float_format="%.6f")
