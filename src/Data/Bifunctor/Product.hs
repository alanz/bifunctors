{-# LANGUAGE CPP #-}

#if __GLASGOW_HASKELL__ >= 708
{-# LANGUAGE DeriveDataTypeable #-}
#endif

#if __GLASGOW_HASKELL__ >= 706
{-# LANGUAGE PolyKinds #-}
#endif

-----------------------------------------------------------------------------
-- |
-- Copyright   :  (C) 2008-2015 Jesse Selover, Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  provisional
-- Portability :  portable
--
-- The product of two bifunctors.
----------------------------------------------------------------------------
module Data.Bifunctor.Product
  ( Product(..)
  ) where

#if __GLASGOW_HASKELL__ < 710
import Control.Applicative
#endif

import Data.Biapplicative
import Data.Bifoldable
import Data.Bifunctor.Functor
import Data.Bitraversable

#if __GLASGOW_HASKELL__ < 710
import Data.Monoid hiding (Product)
#endif

#if __GLASGOW_HASKELL__ >= 708
import Data.Typeable
#endif

-- | Form the product of two bifunctors
data Product f g a b = Pair (f a b) (g a b)
  deriving ( Eq, Ord, Show, Read
#if __GLASGOW_HASKELL__ >= 708
           , Typeable
#endif
           )

instance (Bifunctor f, Bifunctor g) => Bifunctor (Product f g) where
  first f (Pair x y) = Pair (first f x) (first f y)
  {-# INLINE first #-}
  second g (Pair x y) = Pair (second g x) (second g y)
  {-# INLINE second #-}
  bimap f g (Pair x y) = Pair (bimap f g x) (bimap f g y)
  {-# INLINE bimap #-}

instance (Biapplicative f, Biapplicative g) => Biapplicative (Product f g) where
  bipure a b = Pair (bipure a b) (bipure a b)
  {-# INLINE bipure #-}
  Pair w x <<*>> Pair y z = Pair (w <<*>> y) (x <<*>> z)
  {-# INLINE (<<*>>) #-}

instance (Bifoldable f, Bifoldable g) => Bifoldable (Product f g) where
  bifoldMap f g (Pair x y) = bifoldMap f g x `mappend` bifoldMap f g y
  {-# INLINE bifoldMap #-}

instance (Bitraversable f, Bitraversable g) => Bitraversable (Product f g) where
  bitraverse f g (Pair x y) = Pair <$> bitraverse f g x <*> bitraverse f g y
  {-# INLINE bitraverse #-}

instance BifunctorFunctor (Product p) where
  bifmap f (Pair p q) = Pair p (f q)

instance BifunctorComonad (Product p) where
  biextract (Pair _ q) = q
  biduplicate pq@(Pair p _) = Pair p pq
  biextend f pq@(Pair p _) = Pair p (f pq)
