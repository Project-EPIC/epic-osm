package edu.colorado.cs.epic

object TweetSubModels{

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
	){
		def get_hashtags = hashtags
	}

	case class Matching_rules(
		value: String,
		tag: String
	)

	case class Gnip_Meta(
		matching_rules: Option[List[Matching_rules]]
	)
}