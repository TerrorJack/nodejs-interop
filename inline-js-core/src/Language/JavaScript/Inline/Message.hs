{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StrictData #-}

module Language.JavaScript.Inline.Message
  ( SendMsg(..)
  , encodeSendMsg
  , RecvMsg(..)
  , decodeRecvMsg
  ) where

import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text.Encoding as Text
import qualified Language.JavaScript.Inline.JSCode as JSCode
import qualified Language.JavaScript.Inline.JSON as JSON
import Language.JavaScript.Inline.MessageCounter

data SendMsg = Eval
  { isAsync :: Bool
  , evalTimeout, resolveTimeout :: Maybe Double
  , evalCode :: JSCode.JSCode
  }

encodeSendMsg :: MsgId -> SendMsg -> JSON.Value
encodeSendMsg msg_id msg =
  case msg of
    Eval {..} ->
      JSON.Array
        [ _head
        , JSON.Bool isAsync
        , _maybe_number evalTimeout
        , _maybe_number resolveTimeout
        , JSON.String $ JSCode.codeToString evalCode
        ]
  where
    _head = JSON.Number $ fromIntegral msg_id
    _maybe_number = maybe (JSON.Bool False) JSON.Number

data RecvMsg = Result
  { isError :: Bool
  , result :: LBS.ByteString
  }

decodeRecvMsg :: JSON.Value -> Either String (MsgId, RecvMsg)
decodeRecvMsg v =
  case v of
    JSON.Array [JSON.Number _msg_id, JSON.Bool is_err, JSON.String r] ->
      Right
        ( truncate _msg_id
        , Result {isError = is_err, result = LBS.fromStrict $ Text.encodeUtf8 r})
    _ -> _err
  where
    _err =
      Left $
      "Language.JavaScript.Inline.Message.decodeRecvMsg: failed to decode " <>
      show v
