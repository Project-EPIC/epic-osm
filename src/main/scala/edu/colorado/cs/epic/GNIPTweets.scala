package edu.colorado.cs.epic

import spray.json._
import DefaultJsonProtocol._

import com.github.nscala_time.time.Imports._


case class Actor(
	id: String,
	link: String,
	displayName: Option[String],
	postedTime: String,
	summary: Option[String],
	friendsCount: Int,
	followersCount: Int,
	listedCount: Int,
	statusesCount: Int,
	preferredUsername: String,
	favoritesCount: Int
)

case class Generator(
	displayName: 	Option[String],
    link: 			Option[String]
)

case class ReplyTo(
	link: 			Option[String]
)

case class Geo(
	coordinates: List[Double],
	`type`: String
)

// case class ExpandedGeo(

// )

/* Automatically generated from http://json2caseclass.cleverapps.io/ */

case class User_mentions(
  indices: List[Int],
  screen_name: String,
  id_str: Option[ String ],
  name: Option[ String]
)

case class Urls(
  url: String,
  expanded_url: Option[String]
)

case class Hashtags(
  text: String,
  indices: List[Int]
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
	actor: 		Actor,
	id: 		String,
	postedTime: String,
	body: 		String,
	link:   	Option[String],
	retweet_count: Option[Int],
	inReplyTo: 	Option[ReplyTo],
	verb:   	String,
	generator: 	Option[Generator],
 	twitter_entities: Option[Twitter_entities],
 	geo:    	Option[Geo],
  	gnip: 		Gnip_Meta
){

	/* Helper Functions */
	def handle    = actor.preferredUsername

	def gnip_tags = gnip.matching_rules.toList(0).map(t => (t.tag))

	def date      = DateTime.parse(postedTime)

	def has_gnip_tag(tag: String) : Boolean={
		gnip_tags.indexOf(tag) >= 0
	}
}

object MyGNIPJsonProtocol extends DefaultJsonProtocol{
  
  implicit val actorFormat 		= jsonFormat(Actor, "id", "link", "displayName", "postedTime", "summary", "friendsCount", "followersCount", "listedCount", "statusesCount", "preferredUsername", "favoritesCount")
  implicit val generatorFormat  = jsonFormat(Generator, "displayname", "link")
  implicit val replyToFormat    = jsonFormat(ReplyTo, "link")

  implicit val ruleFormat		= jsonFormat(Matching_rules, "value", "tag")
  	implicit val metaFormat		= jsonFormat(Gnip_Meta, "matching_rules")
  
  implicit val geoFormat 		= jsonFormat(Geo, "coordinates", "type")

  implicit val urlFormat   		= jsonFormat(Urls, "url", "expanded_url")
  implicit val hashtagFormat	= jsonFormat(Hashtags,"text", "indices")
  implicit val userMention 		= jsonFormat(User_mentions, "indices", "screen_name", "id_str", "name")
  	implicit val twitterEntitiesFormat = jsonFormat(Twitter_entities, "urls", "hashtags", "user_mentions")
  
  implicit val tweetFormat 		= jsonFormat(GnipTweet, "actor", "id", "postedTime", "body", "link", "retweet_count", "inReplyTo", "verb", "generator", "twitter_entities", "geo", "gnip")

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
