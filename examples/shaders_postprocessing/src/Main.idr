module Main

import System.Clock
import Data.Vect

import Control.App
import Control.App.Console
import Raylib
import RaylibBindings
import RaylibExtBindings
import Data.List
import Data.List1
import Data.Vect
import Data.Nat
import System.Random
import System.FFI


screenWidth : Int
screenWidth = 800

screenHeight : Int
screenHeight = 450

draw
  : RenderTexture
  -> RaylibBindings.Model
  -> Shader
  -> String
  -> Int
  -> IO ()
draw renderTexture model shader shaderName viewAngle = do
  beginTextureMode renderTexture
  clearBackground $ MkColor (chr 245) (chr 245) (chr 245) (chr 245)

  let (camX, camZ, camY) : (Double, Double, Double) = (4, 3, 2)
  let rad = (cast viewAngle * pi) / 180

  let camX' = camX * cos(rad) - camZ * sin(rad);
  let camZ' = camZ * cos(rad) + camX * sin(rad);

  let camera = MkCamera3D
                 (MkVector3 camX' camY camZ')
                 (MkVector3 0 1 0)
                 (MkVector3 0 1 0)
                 45
                 0

  beginMode3D camera
  drawModel model
            (MkVector3 0 0 0)
            0.1
            $ MkColor (chr 245) (chr 245) (chr 245) (chr 245)
  drawGrid 10 1.0
  endMode3D
  endTextureMode

  beginDrawing
  clearBackground $ MkColor (chr 245) (chr 245) (chr 245) (chr 245)
  beginShaderMode shader

  drawTextureRec (get_RenderTexture_texture renderTexture)
                 (MkRectangle 0 0
                              (cast $ get_Texture_width
                                    $ get_RenderTexture_texture
                                    $ renderTexture)
                              (cast $ -(get_Texture_height
                                        $ get_RenderTexture_texture
                                        $ renderTexture))
                 )
                 (MkVector2 0 0)
                 (MkColor (chr 255) (chr 255) (chr 255) (chr 255))
  endShaderMode

  -- Draw 2d shapes and text over drawn texture
  drawRectangle 0 9 580 30 $ MkColor (chr 200) (chr 200) (chr 200) (chr 255)

  drawText "(c) Church 3D model by Alberto Cano" (screenWidth - 200) (screenHeight - 20) 10 $ MkColor (chr 130) (chr 130) (chr 130) (chr 255)
  drawText "CURRENT POSTPRO SHADER:" 10 15 20 $ MkColor (chr 0) (chr 0) (chr 0) (chr 255)
  drawText shaderName 330 15 20 $ MkColor (chr 230) (chr 41) (chr 55) (chr 255)
  drawText "< >" 540 10 30 $ MkColor (chr 0) (chr 82) (chr 172) (chr 255)
  drawFPS 700 15
  endDrawing

rotationTime : Integer
rotationTime = 5000

keyRight : Int
keyRight = 262

keyLeft : Int
keyLeft = 263

finDec : {n : Nat} -> Fin n -> Fin n
finDec FZ = last
finDec (FS x) = weaken x

record State len where
  constructor MkState
  shaders : Vect len (String, Shader)
  shaderIndex : Fin len
  debounceR : Bool
  debounceL : Bool

update
  : { len : Nat }
  -> State len
  -> IO (State len)
update state = do
  k_r <- isKeyDown keyRight
  k_l <- isKeyDown keyLeft
  pure $ case (k_r, debounceR state, k_l, debounceL state) of
    (True,  False, _, _) => { shaderIndex $= finS, debounceR := True } state
    (_, _, True, False) => { shaderIndex $= finDec, debounceL := True } state
    (False, True, _, _) => { debounceR := False } state
    (_, _, False, True) => { debounceL := False } state
    _ => state

loop
  : {len : Nat}
  -> RenderTexture
  -> RaylibBindings.Model
  -> (state: State len)
  -> (clockTimeReturnType Monotonic)
  -> IO ()
loop renderTexture model state startTime = do
     shouldClose <- windowShouldClose
     if shouldClose then closeWindow
       else do
         state' <- update state
         currentTime <- clockTime Monotonic
         let dif = timeDifference currentTime startTime
         let s = (the Double $ cast (seconds dif)) + cast (nanoseconds $ dif) / 1000000000.0
         let s' = the Double $ s * 1000
         let s'' = the Integer $ cast s'
         let s''' = if s'' == 0 then 1 else s''
         let rem = the Integer $ mod s''' rotationTime

         let ratio = (the Double $ cast rem) / (the Double $ cast rotationTime)
         let degrees = ratio * 360

         let (shaderName, shader) = index (shaderIndex state') (shaders state)
         draw renderTexture model shader shaderName (the Int $ cast (ratio * 360))
         loop renderTexture model state' startTime

glslVersion : Int
glslVersion = 330


shaderNames : List String
shaderNames = [ "grayscale"
              , "posterization"
              , "dream_vision"
              , "pixelizer"
              , "cross_hatching"
              , "cross_stitching"
              , "predator"
              , "scanlines"
              , "fisheye"
              , "sobel"
              , "bloom"
              , "blur"
              ]

getShaders : Vect l String
          -> IO $ Vect l (String, Shader)
getShaders shaderNames =
  traverse (\shaderName => do shader <- loadShader Raylib.nullPtrString "resources/shaders/glsl\{show glslVersion}/\{shaderName}.fs"
                              pure (shaderName, shader))
           shaderNames

-- vecLength : Vect len x -> len

export main : IO ()
main = do
     setConfigFlags 0x00000020 -- FLAGS_MSAA_4X_HINT
     initWindow screenWidth screenHeight "raylib [shaders] example - postprocessing shader"
     model <- loadModel("resources/models/church.obj")
     texture <- loadTexture("resources/models/church_diffuse.png")
     RaylibExtBindings.idris2_raylib_ext_set_Model_materials_maps model 0 0 texture
     shaders <- getShaders $ fromList shaderNames
     target <- loadRenderTexture screenWidth screenHeight
     setTargetFPS 60
     startTime <- clockTime Monotonic
     let startState = MkState { shaders = shaders
                              , shaderIndex = 0
                              , debounceR = False
                              , debounceL = False
                              }
     loop target model startState startTime
