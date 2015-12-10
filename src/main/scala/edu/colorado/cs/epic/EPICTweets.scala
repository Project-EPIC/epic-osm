package edu.colorado.cs.epic

import CustomTweetJsonProtocol._
import spray.json._

//Import the Json Protocols from Spray (Defined in TweetModelHelpers)

import GnipTweet._
import FullTweet._

object EpicTweets{

	def getJsObject(jsonString: String)={
    	val jsonAst = jsonString.parseJson
    	jsonAst.asJsObject
  	}

	def asGnipTweet(jsonAst: JsValue)={
    	jsonAst.convertTo[GnipTweet]
  	}

  	def asFullTweet(jsonAst: JsValue)={
    	jsonAst.convertTo[FullTweet]
  	}
	
}