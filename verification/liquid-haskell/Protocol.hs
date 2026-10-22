{-@ LIQUID "--reflection" @-}
{-@ LIQUID "--ple"        @-}

module Protocol where

{-@ type Phase = {v:Double | -3.1415926535 <= v && v <= 3.1415926535} @-}
type Phase = Double

{-@ type Dim = {n:Int | n > 0 && n <= 1024} @-}
type Dim = Int

{-@ data Payload = Payload
      { experimentId :: String
      , iteration    :: {i:Int | 0 <= i && i <= 14}
      , dim          :: Dim
      , params       :: {ps:[Phase] | len ps == dim}
      , energy       :: Double
      , uncertainty  :: {u:Double | u >= 0}
      , sequence     :: Nat
      }
@-}
data Payload = Payload
  { experimentId :: String
  , iteration    :: Int
  , dim          :: Int
  , params       :: [Phase]
  , energy       :: Double
  , uncertainty  :: Double
  , sequence     :: Int
  }

{-@ measure len @-}
len :: [a] -> Int
len []     = 0
len (_:xs) = 1 + len xs

{-@ rejectPreserves :: p:Payload -> Payload @-}
rejectPreserves :: Payload -> Payload
rejectPreserves p = p

{-@ transition :: p:Payload -> {c:[Phase] | len c == dim p}
               -> {r:Payload | iteration r == iteration p + 1 ||
                               (iteration r == iteration p && params r == params p)}
@-}
transition :: Payload -> [Phase] -> Payload
transition p candidate =
  if True  -- acceptance decided externally; refinement only constrains structure
  then p { iteration = iteration p + 1
         , params    = candidate }
  else rejectPreserves p
