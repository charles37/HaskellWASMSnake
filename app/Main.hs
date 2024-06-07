module Main where

import           Foreign.C.String
import           Foreign.Marshal.Alloc
import           Foreign.Ptr
import           Store

import Prelude hiding (Left, Right)
import System.Random.Mersenne (randomIO)

import           Data.IORef
import qualified Data.Map                as M
import           System.IO.Unsafe


main :: IO ()
main = mempty

foreign export ccall callocBuffer :: Int -> IO (Ptr a)
callocBuffer = callocBytes

foreign export ccall freeBuffer :: Ptr a -> IO ()
freeBuffer = free

foreign export ccall echo :: CString -> IO CString
echo a = peekCString a >>= newCString

foreign export ccall save :: CString -> CString -> IO ()
save k v = do
  k' <- peekCString k
  v' <- peekCString v
  save2 k' v'

foreign export ccall load :: CString -> IO CString
load k = peekCString k >>= load2 >>= newCString

foreign export ccall size :: IO Int
size = size2


data Direction = Up | Down | Left | Right deriving (Show, Eq)

type Position = (Int, Int)

data GameState = GameState
  { snake :: [Position]
  , direction :: Direction
  , food :: Position
  } deriving (Show)

width :: Int
width = 20

height :: Int
height = 20

initialGameStateIO :: IO GameState
initialGameStateIO = do 
  let initialSnake = [(width `div` 2, height `div` 2)]
  GameState initialSnake Right <$> randomPosition

randomPosition :: IO Position
randomPosition = do
  x <- randomIO --(0, width - 1)
  y <- randomIO --(0, height - 1)
  let x' = x `mod` width
  let y' = y `mod` height
  pure (x', y')

{-# NOINLINE initialGameState #-}
initialGameState = unsafePerformIO $ newIORef =<< initialGameStateIO


foreign export ccall updateGameStateIO :: IO ()
updateGameStateIO :: IO ()
updateGameStateIO = do

  input <-load2 "input"

  gameState <- readIORef initialGameState
  randomPosition' <- randomPosition

  let direction' = case input of
        "ArrowUp" -> Up
        "ArrowDown" -> Down
        "ArrowLeft" -> Left
        "ArrowRight" -> Right
        _ -> direction gameState
  let newSnakeHead = case direction' of
        Up -> (x, y - 1)
        Down -> (x, y + 1)
        Left -> (x - 1, y)
        Right -> (x + 1, y)
        where
          (x, y) = head $ snake gameState

  let (newFood, gotFood) = if newSnakeHead == food gameState
        then (randomPosition', True)
        else (food gameState, False)


  let newSnake = if gotFood
        then newSnakeHead : snake gameState
        else take (length $ snake gameState) $ newSnakeHead : snake gameState
  

  let newGameState = GameState newSnake direction' newFood
  let output = gameStateToString newGameState
  writeIORef initialGameState newGameState
  -- withCString output (save "output")
  save2 "output" output

gameStateToString :: GameState -> String
gameStateToString gameState = unlines rows
  where
    rows = [[charAt (x, y) | x <- [0..width - 1]] | y <- [0..height - 1]]
    charAt pos
      | pos `elem` snake gameState = '*'
      | pos == food gameState = '@'
      | otherwise = '.'

