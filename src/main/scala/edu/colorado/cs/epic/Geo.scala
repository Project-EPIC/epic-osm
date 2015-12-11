package edu.colorado.cs.epic

//Geographic Pieces
import com.vividsolutions.jts.geom.Geometry
import com.vividsolutions.jts.geom.Point
import com.vividsolutions.jts.geom.Coordinate
import com.vividsolutions.jts.geom.GeometryFactory
import com.vividsolutions.jts.geom.PrecisionModel

import com.vividsolutions.jts.io.WKTReader

//import org.geotools.geojson._
//import org.geotools.geojson.geom.GeometryJSON;

object Geo{

	val geometryFactory = new GeometryFactory(new PrecisionModel(), 4326)

	case class GeoTweet(
		coordinates: List[Double], 
		`type`: String){
	
		def point: Point={
			geometryFactory.createPoint(new Coordinate(coordinates(0), coordinates(1)))
		}
	}

	def geometryFromWKT(input: String)={
		val reader = new WKTReader(geometryFactory)
		reader.read(input)
	}
}