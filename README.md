DeformIt - Tool for simulating ground truth labels and transformations via physical and statistical warps.
==========================================================================================================
Preet S. Jassi, May 5 2011
--------------------------

DeformIt is a Matlab tool to generate a large data-set deformed images and ground truth segmentations for machine learning algorithms based on a single prototype image and ground truth segmentation.  To deform 2D images, use 2D/DeformIt.m.  To deform 3D images use 3D/DeformIt.m

To generate a large data-set of 2D images based on a single image and segmentation, run the following command in Matlab:

```Matlab
DeformIt(file, segmentation, nObs, WarpedImage, cp, RandomMorph, RandomRange, alpha1, t, Noise, NoiseType, NM,NV,ND,NonUniform, ncp, NonUniformStrength)
```

where:

* _file_  - the filename
* _segmentation_ - the segmentation name or empty string
* _nObs_ - the number of images you want to generate
* _WarpedImage_ - 1 if the image is to be deformed and 0 if the image is not to be deformed (warped)
* _cp_ - the number of control points per axis of the image if you do not want to manually specify the control points
* _RandomMorph_ - 1 if you want the deformation to be Random instead of Vibrational / Variational
* _RandomRange_ - integer between [0,1] for the range of the random vectors where 1 is half the distance between control points
* _alpha1_ - weight of vibrational vs variational when calculating the displacement vectors in the range [0,1]
* _t_ - number of variational modes used in describing the deformation or the fractional variance if less than one, value between [0, nObs^2]
* _Noise_ - 1 if you want to add noise to the image
* _NoiseType_ - gaussian, poisson, salt & pepper, speckle
* _NM_ - the mean of the noise for guassian noise
* _NV_ - the variance for guassian and speckle
* _ND_ - density for salt and pepper
* _NonUniform_ - 1 if you want non uniformity intensities added to simulate the imhomogenity found in magentic resonance images
* _ncp_ - the number of control points for the non uniformity
* _NonUniformStrength_ - the strength of the non uniformity [0,1]

You can also specify landmarks in a text file landmarks.txt and the new location of those landmarks will be specified.

Generating deformed 3D images is very similar.  Look at DeformIt.m in the 3D folder for information about the parameters.

You can read the paper here for more information about [DeformIt](http://www.erudianart.com/research/papers/deformit.pdf)





