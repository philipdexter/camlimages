module Numbers : sig
  type rational  = int64 * int64 (** unsigned 32bits int rational *)
  type srational = int32 * int32 (** signed 32bits int rational *)
  val float_of_rational   : int64 * int64 -> float
  val float_of_srational  : int32 * int32 -> float
  val string_of_rational  : int64 -> int64 -> string
  val string_of_srational : int32 -> int32 -> string
end

open Numbers

module Endian : sig
  type t = Big | Little 
  val to_string : t -> string 
  val sys : t 
end

module IFD : sig
  type t = 
    | IFD_0   (** Info of the main image *)
    | IFD_1   (** Info of the thumbnail *)
    | EXIF    (** camera info *)
    | GPS     (** location *)
    | Interop (** exif format interoperability info *)
end

module Date : sig
  (** Date for GPSDateStamp *)
  type t = { year : int; month : int; day : int; }
  val to_string : t -> string
  val of_string : string -> [> `Error of string | `Ok of t ]
end

module DateTime : sig
  type t = {
    year : int;
    month : int;
    day : int;
    hour : int;
    min : int;
    sec : int;
  }

  val to_string : t -> string

  val of_string : string -> [> `Error of string | `Ok of t ]
  (** To convert DateTime string to DateTime.t.
  *)

  val of_string_packed_unix_time : string -> [> `Error of string | `Ok of t ]
  (** I had an Android phone which created DateTime tag with
      a little endian encoded unsigned int32 of unix time!
      This function tries to fix the issue.
  *)
  
end
    
module Tag : sig
  type t = int

  val to_string : t -> IFD.t -> string
  (** Tag name requires IFD.t since the same tag number has different
      meaning in IFD and GPS *)
end

module Entry : sig
  type t
  
  module Pack : sig

    type format =
      | ILLEGAL (** do not used it *)
      | BYTE
      | ASCII
      | SHORT
      | LONG
      | RATIONAL
      | SBYTE
      | UNDEFINED
      | SSHORT
      | SLONG
      | SRATIONAL
      | FLOAT
      | DOUBLE

    val string_of_format : format -> string

    type unpacked =
      | Bytes of int array
      | Asciis of string
      | Shorts of int array
      | Longs of int64 array
      | Rationals of (int64 * int64) array
      | SBytes of int array
      | Undefined of string
      | SShorts of int array
      | SLongs of int32 array
      | SRationals of (int32 * int32) array
      | Floats of float array
      | Doubles of float array
    (** Constructors start with "S" are signed. *)

    val unpack : format -> int -> string -> unpacked
    (** [unpack format components packed] 
        [components] are the number of elements in [packed],
        not the bytes of [packed].
    *)

    val format : Format.formatter -> unpacked -> unit

  end
  
  module Decoded : sig
    type t = {
      tag : int;
      format : Pack.format;
      components : int;
      data : string;
    }
  end
  
  val decode : t -> Decoded.t

  type unpacked_entry = Tag.t * Pack.unpacked
  val unpack : Decoded.t -> unpacked_entry

  val format_unpacked_entry :
    IFD.t -> Exifutil.Format.formatter -> Tag.t * Pack.unpacked -> unit
  
  val format : IFD.t -> Exifutil.Format.formatter -> t -> unit
    (** [format] does decode + unpack *)

end

module Content : sig
  type t

  val entries : t -> Entry.t list
  val format : IFD.t -> Exifutil.Format.formatter -> t -> unit
end

module Data : sig
  type t
  
  val get_byte_order : t -> Endian.t
  val set_byte_order : t -> Endian.t -> unit
  val fix : t -> unit
  val dump : t -> unit

  val from_string : string -> t
  val format : Exifutil.Format.formatter -> t -> unit
  
  type contents = {
    ifd_0   : Content.t option;
    ifd_1   : Content.t option;
    exif    : Content.t option;
    gps     : Content.t option;
    interop : Content.t option;
  }
  
  val contents : t -> contents

  val get_ifd_0   : t -> Content.t option
  val get_ifd_1   : t -> Content.t option
  val get_exif    : t -> Content.t option
  val get_gps     : t -> Content.t option
  val get_interop : t -> Content.t option

  val unpack_ifd_0 : t -> Entry.unpacked_entry list option
  val unpack_ifd_1 : t -> Entry.unpacked_entry list option
  val unpack_exif  : t -> Entry.unpacked_entry list option
  val unpack_gps   : t -> Entry.unpacked_entry list option
  val unpack_interop : t -> Entry.unpacked_entry list option

end

module Analyze : sig

  type datetime = 
    [ `EncodedInUnixTime of DateTime.t
    | `Error of string
    | `Ok of DateTime.t 
    ]
  (** I have some photos from my old Android with non Ascii datetime.
      They have encoded 32 bit int in Unix time instead! :-(
  *)

  val parse_datetime : string -> [> datetime ]

  val analyze_ifd :
    int * Entry.Pack.unpacked 
    -> [> `DateTime of [> datetime ]
       | `Make of string
       | `Model of string
       | `Orientation of [> `BottomLeft
                         | `BottomRight
                         | `LeftBottom
                         | `LeftTop
                         | `RightBottom
                         | `RightTop
                         | `TopLeft
                         | `TopRight ]
       | `ResolutionUnit of [> `Centimeters | `Inches ]
       | `Software of Entry.Pack.unpacked
       | `Unknown of int * Entry.Pack.unpacked
       | `XResolution of int64 * int64
    | `YResolution of int64 * int64 ]

  val analyze_exif :
    int * Entry.Pack.unpacked 
    -> [> `DateTimeDigitized of [> datetime ]
       | `DateTimeOriginal of [> datetime ]
       | `ExifVersion of string
       | `MakerNote of string
       | `SubsecTime of string
       | `SubsecTimeDigitized of string
       | `SubsecTimeOriginal of string
       | `Unknown of int * Entry.Pack.unpacked
       | `UserComment of string ]

  val analyze_gps :
    int * Entry.Pack.unpacked 
    -> [> `AboveSeaLevel
       | `Altitude of int64 * int64
       | `BelowSeaLevel
       | `EastLongitude
       | `GPSDate of [> `Error of string | `Ok of Date.t ]
       | `GPSMapDatum of string
       | `GPSVersion of int * int * int * int
       | `ImgDirection of int64 * int64
       | `ImgDirectionMagnetic
       | `ImgDirectionTrue
       | `Latitude of int64 * int64
       | `Longitude of int64 * int64
       | `NorthLatitude
       | `SouthLatitude
       | `TimeStampUTC of float * float * float
       | `TimeStampUTCinSRationals of float * float * float
       | `Unknown of int * Entry.Pack.unpacked
       | `WestLongitude 
       ]

  val ifd_0_datetime : Data.t -> [> datetime ] option
  (** Get ifd_0 DateTime *)

  val exif_datetime : Data.t -> [> datetime ] option
  (** Get exif DateTimeOriginal *)

  val datetime : Data.t -> [> datetime ] option
  (** Get one of the first finding of the followings:
      * exif DateTimeOriginal
      * ifd_0 DateTime
   *)
end
