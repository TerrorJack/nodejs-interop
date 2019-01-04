{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}

module Tests.Quotation
  ( tests
  ) where

import Control.Monad (void)
import Language.JavaScript.Inline
import Language.JavaScript.Inline.JSON
import Language.JavaScript.Inline.Session
import Test.Tasty (TestTree)
import Test.Tasty.Hspec (it, shouldBe, testSpec)

-- A test of the initial implementation, with manual Value conversion
tests :: IO TestTree
tests =
  testSpec "Inline JavaScript QuasiQuoter" $ do
    it "should add two numbers and return a Number" $ do
      result <- withJSSession defJSSessionOpts [js| 1 + 3 |]
      result `shouldBe` Number 4
    it "should concatenate two Strings" $ do
      result <- withJSSession defJSSessionOpts [js| "hello" + " goodbye" |]
      result `shouldBe` String "hello goodbye"
    it "should take in a Haskell String and return it" $ do
      let sentence = String "This is a String"
      result <- withJSSession defJSSessionOpts [js| $sentence |]
      result `shouldBe` sentence
    it "should append a Haskell-inserted String to a JavaScript String" $ do
      let sentence = String "Pineapple"
      result <- withJSSession defJSSessionOpts [js| $sentence + " on pizza" |]
      result `shouldBe` String "Pineapple on pizza"
