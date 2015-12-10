package edu.colorado.cs.epic

import com.vividsolutions.jts.geom.Geometry
import com.vividsolutions.jts.geom.Point
import com.vividsolutions.jts.geom.Coordinate

import com.vividsolutions.jts.geom.GeometryFactory
import com.vividsolutions.jts.geom.PrecisionModel

object TweetSubModels{

	val geometryFactory = new GeometryFactory(new PrecisionModel(), 4326)
	
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

	case class GeoTweet(
		coordinates: List[Double], 
		`type`: String){
	
		//Pass it just coordinates, it knows it's a point
		//def this(coordinates: List[Double]) = this(coordinates, "Point")

		def point: Point={
			geometryFactory.createPoint(new Coordinate(coordinates(0), coordinates(1)))
		}
	}
}