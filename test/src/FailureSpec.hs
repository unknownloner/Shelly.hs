module FailureSpec ( failureSpec ) where

import TestInit

failureSpec :: Spec
failureSpec = do
  let discardException action = shelly $ catchany_sh action (\_ -> return ())

  describe "failure set to stderr" $
    it "writes a failure message to stderr" $ do
      shelly $ discardException $
        liftIO $ shellyNoDir $ do
          test_d ".shelly" >>= liftIO . assert . not
          echo "testing"
          error "bam!"
      assert . not =<< shelly (test_d ".shelly")

  describe "failure set to directory" $
    it "writes a failure message to a .shelly directory" $ do
      shelly $ discardException $
        shelly $ do
          test_d ".shelly" >>= liftIO . assert . not
          echo "testing"
          error "bam!"
      assert =<< shelly ( do
          exists <- test_d ".shelly"
          rm_rf ".shelly"
          return exists
        )
