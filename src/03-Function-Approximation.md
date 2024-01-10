---
title  : Function Approximation
author : Walter Dal'Maz Silva
date   : `j import Dates; Dates.Date(Dates.now())`
weave_options:
  error: false
  term: false
  wrap: true
  line_width: 100
---

# Approximating functions

In this article we will explore how least squares work and implement an arbitrary function fitting in Julia. The approach implemented here follows the works of [Professor Dr. Hans Peter Langtangen (deceased)](https://hplgit.github.io/fem-book/doc/web/index.html) who have written probably the best introductory texts on finite element methods to date.