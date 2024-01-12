+++
title   = "Calling Fortran from C/C++"
tags    = ["programming", "fortran", "c++"]
showall = true
outpath = "/assets/content/medium/06-Calling-Fortran-from-C-C++/code/output"
+++

# Calling Fortran from C/C++

I often find myself with the task of mixing several programming languages in a
single scientific computing project. That sounds a bit crazy but is quite usual
because sometimes legacy code is too long to translate within the deadline or
even political reasons (yes, the guy who wrote the code during his thesis in
1983 might get offended if you update his code). Today I will talk a bit about
exposing Fortran interfaces to be used in C/C++ code. I haven't mastered the
subject yet, although I possess some experience doing so. If you are in a hurry
and don't bother for details, you can go directly
[here](https://github.com/wallytutor/medium-articles/tree/main/src/content/medium/examples/06-Calling-Fortran-from-C-C++)
and download the example project.

## Required knowledge

Once given the task to expose a Fortran API to a C program (from now on I will
let C++ implicit because formally we are exposing the interface to C), a set of
prior knowledge is required. First, a minimum knowledge of Fortran is required
to write the Fortran ISO-C bindings to the interface. These are the files that
mimic (but could also modify) the functions from the original library that are
desired to be available in C. This is Fortran code using the standard library
iso_c_binding as we will see next. It should be obvious by know that you must
know how to compile some code and create application libraries. If you don't,
keep reading and we are going to get there.

## Workflow of interfacing

Let's get practical. Assume you have some old (or not so old) Fortran code, and
your manager or thesis advisor asked you to develop further the existing model.
You are in 2023 (as I write) and know that Fortran is a decaying language, as
you might check in the link. As of today, if you search tags in Stack Overflow,
you get 12759 questions with Fortran, 396490 results with C, and surprisingly
794158 results under C++. You can have a similar experience in your search
engine. By now you argue with your manager/adviser, and both agree that new
developments should be made in a language that provides more online support.

With your copy of the Fortran library to provide a C-interface in hand, you
decide to make a draft of a Gant chart for the tasks to accomplish. Starting
with a simple list, you should write something close to:

1. Fortran interface development: provide a C-binding for each Fortran
   function/module that will be used in C project. Notice that you don't need to
   provide an interface for all library functions, but only those you will use
   (similarly to providing an interface to a C++ class in Cython, if you have
   ever done that).

1. Generate the interface library: here I assume you have already compiled your
   Fortran library to be linked to the original Fortran project. Now you need to
   compile the object code of each of the Fortran ISO-C binding files and the
   original library and then archive them as a shared library (I haven't tried
   doing a shared library yet, in my TODO list!).

1. Provide C headers: to call the Fortran functions from C, the signature of
   each function must be exposed, preferably in a header file. This file shall
   also redefine all Fortran types as C struct.

1. Include the header in main C program: have fun! You can compile your C
   program calling Fortran functions. Don't forget to link the ISO-C binding
   library previously created to the executable, otherwise you will get a
   segmentation fault.

## Getting to the details

In what follows all comments, and some spaces were stripped from the files to
get a more compact code. You can find the sources and compilations instructions
here.

The next code block defines a module called module_f_example, which is the
library your boss provided to you for using from C code. Notice that we have the
type of example_type that is passed as argument mstruc to subroutine example,
the one we will interface here. This subroutine computes the hypotenuse of a
triangle whose sides are provided by properties of example_type and then it sets
both sides of the triangle to zero (why? I have no idea why I did that). So, we
need to bind to C a Fortran type and a function that receives as arguments the
interfaced type and a double number which returns the result of the calculation.
Quite boring. Just to show from C when we are inside Fortran code, some values
before and after the calculation are printed to the screen.

```plaintext
! module_f_example.F95
! Module intended to be called from C/C++.
!
! Author: Walter Dal'Maz Silva
! Date  : Jan 6 2019

module module_f_example
    implicit none

    ! Declare a type to illustrate how to use from C/C++.
    type example_type
        double precision :: x
        double precision :: y
    end type example_type

contains

    ! Function to be called from C/C++.
    subroutine example(mstruc,val)
        implicit none

        type(example_type), pointer, intent(inout) :: mstruc
        double precision, intent(inout) :: val

        ! Be verbose to check from C/C++.
        write(*,*)'Point 0 at `module_f_example:example`: val =',val
        ! Modify all quantities.
        val = sqrt(mstruc%x * mstruc%x + mstruc%y * mstruc%y)
        mstruc%x = 0
        mstruc%y = 0
        write(*,*)'Point 1 at `module_f_example:example`: val =',val
    end subroutine example

endmodule module_f_example
```

Now it is time to provide the interface. The code here is some sort of weird
Fortran actually. First, we need to use the compiler's default iso_c_binding. It
is recommended to import it as use, intrinsic because otherwise the compiler may
have its specific implementation that may not respect the standards, what may
result that your code may not be compiled with a different compiler. Next, as
(maybe) expected, we import the Fortran module to provide the interface. The
type is redefined and renamed. Notice the use of bind(c) after all declarations
we wish to be able to call from C (type and subroutine).

In the subroutine some particularities are observed in the types. First, this
function will receive C types, thus the values of mstruc and val must comply
with these and use the equivalent types as the Fortran ones. Since the struct is
not a C equivalent of Fortran type, parameter mstruc is provided as a c_ptr. For
obvious reasons this object cannot be used by the Fortran routine. Hopefully
iso_c_binding provides a pointer translator c_f_pointer to retrieve the
equivalent Fortran pointer that will be set to f_mstruc, the variable that
finally can be used the the call to example! What confusion! And there is more:
once the Fortran call is over, you need to retrieve the address of its pointer
through c_loc so that you can return your object properly modified to C. Yes, I
know this paragraph is quite dense. You should get back to the beginning or just
look at this file with the proper comments
[here](https://github.com/wallytutor/medium-articles/tree/main/src/content/medium/examples/06-Calling-Fortran-from-C-C++).
It's done, time to C!

```plaintext
! module_c_example.F95
! ISO-C Binding to module_f_example
!
! Author: Walter Dal'Maz Silva
! Date  : Jan 6 2019

module module_c_example
    ! Use ISO-C Bindings default
    use, intrinsic :: iso_c_binding
    !, only : c_f_pointer, c_loc, c_double, c_ptr

    ! The module we are interfacing.
    use module_f_example

    implicit none

    ! XXX this seems actually not to be necessary once example_type is
    ! defined as a struct in c_example.hpp. The only important factor is
    ! that the order of parameters and their names must respect the original
    ! interface from module_f_example. This is weird because the code works
    ! fine, against what has been stated in the following link:
    ! https://stackoverflow.com/tags/fortran-iso-c-binding/info
    ! Maybe it is linked to the fact we use 2008ts, not 2003 here!
    ! type, bind(c) :: c_example_type
    !     real(c_double) :: x
    !     real(c_double) :: y
    ! end type c_example_type

contains

    ! Declaration of C-callable interface for `example` function. The main
    ! feature in this interface is the `bind` method providing the C-name.
    subroutine c_example(mstruc,val) bind(c,name='c_example')
        implicit none

        ! Provide argument types. Notice here that declarations are not as
        ! usual in Fortran, but must respect the style of iso_c_binding.
        ! Another import point is about the typo of `mstruc`. Although in
        ! the headings of this module c_example_type was declared, that
        ! interface was only intended for the C-header file and here one
        ! must use the `c_ptr` type. See C interface with a `void*` in its
        ! place for compatibility. The type of `val` is now given by the
        ! C-binding `real(c_double)`.
        type(c_ptr), intent(inout) :: mstruc
        real(c_double), intent(inout) :: val

        ! Declare internal object of Fortran type for conversion and actual
        ! communication with underlining library.
        type(example_type), pointer :: f_mstruc

        ! Convert C to Fortran pointer.
        ! https://gcc.gnu.org/onlinedocs/gfortran/C_005fF_005fPOINTER.html
        call c_f_pointer(mstruc, f_mstruc)

        ! Call of Fortran function.
        call example(f_mstruc,val)

        ! Gets the address of Fortran pointer.
        ! https://gcc.gnu.org/onlinedocs/gfortran/C_005fLOC.html
        mstruc = c_loc(f_mstruc)
    end subroutine c_example

endmodule module_c_example
```

Things get much simpler in C header file. Just provide a struct with the same
face as its Fortran equivalent type and an interface to the function as named in
ISO-C binding interface: c_example. But wait! There is a particularity here.
Notice that the first argument of this function is now a void*, this cryptic
type! This is required because Fortran cannot know about the struct type, and
thus we need to apply a raw pointer (or it is my limited knowledge of the
subject).

**PS:** after checking some more examples I finally understood the limitation.
Actually, you can use c_example_type inside the ISO-C interface, if the type is
defined to be interoperable, but this type cannot be passed to the raw Fortran
function. That's the reason we need the void*. Check this and this.

```c
// c_example.hpp
//
// Author: Walter Dal'Maz Silva
// Date  : Jan 6 2019

#ifndef __C_EXAMPLE_HPP__
#define __C_EXAMPLE_HPP__

// Consider compatibility with plain C.
#ifdef __cplusplus
extern "C" {
#endif

// This has the same face as the example_type in module_f_example.95 but
// it was nowhere declared in (see the file for more) module_c_example.F95.
typedef struct {
    double x;
    double y;
} example_type;

// Function interfaced at module_c_example.F95
void c_example(void* mstruc, double* val);

#ifdef __cplusplus
}
#endif

#endif // (__C_EXAMPLE_HPP__)
```

Just to conclude, we apply the interface. Again, the only particularity is that
we need to convert a reference to our ptr to a void* for compatibility with the
interface.

```c
// c_example.cpp
// 
// Author: Walter Dal'Maz Silva
// Date  : Jan 6 2019

#include <iostream>
#include <iomanip>
#include "c_example.hpp"

int main()
{
    double val = 0.0;
    example_type *ptr = new example_type {3.0, 4.0};

    std::cout << std::fixed << std::setprecision(2)
              << "\n Before Fortran call"
              << "\n x = " << ptr->x
              << "\n y = " << ptr->y
              << "\n v = " << val
              << "\n" << std::endl;

    c_example((void*)&ptr, &val);

    std::cout << std::fixed << std::setprecision(2)
              << "\n After Fortran call"
              << "\n x = " << ptr->x
              << "\n y = " << ptr->y
              << "\n v = " << val
              << "\n" << std::endl;
    return 0;
}
```

Hope you have enjoyed it and find this code useful. I will eventually update the
GitHub sources with more specific cases as I need them in my personal projects.
If you have any questions don't hesitate to contact me.

\patreon
