{ system ? builtins.currentSystem }:

(builtins.getFlake (toString ../..)).devShells.${system}.idris2-raylib
