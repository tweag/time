-- #hide
module Data.Time.Clock.CTimespec where

#include "HsTimeConfig.h"

#if !defined(mingw32_HOST_OS) && HAVE_CLOCK_GETTIME

#if __GLASGOW_HASKELL__ >= 709
import Foreign
#else
import Foreign.Safe
#endif
import Foreign.C

#include <time.h>

data CTimespec = MkCTimespec CTime CLong

instance Storable CTimespec where
    sizeOf _ = #{size struct timespec}
    alignment _ = alignment (undefined :: CLong)
    peek p = do
        s  <- #{peek struct timespec, tv_sec } p
        ns <- #{peek struct timespec, tv_nsec} p
        return (MkCTimespec s ns)
    poke p (MkCTimespec s ns) = do
        #{poke struct timespec, tv_sec } p s
        #{poke struct timespec, tv_nsec} p ns

foreign import ccall unsafe "time.h clock_gettime"
    clock_gettime :: #{type clockid_t} -> Ptr CTimespec -> IO CInt

-- | Get the current POSIX time from the system clock.
getCTimespec :: IO CTimespec
getCTimespec = alloca (\ptspec -> do
    throwErrnoIfMinus1_ "clock_gettime" $
        clock_gettime #{const CLOCK_REALTIME} ptspec
    peek ptspec
    )

#endif
