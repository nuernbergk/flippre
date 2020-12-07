{-# LANGUAGE CPP #-}

module Text.FliPpr.Err where

#if !MIN_VERSION_base(4,11,0)
import qualified Control.Monad.Fail as Fail
#endif

import           Text.FliPpr.Doc    as D

data Err a = Ok !a | Fail !D.Doc

instance Functor Err where
  fmap f (Ok a)   = Ok (f a)
  fmap _ (Fail d) = Fail d
  {-# INLINE fmap #-}

instance Applicative Err where
  pure = Ok
  {-# INLINE pure #-}
  Fail d <*> Ok _    = Fail d
  Fail d <*> Fail d' = Fail (d D.$$ d')
  Ok   _ <*> Fail d  = Fail d
  Ok   f <*> Ok a    = Ok (f a)
  {-# INLINABLE (<*>) #-}

instance Monad Err where
  return = pure
  {-# INLINE return #-}
  Fail d >>= _ = Fail d
  Ok a >>= f   = f a
  {-# INLINE (>>=) #-}

#if !MIN_VERSION_base(4,11,0)
  fail = Fail.fail
#endif

instance MonadFail Err where
  fail = Fail . D.text

instance Show a => Show (Err a) where
  show (Ok a)   = "Ok " ++ show a
  show (Fail s) = show (D.text "Error: " <+> D.align s)

err :: D.Doc -> Err a
err = Fail
{-# INLINE err #-}
