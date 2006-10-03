-- | Some functions and generators suitable for writing QuickCheck
-- properties.

module Termination.TestHelpers
  ( -- * Algebraic properties
    associative
  , commutative
  , isZero
  , identity
  , leftDistributive
  , rightDistributive
    -- * Other tests
  , allEqual
    -- * Generators
  , natural
  , list
  , listOfLength
  )
  where

import Test.QuickCheck
import Data.List

------------------------------------------------------------------------
-- Algebraic properties

-- | Is the operator associative?

associative :: (Arbitrary a, Eq a, Show a)
            => (a -> a -> a)
            -> a -> a -> a -> Bool
associative (+) = \x y z ->
  x + (y + z) == (x + y) + z

-- | Is the operator commutative?

commutative :: (Arbitrary a, Eq a, Show a)
            => (a -> a -> a)
            -> a -> a -> Bool
commutative (+) = \x y ->
  x + y == y + x

-- | Is the element a zero for the operator?

isZero :: (Arbitrary a, Eq a, Show a)
     => a -> (a -> a -> a)
     -> a -> Bool
isZero zer (*) = \x ->
  (zer * x == zer)
  &&
  (x * zer == zer)

-- | Is the element a unit for the operator?

identity :: (Arbitrary a, Eq a, Show a)
         => a -> (a -> a -> a)
         -> a -> Bool
identity one (*) = \x ->
  (one * x == x)
  &&
  (x * one == x)

-- | Does the first operator distribute (from the left) over the
-- second one?

leftDistributive
  :: (Arbitrary a, Eq a, Show a)
  => (a -> a -> a) -> (a -> a -> a)
  -> a -> a -> a -> Bool
leftDistributive (*) (+) = \x y z ->
  x * (y + z) == (x * y) + (x * z)

-- | Does the first operator distribute (from the right) over the
-- second one?

rightDistributive
  :: (Arbitrary a, Eq a, Show a)
  => (a -> a -> a) -> (a -> a -> a)
  -> a -> a -> a -> Bool
rightDistributive (*) (+) = \x y z ->
  (x + y) * z == (x * z) + (y * z)

------------------------------------------------------------------------
-- Other tests

-- | Checks if all the elements in the list are equal. Assumes that
-- the 'Eq' instance stands for an equivalence relation.

allEqual :: Eq a => [a] -> Bool
allEqual []       = True
allEqual (x : xs) = all (== x) xs

------------------------------------------------------------------------
-- Generators

-- | Generates natural numbers.

natural :: (Arbitrary i, Integral i) => Gen i
natural = fmap abs arbitrary

-- | Generates a list of the given length, using the given generator
-- to generate the elements.

listOfLength :: Integral i => i -> Gen a -> Gen [a]
listOfLength n gen = sequence $ genericReplicate n gen

prop_listOfLength =
  forAll (natural :: Gen Integer) $ \n ->
    forAll (listOfLength n arbitrary :: Gen [Integer]) $ \xs ->
      genericLength xs == n

-- | Generates a list, using the given generator to generate the
-- elements.

list :: Gen a -> Gen [a]
list gen = do
  n <- natural :: Gen Integer
  listOfLength n gen

------------------------------------------------------------------------
-- All tests

tests = do
  quickCheck prop_listOfLength
