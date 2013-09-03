=========================================================
CamlImages - Objective Caml image processing library
=========================================================

Requirements
=================

 To install CamlImages library, you need the following softwares:

* OCaml 4.00.1 or higher (OCaml 3.11 and above might work with small trivial fixes, but never tested)
* Findlib (aka ocamlfind, http://www.camlcity.org/archive/programming/findlib.html )
* OMake ( http://omake.metaprl.org/index.html )

Note that this is the minimum requirement: you can read/write BMP or
PXM (PPM, PGM, PBM) image formats but no other formats. If you want to
deal with other image formats, you need to install the corresponding
external libraries:

* libpng for PNG format
        http://www.libpng.org/pub/png/libpng.html
        http://sourceforge.net/projects/libpng/

* libjpeg for JPEG format
        The Independent JPEG Group's software
        ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6b.tar.gz

* libexif for EXIF tags in JPEG files

* libtiff for TIFF format
        http://www.libtiff.org/
        ftp://ftp.remotesensing.org/pub/libtiff/

* libxpm for XPM format (could be already by the X server installation)
        X contrib libraries ftp directory
        ftp://ftp.x.org/contrib/libraries

* freetype for drawing texts using truetype fonts
        The FREETYPE Project
        http://sourceforge.net/projects/freetype/

* libungif for GIF format
        Libungif, a library for using GIFs
          http://sourceforge.net/projects/libungif/

* ghostscript for PS format
        See http://www.ghostscript.com/

* lablgtk2, an Objective Caml interface to gtk+
        http://wwwfun.kurims.kyoto-u.ac.jp/soft/olabl/lablgtk.html

*** Installation procedure by omake

 % yes no | omake --install 
 % omake --configure <configuration options>
 % omake install

At omake --configure, you can specify CFLAGS and LDFLAGS 
to add extra header and library search paths respectively. For example,

    % omake --configure CFLAGS="-I /usr/include/libexif" LDFLAGS="-L/opt/blah"

List of configurable variables

  CFLASG, INCLUDES, LDFLAGS: as usual.

  ARG_WANT_<feature>=bool
      Without specifying ARG_WANT_<feature>, omake --configure automatically
      searches the availability of <feature> and enables it when found.

      If ARG_WANT_<feature>=0, the feature is not checked, and disabled.

      If ARG_WANT_<feature>=1, the feature must exist and is enabled.
      If omake fails to find the feature, the entire build fails.

      Currently the following features are available:
        GIF, PNG, JPEG, EXIF, TIFF, XPM, GS, LABLGTK2, GRAPHICS, FREETYPE

  ARG_FREETYPE_CONFIG=string
  ARG_PATH_GS=string
      PATH of freetype-config and gs. 
      Without specifying, omake tries to find them in the PATH.

Test
----
  Before you actually install the library, you can check that it
really works, by running examples in the test directory. For the test
programs,

        % cd test
        % make
        % ./test
        % ./test.run

(./test.run is the bytecode executable and ./test the binary
executable).
