========================================================
CamlImages - Objective Caml image processing library
========================================================

The latest released version is 4.1.2.
========================================================

Note: This library is currently under development.
========================================================

What is CamlImages ?
========================================================

This is an image processing library, which provides some basic
functions of image processing and loading/saving various image file
formats. In addition the library can handle huge images that cannot be
(or can hardly be) stored into the memory (the library automatically
creates swap files and escapes them to reduce the memory usage).

Installation
========================================================

Read the file INSTALL.txt

CamlImages concepts
========================================================

Color models
--------------------------------------------------------

CamlImages supports the following color models:

* Rgb24 -- 24bit depth full color image
* Index8 -- 8bit depth indexed image with transparent information
* Index16 -- 16bit depth indexed image with transparent information

For each color models, the corresponding module is provided. Use the module
Rgb24 if you want to access 24bit depth full color images, for example.

Load/Save image files and other fancy features
--------------------------------------------------------

CamlImages supports loading and saving of the following file formats:

* Bitmap (.bmp)
* Tiff (.tiff or .tif), color only
* Jpeg (.jpeg or .jpg)
* Png  (.png)
* Ppm (.pbm, .pgm, .ppm), portable pixmaps
* PS (.ps, .eps), PostScript files
* X Pixmap (.xpm), no saving
* Gif (.gif) (not recommended)
* EXIF tag

For each image format, we provide a separate module. For instance,
there is a Tiff module to load and save images stored in the tiff file
format.

If you do not want to specify the file format, you can use Image.load:
this function automatically analyses the header of the image file at hand
and loads the image into the memory, if the library supports this format.

CamlImages also provides an interface to the internal image format of
O'Caml's Graphics library (this way you can draw your image files into 
the Graphics window).

You can also draw strings on images using the Freetype library, which 
is an external library to load and render TrueType fonts.

Class interface
--------------------------------------------------------

The modules begins the letter 'o' are the class interface for CamlImages.

Image swap
--------------------------------------------------------

When you create/load a huge image, the computer memory may not be
sufficient to contain all the data. (For example, this may happen if
you are working with a scanned image of A4, 720dpi, 24bit fullcolor,
even if you have up to 128Mb of memory!) 
(Well, my son, the first version of this document was written around 1998,
and computers had less memory at that time.)
To work with such huge
images, CamlImages provides image swaps, which can escape part of the
images into files stored on the hard disk. A huge image is thus
partitioned into several blocks and if there is not enough free
memory, the blocks which have not been accessed recently are swapped
to temporary files.  If a program requests to access to such a swapped
block, the library silently loads it back into memory.

By default, image swapping is disabled, because it slows down the
programs. To activate this function, you have to modify
Bitmap.maximum_live and Bitmap.maximum_block_size. Bitmap.maximum_live
is the maximum heap live data size of the program (in words) and
Bitmap.maximum_block_size is the maximum size of swap blocks (in
words).

For example, if you do not want to use more than 10M words (that is
40Mb for a 32bit architecture or 80Mb for a 64bit architecture), set
Bitmap.maximum_live to 10000000. You may (and you should) enable heap
compaction, look at the GC interface file, gc.mli, in the standard
library for more details (you should change the compaction configuration).

Bitmap.maximum_block_size affects the speed and frequency of image
block swapping. If it is larger, each swapping becomes slower. If it
is smaller, more swappings will occur. Too large and too small
maximum_block_size, both may make the program slower. I suggest to
have maximum_block_size set to !Bitmap.maximum_live / 10.

If you activated image swapping, cache files for unused swapped 
blocks will be removed automatically by Caml GC finalization, 
but you may free them explicitly by hand also. The functions and methods 
named "destroy" will free those blocks. 

The swap files are usually created in the /tmp directory.  If you
set the environment variable "CAMLIMAGESTMPDIR", then its value
replaces the default "/tmp" directory. The temporary files are erased
when the program exits successfully. In other situations, for instance
in case of spurious exception, you may need to erase temporary files
manually.

Use of CamlImages
====================================

OCamlFind
------------------------------------

Due to the library complexity, we recommend using OCamlFind.
You can get the list of related packages by::

    $ ocamlfind list | grep camlimages
    camlimages          (version: 4.1.2)
    camlimages.all      (version: 4.1.2)
    camlimages.all_formats (version: 4.1.2)
    camlimages.core     (version: 4.1.2)
    camlimages.exif     (version: 4.1.2)
    camlimages.freetype (version: 4.1.2)
    camlimages.gif      (version: 4.1.2)
    camlimages.graphics (version: 4.1.2)
    camlimages.jpeg     (version: 4.1.2)
    camlimages.lablgtk2 (version: 4.1.2)
    camlimages.png      (version: 4.1.2)
    camlimages.ps       (version: 4.1.2)
    camlimages.tiff     (version: 4.1.2)
    camlimages.xpm      (version: 4.1.2)
 
After successful installation of CamlImages, you should see something similar above.
At compilation of your program, you should list the packages of image formats and GUI of you needs.
But if you are not sure which one is required, just use 'camlimages.all':
it contains everything. Normally your compilation command should look like::

    $ ocamlfind ocamlc -c -package camlimages.all blah.ml

to compile a module using CamlImages, or to build an executable,::

    $ ocamlfind ocamlc -linkpkg -package camlimages.all blah.ml

Basic image manipulation
--------------------------------------

We have a basic image manipulation modules for each image pixel type:
Index8, Index16, Rgb24, Rgba32 and Cmyk32. All they have the same interface
documented in Image_intf.IMAGE.

Image saving/loading
--------------------------------------

To save or load an image to some image format, use the corresponding module
for the image format. Jpeg, Gif, Png and so on.

Here is a simple code to create a 1x1 RGB24 image and save it to a jpeg file::

    (* save it to sample.ml *)
    let () =
      let img = Rgb24.create 1 1 in
      Rgb24.set img 0 0 { Color.r = 255; g = 0; b = 0 };
      Jpeg.save "sample.jpg" [] (Images.Rgb24 img)

You should be able to compile it by::

    $ ocamlfind ocamlc -linkpkg -package camlimages.all -o sample sample.ml

and "./sample" should create an image file "sample.jpg". 
(To run the code correctly, your CamlImages must be compiled with JPEG library.)

Examples
--------------------------------------

Some one-ML-file examples are found in CamlImages source directory. 
Here are some recommendations:

* examples/edgedetect : Good to learn basic image loading/saving and pixel color manipulation
* examples/imgstat : Image header check which is written in pure OCaml code.
* tests/test.ml : Various image load/save tests displaying them on OCaml's Graphics window.
* examples/gifanim : How to handle Gif animation frames and how to write LablGtk app
* examples/resize : Resizing image

You can normally compile them by::

    $ ocamlfind ocamlc -linkpkg -package camlimages.all -o XXX XXX.ml

Some may just fail because some of required libraries are not found in your system.

Where to report issues?
==========================================================

https://bitbucket.org/camlspotter/camlimages/issues?status=new&status=open
