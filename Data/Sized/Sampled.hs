{-# LANGUAGE ScopedTypeVariables #-}
module Data.Sized.Sampled where

import Data.Ratio
import Data.Sized.Signed
import Data.Sized.Ix

-- A signed fixed precision number, with max value m, via n sampled bits.

-- We add an extra bit, to represent the *sign*.
data Sampled m n = Sampled (Signed n) Rational
--	deriving Show

mkSampled :: forall n m . (Size n,  Enum n, Size m) => Rational -> Sampled m n
mkSampled v = Sampled val (fromIntegral scale * fromIntegral val / fromIntegral precision)
   where scale     :: Integer
	 scale     = fromIntegral (size (undefined :: m))
	 precision :: Integer
	 precision = 2 ^ (fromIntegral (size (undefined :: n) - 1) :: Integer)
	 val0      :: Rational
	 val0      = v / fromIntegral scale
	 val1 	   :: Integer
		     -- Key rounding step
	 val1      = round (val0 * fromIntegral precision)
	 val       = if val1 >= precision then maxBound
		else if val1 <= -precision then minBound
		else fromInteger val1

instance (Size ix, Enum ix) => Eq (Sampled m ix) where
	(Sampled a _) == (Sampled b _) = a == b
instance (Size ix, Enum ix) => Ord (Sampled m ix) where
	(Sampled a _) `compare` (Sampled b _) = a `compare` b
instance (Size ix, Enum ix) => Show (Sampled m ix) where
	show (Sampled _ s) = show (fromRational s :: Double)
instance (Enum ix, Size ix, Size m) => Read (Sampled m ix) where
	readsPrec i str = [ (mkSampled a,r) | (a,r) <- readsPrec i str ]

instance (Size ix, Enum ix, Size m) => Num (Sampled m ix) where
	(Sampled _ a) + (Sampled _ b) = mkSampled $ a + b
	(Sampled _ a) - (Sampled _ b) = mkSampled $ a - b
	(Sampled _ a) * (Sampled _ b) = mkSampled $ a * b
	abs (Sampled _ n) = mkSampled $ abs n
	signum (Sampled _ n) = mkSampled $ signum n
	fromInteger n = mkSampled (fromInteger n)

instance (Size ix, Enum ix, Size m) => Real (Sampled m ix) where
	toRational (Sampled _ n) = toRational n
	
instance (Size ix, Enum ix, Size m) => Fractional (Sampled m ix) where
	fromRational n      = mkSampled n
	recip (Sampled _ n) = mkSampled $ recip n

-- This is a bit of a hack, and may generate -ve values from fromEnum.
instance (Size ix, Enum ix, Size m) => Enum (Sampled m ix) where
	fromEnum (Sampled n _) = fromEnum n

	toEnum n = mkSampled (fromIntegral scale * fromIntegral val / fromIntegral precision)
	   where val :: Signed ix
		 val = toEnum n
   		 scale     :: Integer
	 	 scale     = fromIntegral (size (undefined :: m))
	 	 precision :: Integer
	 	 precision = 2 ^ (fromIntegral (size (undefined :: ix) - 1) :: Integer)


