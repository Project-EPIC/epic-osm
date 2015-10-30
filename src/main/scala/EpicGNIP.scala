import spray.json._
import DefaultJsonProtocol._

case class GnipTweet(
	actor:  Map[String, JsValue],
	body: 	String,
	postedTime: String,
	retweetCount: Int,
	gnip:   Map[String, JsValue]
)

object GnipTweet

object MyGNIPJsonProtocol extends DefaultJsonProtocol {
  implicit val activityFormat = jsonFormat5(GnipTweet.apply)
}

import MyGNIPJsonProtocol._

object EpicGNIP {

	def parseJsonToTweet(jsonString: String)={
    	val jsonAst = jsonString.parseJson
    	jsonAst.convertTo[GnipTweet]
	}

}
