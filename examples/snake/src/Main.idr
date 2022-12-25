module Main

import Control.App
import Control.App.Console
import RaylibBindings
import Data.List
import Data.List1
import Data.Vect
import Data.Nat
import System.Random

V2 : Type
V2 = (Int, Int)

castDouble : Int -> Double
castDouble = cast

screenWidth : Int
screenWidth = 800

screenHeight : Int
screenHeight = 450

squareSize : Int
squareSize = 31

gridX : Int
gridX = cast $ ((castDouble screenWidth) / (castDouble squareSize))

gridY : Int
gridY = cast $ ((castDouble screenHeight) / (castDouble squareSize))

offsetX : Int
offsetX = mod screenWidth squareSize

offsetY : Int
offsetY = mod screenHeight squareSize

darkBlue : Color
darkBlue = MkColor (chr 0) (chr 82) (chr 172) (chr 255)

blue : Color
blue = MkColor (chr 0) (chr 121) (chr 241) (chr 255)

skyBlue : Color
skyBlue = MkColor (chr 102) (chr 191) (chr 255) (chr 255)

Snake : Type
Snake = List1 V2

data Direction
= Right
| Left
| Up
| Down

Eq Direction where
  ((==) Right Right) = True
  ((==) Left Left) = True
  ((==) Up Up) = True
  ((==) Down Down) = True
  ((==) _ _) = False

record PlayState where
  constructor MkPlayState
  snake : Snake
  fruit : V2
  movementDirection : Direction
  framesCounter : Int

data GameState
= NotStarted
| Playing PlayState
| GameOver

Show PlayState where
  show x = "snake: \{show x.snake}, fruit: \{show x.fruit}"

keyRight : Int
keyRight = 262

keyLeft : Int
keyLeft = 263

keyDown : Int
keyDown = 264

keyUp : Int
keyUp = 265

keyEnter : Int
keyEnter = 257

getDirection : Direction -> IO Direction
getDirection direction = do
  k_r <- isKeyDown keyRight
  k_l <- isKeyDown keyLeft
  k_u <- isKeyDown keyUp
  k_d <- isKeyDown keyDown
  pure $ case (k_r, k_l, k_u, k_d) of
    (True, _, _, _) => c Left Right
    (_, True, _, _) => c Right Left
    (_, _, True, _) => c Down Up
    (_, _, _, True) => c Up Down
    (_, _, _, _) => direction
  where
    c : Direction -> Direction -> Direction
    c x y = if direction == x then x else y

randomFruit : IO V2
randomFruit = do
  x <- rndSelect [0..(gridX-1)]
  y <- rndSelect [0..(gridY-1)]
  pure $ (x, y)

extrudeSnake : V2 -> Vect (S n) V2 -> Vect (S (S n)) V2
extrudeSnake pos snake = pos::snake

moveSnakeTo : V2 -> Vect (S n) V2 -> Vect (S n) V2
moveSnakeTo pos (head :: []) = pos::[]
moveSnakeTo pos (head :: (tail :: tails)) = pos::(moveSnakeTo head (tail::tails))

listToVect : (xs : List a) -> Vect (length xs) a
listToVect [] = []
listToVect (x :: xs) = x:: listToVect xs

list1ToVect1 : (xs : List1 a) -> Vect (S (case xs of _:::xs' => length xs')) a
list1ToVect1 (head ::: tail) = head :: listToVect tail

vect1ToList1 : (xs : Vect (S n) a) -> List1 a
vect1ToList1 (x :: xs) = x:::(toList xs)

checkSelfCollision : V2 -> (List V2) -> Bool
checkSelfCollision pos [] = False
checkSelfCollision pos (x :: xs)  = x == pos || checkSelfCollision pos xs

checkFruitCollision : V2 -> PlayState -> IO PlayState
checkFruitCollision headPos state =
  if state.fruit == headPos then do
      let
        snake = vect1ToList1 $ extrudeSnake headPos (list1ToVect1 state.snake)
      fruit <- randomFruit
      pure $ { snake := snake, fruit := fruit } state
    else do
        let snake = (vect1ToList1 $ moveSnakeTo headPos (list1ToVect1 state.snake))
        pure $ { snake := snake } state

moveSnake : PlayState -> IO GameState
moveSnake state =
  let
    (x,y):::_ = state.snake
    (nx, ny) =
      case state.movementDirection of
        Right => (x+1, y)
        Left => (x-1, y)
        Up => (x, y-1)
        Down => (x, y+1)
    gameOver = (nx >= gridX || nx < 0) ||
               (ny >= gridY || ny < 0)
  in
  if gameOver then pure GameOver
    else do
      if checkSelfCollision (nx, ny) (toList state.snake) then
          pure GameOver
        else do
          state <- checkFruitCollision (nx, ny) state
          pure $ Playing state


newGameState : IO PlayState
newGameState = do
  let snakeHead =
      (cast $ ((castDouble gridX)/2)
      ,cast $ ((castDouble gridY)/2))
  fruit <- randomFruit
  pure $ MkPlayState (snakeHead:::[]) fruit Right 0

updatePlayState
  : PlayState
  -> IO GameState
updatePlayState state = do
  newMovementDirection <- getDirection state.movementDirection
  let state =
      { framesCounter $= (+) 1
      , movementDirection := newMovementDirection
      } state
  if state.framesCounter /= 0 && mod state.framesCounter 5 == 0
    then do
      newState <- moveSnake state
      pure newState
    else pure $ Playing state

checkStart : GameState -> IO GameState
checkStart ret = do
  x <- isKeyDown keyEnter
  if x then do
      state <- newGameState
      pure $ Playing state
    else pure ret

updateState : GameState -> IO GameState
updateState NotStarted = checkStart NotStarted
updateState GameOver = checkStart GameOver
updateState (Playing x) = updatePlayState x

drawGridHorizontal : List Int -> IO ()
drawGridHorizontal [] = pure ()
drawGridHorizontal (i :: is) = do
  let
    x : Int
    x = squareSize * i + cast((castDouble offsetX)/(castDouble 2))
    y : Int
    y = cast((castDouble offsetY)/(castDouble 2))
  drawLine x y x (screenHeight - y) $ MkColor (chr 190) (chr 33) (chr 55) (chr 255)
  drawGridHorizontal is

drawGridVertical : List Int -> IO ()
drawGridVertical [] = pure ()
drawGridVertical (i :: is) = do
  let
    x : Int
    x = cast((castDouble offsetX)/(castDouble 2))
    y : Int
    y = squareSize * i + cast((castDouble offsetY)/(castDouble 2))
  drawLine x y (screenWidth - x) y $ MkColor (chr 190) (chr 33) (chr 55) (chr 255)
  drawGridVertical is

drawGrid : IO ()
drawGrid = do
  drawGridHorizontal [0..gridX]
  drawGridVertical [0..gridY]

drawGridSquare : V2 -> Color -> IO ()
drawGridSquare (x,y) color = do
  let r = get_Color_r color
  drawRectangle ((cast $ (castDouble offsetX)/2) + (x*squareSize)) ((cast $ (castDouble offsetY)/2) + (y*squareSize)) squareSize squareSize color

drawSnakeTail : List V2 -> IO ()
drawSnakeTail [] = pure ()
drawSnakeTail (x :: xs) = do
  drawGridSquare x skyBlue
  drawSnakeTail xs

drawSnake : List1 V2 -> IO ()
drawSnake (head ::: tail) = do
  drawGridSquare head darkBlue
  drawSnakeTail tail

drawCenteredText : String -> IO ()
drawCenteredText x = drawText x 10 10 20 (MkColor (chr 80) (chr 80) (chr 80) (chr 255))

drawFrame : GameState -> IO ()
drawFrame state = do
  beginDrawing
  clearBackground $ MkColor (chr 245) (chr 245) (chr 245) (chr 245)
  case state of
    NotStarted => drawCenteredText "PRESS [ENTER] TO START"
    GameOver => drawCenteredText "PRESS [ENTER] TO PLAY AGAIN"
    Playing state => do
      drawGrid
      drawSnake state.snake
      drawGridSquare state.fruit blue
  endDrawing

loop : GameState -> IO ()
loop state = do
     shouldClose <- windowShouldClose
     if shouldClose then do
       closeWindow
       else do
         newState <- updateState state
         drawFrame newState
         loop newState

export main : IO ()
main = do
     initWindow screenWidth screenHeight "hello world"
     setTargetFPS 60
     fruit <- randomFruit
     loop $ NotStarted
