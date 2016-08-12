SVG-PCB Oversample Script
=========================

This script and its friends convert SVG artwork into a gEDA PCB file with improved resolution in comparison to using `pstoedit` directly.

Usage
-----

    [FACTOR=number] path/to/svg-pcb-oversample.sh < input.svg > output.pcb

Implementation
--------------

In the ordinary SVG-to-PCB procedure, the user converts the SVG to an EPS file (using Inkscape, for example), then hands the result to `pstoedit` to convert directly to a PCB file. For small artwork, the shapes in `pstoedit`'s PCB export are heavily approximated; arcs, curves, and text rendered at the small scale of a PCB are too sloppy to use.

This approximation is not nearly as pronounced at larger scales, so we employ a workaround based on oversampling: From the original SVG, we make a copy magnified in both dimensions by some factor (100 by default), follow the original procedure, and finally shrink the result by the same factor.

The specific steps taken are these:

*   Scale the SVG to the desired oversampling factor.
*   Export to EPS.
*   Convert the EPS to PCB.
*   Extract the polygon data from the generated PCB.
*   Shrink the polygon data by the oversampling factor.
*   Determine the minimum and maximum X and Y points, adjusting the bounding box accordingly.
*   Format the resulting data as a new PCB file.

Requirements
------------

For this script to run as-is, make sure you have

*   `bash`
*   `realpath`
*   `xsltproc` (applies XSLT transform to enlarge the initial SVG)
*   `inkscape` (converts SVG to EPS)
*   `pstoedit` (converts EPS to nominal PCB)
*   `perl` (runs extraction, shrinking, bounding box adjustment, and final PCB output)
    *   The perl module `JSON`, which may be available in your system package manager (possibly under some awkward systematic name like `libjson-perl`) or can be added using CPAN

