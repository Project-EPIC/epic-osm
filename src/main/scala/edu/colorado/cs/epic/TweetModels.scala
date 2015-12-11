package edu.colorado.cs.epic

import spray.json._

import com.github.nscala_time.time.Imports._

//Keeping Geo Models Separate for right now
// import GeoTweet._

//Import All the SubPieces
import TweetSubModels._
import Geo._

//Basic Tweet Functions
abstract class Tweet {
	val coordinates: Option[GeoTweet] = None
	def sayHi: String = {
		"Hi"
	}
	def hasGeo: Boolean={
		coordinates != None
	}
}

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
 	override val coordinates: Option[GeoTweet],
  	gnip: 		Gnip_Meta
) extends Tweet{

	/* Helper Functions */
	def text      = body
	def handle    = actor.preferredUsername
	def gnip_tags = gnip.matching_rules.toList(0).map(t => (t.tag))
	def date      = DateTime.parse(postedTime)
	def has_gnip_tag(tag: String) : Boolean={
		gnip_tags.indexOf(tag) >= 0
	}
}

case class FullTweet(
	id: 		String,
	created_at: String,
	text: 		String,
	retweet_count: Option[Int],
	source: 	String,
 	entities:   Twitter_entities,
 	override val coordinates: Option[GeoTweet]
	
	)extends Tweet{
		def date ={
			//What format is this, is this what we always have – No!?
			val formatter = DateTimeFormat.forPattern("EEE MMM d HH:mm:ss Z YYYY")
			formatter.parseDateTime(created_at)
		}
}

//The Nitty Gritty JSONProtocol Pieces to put it all together...
object CustomTweetJsonProtocol extends DefaultJsonProtocol{
  
  implicit val actorFormat 		= jsonFormat(Actor, "id", "link", "displayName", "postedTime", "summary", "friendsCount", "followersCount", "listedCount", "statusesCount", "preferredUsername", "favoritesCount")
  implicit val generatorFormat  = jsonFormat(Generator, "displayname", "link")
  implicit val replyToFormat    = jsonFormat(ReplyTo, "link")

  implicit val ruleFormat		= jsonFormat(Matching_rules, "value", "tag")
  	implicit val metaFormat		= jsonFormat(Gnip_Meta, "matching_rules")
  
  implicit val geoFormat 		= jsonFormat(GeoTweet, "coordinates", "type")

  implicit val urlFormat   		= jsonFormat(Urls, "url", "expanded_url")
  implicit val hashtagFormat	= jsonFormat(Hashtags,"text", "indices")
  implicit val userMention 		= jsonFormat(User_mentions, "indices", "screen_name", "id_str", "name")
  	implicit val twitterEntitiesFormat = jsonFormat(Twitter_entities, "urls", "hashtags", "user_mentions")
  
  implicit val gnipTweetFormat   = jsonFormat(GnipTweet, "actor", "id", "postedTime", "body", "link", "retweet_count", "inReplyTo", "verb", "generator", "twitter_entities", "geo", "gnip")
  implicit val fullTweetFormat   = jsonFormat(FullTweet, "id_str", "created_at", "text", "retweet_count", "source", "entities", "coordinates")
}

