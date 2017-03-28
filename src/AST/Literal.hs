{-# OPTIONS_GHC -Wall #-}
{-# LANGUAGE OverloadedStrings #-}
module AST.Literal
  ( Literal(..)
  , toBuilder
  , GLType(..), glTypeToText, Shader(..)
  )
  where


import Data.Binary
import qualified Data.Map as Map
import Data.Monoid ((<>))
import Data.Text (Text)
import Data.Text.Lazy.Builder (Builder, fromText)
import Data.Text.Lazy.Builder.Int (decimal)
import Data.Text.Lazy.Builder.RealFloat (realFloat)



-- LITERALS


data Literal
  = Chr Text
  | Str Text
  | IntNum Int
  | FloatNum Double
  | Boolean Bool
  deriving (Eq, Ord)


toBuilder :: Literal -> Builder
toBuilder literal =
  case literal of
    Chr c -> fromText ("'" <> c <> "'")
    Str s -> fromText ("\"" <> s <> "\"")
    IntNum n -> decimal n
    FloatNum n -> realFloat n
    Boolean bool -> if bool then "True" else "False"



-- WebGL TYPES


data Shader =
  Shader
    { attribute :: Map.Map Text GLType
    , uniform :: Map.Map Text GLType
    , varying :: Map.Map Text GLType
    }
    deriving (Eq)


data GLType
  = Int
  | Float
  | V2
  | V3
  | V4
  | M4
  | Texture
  deriving (Eq)


glTypeToText :: GLType -> Text
glTypeToText glTipe =
  case glTipe of
    V2 -> "Math.Vector2.Vec2"
    V3 -> "Math.Vector3.Vec3"
    V4 -> "Math.Vector4.Vec4"
    M4 -> "Math.Matrix4.Mat4"
    Int -> "Int"
    Float -> "Float"
    Texture -> "WebGL.Texture"



-- BINARY


instance Binary Literal where
  put literal =
    case literal of
      Chr chr ->
        putWord8 0 >> put chr

      Str str ->
        putWord8 1 >> put str

      IntNum n ->
        putWord8 2 >> put n

      FloatNum n ->
        putWord8 3 >> put n

      Boolean True ->
        putWord8 4

      Boolean False ->
        putWord8 5

  get =
    do  word <- getWord8
        case word of
          0 -> Chr <$> get
          1 -> Str <$> get
          2 -> IntNum <$> get
          3 -> FloatNum <$> get
          4 -> pure $ Boolean True
          5 -> pure $ Boolean False
          _ -> error "bad binary for AST.Literal"
