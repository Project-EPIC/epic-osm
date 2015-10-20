import spray.json._
import DefaultJsonProtocol._

case class SimpleTweet(handle: String, time: String, text: String, context: Boolean, geo: Array[Float])

object SimpleTweet

object EpicSparkTwitter {
	
}
