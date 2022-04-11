# BrainSignalDistribution

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![DOI](https://zenodo.org/badge/417160091.svg)](https://zenodo.org/badge/latestdoi/417160091)

**Synopsis:**
Image analysis of brain sections for the rapid quantification of hemispheric signals. This plugin calculates the ratio of integrated fluorescence between left and right brain hemisphere in low-magnification fluorescence microscopy slices of coronal brain cuts. Brain orientation detection and hemisphere assignment is done from an ellipse fit to a morphological reference image. For symmetric cuts the ellipse minor axis coincides with the brain longitudinal fissure.

---

**Requirement:**
+ Morphological reference image to trace outline of the brain slice, eg., DAPI or CellMask labeling.
+ Measurement image with the signal to be compared between hemispheres.
+ Single channel images, eg., in TIFF format

---

**Quick guide:**
+ Open the macro in Fiji/ImageJ: go to Plugins – Macros – Run... and select the .ijm or refer to https://imagej.nih.gov/ij/developer/macro/macros.html
+ Define parameters: “Reference thresholding” and ”Dilatation step” may require some adaptation depending on magnification and image quality. Leave on default to start with. Adapt if brain outline is not correctly identified from morphological reference. Increase dilatation step for a smoother outline.
+ The ellipse fit is done automatically by default, but both center of mass and major axis can be specified manually if needed.
+ Proceed by clicking "OK". 
+ First dialogue box: open the morphological reference image, eg., DAPI signal (single channel image)
+ Second dialogue box: open the corresponding image of the fluorescence distribution (single channel image)

The analysis will start automatically. You can follow hemisphere assignments while it runs.

---

**Results:**
Once the analysis is done, the plugin adds the latest results to a table.
+ X and Y positions of the center of mass (XM, YM)
+ Lengths of major and minor axis of the ellipse (Major, Minor)
+ Orientation of the major axis (Angle)
+ Integrated signals in left and right hemisphere (L, R)
+ Logarithm of the ratio of left and right signal (LogRatio)
