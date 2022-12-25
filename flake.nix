{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.idris2 = {
    url = "github:idris-lang/Idris2";
  };
  inputs.json = {
    url = "github:stefan-hoeck/idris2-json";
    flake = false;
  };
  inputs.elab-util = {
    url = "github:stefan-hoeck/idris2-elab-util";
    flake = false;
  };

  inputs.idris2-pkgs = {
    url = "github:lizard-business/idris2-pkgs/idris0.6.0";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.idris2.follows = "idris2";
    inputs.json.follows = "json";
    inputs.elab-util.follows = "elab-util";
  };

  inputs.idris2-ffigen.url = "github:xavierzwirtz/idris2-ffigen";
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , idris2-pkgs
    , idris2
    , json
    , elab-util
    , idris2-ffigen
    }:
    let
      mkPkgs = system:
        import nixpkgs {
          inherit system;
          overlays = [
            idris2-pkgs.overlay
            idris2-ffigen.overlay
          ];
        };
      mainExports = flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = mkPkgs system;
            libidris2-raylib-ext = pkgs.stdenv.mkDerivation {
              name = "libidris2-raylib-ext";
              unpackPhase = "true";
              installPhase = "true";
              buildInputs = with pkgs; [ raylib ];
              buildPhase = ''
                mkdir -p $out/lib
                cc -c -fPIC -o libidris2-raylib-ext.o \
                    -I${self}/src/idris2-raylib-ext \
                    ${self}/src/idris2-raylib-ext/idris2-raylib-ext.c
                cc -shared -fPIC -Wl,-soname,libidris2-raylib-ext.so.1 \
                    -o libidris2-raylib-ext.so.0.0.1 libidris2-raylib-ext.o -lc \
                    -L${pkgs.raylib}/lib/\
                    -lraylib
                cp libidris2-raylib-ext.so.0.0.1 libidris2-raylib-ext.o $out/lib
                ln -s $out/lib/libidris2-raylib-ext.so.0.0.1 $out/lib/libidris2-raylib-ext.so
                ln -s $out/lib/libidris2-raylib-ext.so.0.0.1 $out/lib/libidris2-raylib-ext.so.1
              '';
              keepDebugInfo = true;
              dontStrip = true;
            };
            idris2-raylib-ext-bindings = pkgs.idris2-ffigen-make-package {
              authors = "xavierzwirtz";
              packageName = "idris2-raylib-ext-bindings";
              header = "${self}/src/idris2-raylib-ext/idris2-raylib-ext.h";
              libName = "libidris2-raylib-ext";
              clib = libidris2-raylib-ext;
              ccArgs = "-I${pkgs.raylib}/include";
              moduleName = "RaylibExtBindings";
              structs = [
              ];
              functions = [
                {
                  functionName = "idris2_raylib_ext_set_Model_materials_maps";
                  hasIO = true;
                  functionArgSettings = [ ];
                }
              ];
            };
            idris2-raylib-bindings = pkgs.idris2-ffigen-make-package {
              authors = "xavierzwirtz";
              packageName = "idris2-raylib-bindings";
              header = "${pkgs.raylib}/include/raylib.h";
              libName = "libraylib";
              clib = pkgs.raylib;
              moduleName = "RaylibBindings";
              structs = [
                {
                  structName = "Color";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "RenderTexture2D";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Camera3D";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Camera2D";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Camera";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Vector2";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Vector3";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "RenderTexture";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Rectangle";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Texture";
                  createConstructor = true;
                  members = [ ];
                }
                {
                  structName = "Texture2D";
                  createConstructor = true;
                  members = [ ];
                }
              ];
              functions = [
                {
                  "functionName" = "InitWindow";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "WindowShouldClose";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "BeginDrawing";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "EndDrawing";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "ClearBackground";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "GetFontDefault";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawText";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawTextEx";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawTextPro";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "MeasureText";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "MeasureTextEx";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawCircle";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawLine";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawRectangle";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "CloseWindow";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "SetTargetFPS";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "IsKeyDown";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "SetConfigFlags";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "LoadModel";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "LoadTexture";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "LoadShader";
                  "hasIO" = true;
                  "functionArgSettings" = [
                    {
                      functionArgName = "vsFileName";
                      functionArgMapping = "AsPtrString";
                    }
                  ];
                }
                {
                  "functionName" = "LoadRenderTexture";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "UnloadModel";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "UnloadTexture";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "UnloadShader";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "UnloadRenderTexture";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "SetCameraMode";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "BeginTextureMode";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "EndTextureMode";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawModel";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawGrid";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "BeginMode3D";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "EndMode3D";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "BeginShaderMode";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "EndShaderMode";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawTextureRec";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
                {
                  "functionName" = "DrawFPS";
                  "hasIO" = true;
                  "functionArgSettings" = [ ];
                }
              ];
            };
            idris2-raylib =
              pkgs.idris2-pkgs._builders.buildIdris {
                name = "idris2-raylib";
                src = "${self}/src/idris2-raylib";
                idrisLibraries = [
                  idris2-raylib-bindings.idris2Lib
                  idris2-raylib-ext-bindings.idris2Lib
                ];
              };
          in
          rec {
            packages =
              {
                inherit idris2-raylib-bindings libidris2-raylib-ext idris2-raylib-ext-bindings;
              };
            devShells.idris2-raylib = pkgs.mkShell {
              buildInputs = [
                pkgs.raylib
                pkgs.libGL
                pkgs.xorg.libX11
                pkgs.gmp
                pkgs.idris2
                idris2-raylib-bindings.clib
                idris2-raylib-ext-bindings.clib
                libidris2-raylib-ext
              ];
              LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
                pkgs.raylib
                pkgs.idris2
                idris2-raylib-bindings.clib
                idris2-raylib-ext-bindings.clib
                libidris2-raylib-ext
              ];
              IDRIS2_PACKAGE_PATH =
                builtins.concatStringsSep ":" [
                  "${pkgs.idris2}/${pkgs.idris2.name}"
                  "${idris2-raylib.asLib}/idris2-${pkgs.idris2.version}"
                  "${idris2-raylib-bindings.idris2Lib.asLib}/idris2-${pkgs.idris2.version}"
                  "${idris2-raylib-ext-bindings.idris2Lib.asLib}/idris2-${pkgs.idris2.version}"
                ];
            };
            devShell = pkgs.mkShell {
              buildInputs = [
                pkgs.idris2
              ];
              IDRIS2_PACKAGE_PATH = "${pkgs.idris2}/${pkgs.idris2.name}";
            };
          }
        );
    in
    mainExports;
}
