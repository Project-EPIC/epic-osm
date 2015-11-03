import spray.json._
import DefaultJsonProtocol._

case class Actor(
	id: String,
	link: String,
	displayName: Option[String],
	postedTime: String,
	summary: Option[String],
	friendsCount: Double,
	followersCount: Double,
	listedCount: Double,
	statusesCount: Double,
	preferredUsername: String,
	favoritesCount: Double
)

/* Automatically generated from http://json2caseclass.cleverapps.io/ */

case class User_mentions(
  indices: List[Double],
  screen_name: String,
  id_str: String,
  name: String
)

case class Urls(
  url: String,
  expanded_url: String
)

case class Hashtags(
  text: String,
  indices: List[Double]
)

case class Twitter_entities(
  urls: Option[ List[Urls] ],
  hashtags: Option[ List[Hashtags] ],
  user_mentions: Option[ List[User_mentions] ]
)

case class Matching_rules(
	value: String,
	tag: String
)

case class Gnip_Meta(
	matching_rules: Option[List[Matching_rules]]
)

case class GnipTweet(
	actor: Actor,
	id: String,
	postedTime: String,
	body: String,
 	twitter_entities: Option[Twitter_entities],
  	gnip: Gnip_Meta
){

	/* Helper Functions */
	def handle = actor.preferredUsername

	def gnip_tag = gnip.matching_rules.get(0).tag
}

object MyGNIPJsonProtocol extends DefaultJsonProtocol{
  implicit val actorFormat = jsonFormat(Actor, "id", "link", "displayName", "postedTime", "summary", "friendsCount", "followersCount", "listedCount", "statusesCount", "preferredUsername", "favoritesCount")
  
  implicit val ruleFormat  = jsonFormat(Matching_rules, "value", "tag")
  	implicit val metaFormat  = jsonFormat(Gnip_Meta, "matching_rules")
  
  implicit val urlFormat   = jsonFormat(Urls, "url", "expanded_url")
  implicit val hashtagFormat=jsonFormat(Hashtags,"text", "indices")
  implicit val userMention = jsonFormat(User_mentions, "indices", "screen_name", "id_str", "name")
  	implicit val twitterEntitiesFormat = jsonFormat(Twitter_entities, "urls", "hashtags", "user_mentions")
  
  implicit val tweetFormat = jsonFormat(GnipTweet, "actor", "id", "postedTime", "body", "twitter_entities", "gnip")
}

import MyGNIPJsonProtocol._

object EpicGNIP {

	def getJsObject(jsonString: String)={
		val jsonAst = jsonString.parseJson
		jsonAst.asJsObject
	}

	def asGnipTweet(jsonAst: JsValue)={
		jsonAst.convertTo[GnipTweet]
	}
}
