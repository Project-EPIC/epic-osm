import spray.json._
import DefaultJsonProtocol._

//The simplest case class: A Tweet
case class SimpleTweet(
	handle: 	String, 
	time: 		String, 
	text: 		String, 
	context:    Boolean,
	geo: 		Array[Float]
)

object SimpleTweet

object MyJsonProtocol extends DefaultJsonProtocol {
  implicit val tweetFormat = jsonFormat5(SimpleTweet.apply)
}

import MyJsonProtocol._

object EpicTwitter {

	def parseJsonToTweet(jsonString: String)={
    	val jsonAst = jsonString.parseJson
    	jsonAst.convertTo[SimpleTweet] 
	}

}
