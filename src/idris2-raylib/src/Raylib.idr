module Raylib

public export
%foreign ("C:idris2_raylib_ext_nullPtr,libidris2-raylib-ext")
nullPtrString : Ptr String

public export
%foreign ("C:idris2_raylib_ext_mkString,libidris2-raylib-ext")
mkString : String -> Ptr String


