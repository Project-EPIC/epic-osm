package edu.colorado.cs.epic

//Basic FileIO
import java.nio.file.{Files,Path,Paths}
import java.io.{File,PrintWriter}

//Desired Tweet Format
import EpicTweets._

import Geo._

object SparkTweets {

  def main(args: Array[String]) {

    println("Running Main from SparkTweets")

    //Load the Tweets
    val tweet_file = "test/sandy_keyword_geo_tweet_sample.json"
    val strings        = get_tweets(tweet_file)
    val tweetJsons     = strings.map{t => getJsObject(t)}

    //Convert the tweets into FullTweet Objects
    val tweets       = tweetJsons.map{t => asFullTweet(t)}
    
    //Filter on GeoTweets Example
    filterGeoTweetsExample(tweets)

    //Handle Time
    filterOnTimeExample(tweets)

  }

  def filterOnTimeExample(tweets: Array[FullTweet])={
    tweets.take(25).foreach(t => {
      println(t.created_at);
      println(t.date)
    })
  }

  def filterGeoTweetsExample(tweets: Array[FullTweet])={
    //How about the evacuation zones as WKT?
    val zone_a_path        = Paths.get("test/zone_a_wkt.txt").toAbsolutePath.normalize
    val evac_handle        = io.Source.fromFile(zone_a_path.toFile)
    val evac_string        = evac_handle.mkString;
    evac_handle.close 
    val nycEvacZoneA       =  geometryFromWKT(evac_string)
    
    println(s"Found ${tweets.size} tweets")
    val geo_tweets = tweets.filter{t => t.hasGeo}
    println(s"Found ${geo_tweets.size} geo tweets")

    var inZoneA = geo_tweets.filter(t => {
      nycEvacZoneA.contains( t.coordinates.get.point )
    })

    println(s"Found ${inZoneA.size} tweets in Zone A")
  }

  def GNIPTweetTesting={
    // val t2 = """{"id":"tag:search.twitter.com,2005:268922234935066624","objectType":"activity","actor":{"objectType":"person","id":"id:twitter.com:80948607","link":"http://www.twitter.com/soflaliving","displayName":"Tim Martin","postedTime":"2009-10-08T21:30:05.000Z","image":"https://si0.twimg.com/profile_images/530970514/DSC07297_normal.JPG","summary":"Real Estate Professional in Florida - Residential or Commerical - Buy or Sell, from Palm Beach To Stuart!  Retire To The Sunshine State!","links":[{"href":null,"rel":"me"}],"friendsCount":612,"followersCount":633,"listedCount":11,"statusesCount":23286,"twitterTimeZone":"Quito","verified":false,"utcOffset":"-18000","preferredUsername":"soflaliving","languages":["en"],"location":{"objectType":"place","displayName":"Palm Beach Gardens, Florida"},"favoritesCount":0},"verb":"share","postedTime":"2012-11-15T03:43:51.000Z","generator":{"displayName":"TweetDeck","link":"http://www.tweetdeck.com"},"provider":{"objectType":"service","displayName":"Twitter","link":"http://www.twitter.com"},"link":"http://twitter.com/soflaliving/statuses/268922234935066624","body":"RT @jtLOL: WSVN-TV - Almost 1K ballots found in Broward elections warehouse http://t.co/9DEz2PeG","object":{"id":"tag:search.twitter.com,2005:268877932519378944","objectType":"activity","actor":{"objectType":"person","id":"id:twitter.com:11203972","link":"http://www.twitter.com/jtLOL","displayName":"Jim Treacher","postedTime":"2007-12-15T20:59:10.000Z","image":"https://si0.twimg.com/profile_images/2163908711/DontEatMyDog_normal.jpg","summary":"","links":[{"href":"http://dailycaller.com/section/dc-trawler","rel":"me"}],"friendsCount":2963,"followersCount":21596,"listedCount":1182,"statusesCount":47303,"twitterTimeZone":"Eastern Time (US & Canada)","verified":false,"utcOffset":"-18000","preferredUsername":"jtLOL","languages":["en"],"location":{"objectType":"place","displayName":"http://thedc.com/x1yuQh"},"favoritesCount":4},"verb":"post","postedTime":"2012-11-15T00:47:49.000Z","generator":{"displayName":"Tweet Button","link":"http://twitter.com/tweetbutton"},"provider":{"objectType":"service","displayName":"Twitter","link":"http://www.twitter.com"},"link":"http://twitter.com/jtLOL/statuses/268877932519378944","body":"WSVN-TV - Almost 1K ballots found in Broward elections warehouse http://t.co/9DEz2PeG","object":{"objectType":"note","id":"object:search.twitter.com,2005:268877932519378944","summary":"WSVN-TV - Almost 1K ballots found in Broward elections warehouse http://t.co/9DEz2PeG","link":"http://twitter.com/jtLOL/statuses/268877932519378944","postedTime":"2012-11-15T00:47:49.000Z"},"twitter_entities":{"urls":[{"expanded_url":"http://www.wsvn.com/news/articles/politics/21009052826783/almost-1k-ballots-found-in-broward-elections-warehouse/","indices":[65,85],"display_url":"wsvn.com/news/articles/…","url":"http://t.co/9DEz2PeG"}],"hashtags":[],"user_mentions":[]}},"twitter_entities":{"urls":[{"expanded_url":"http://www.wsvn.com/news/articles/politics/21009052826783/almost-1k-ballots-found-in-broward-elections-warehouse/","indices":[76,96],"display_url":"wsvn.com/news/articles/…","url":"http://t.co/9DEz2PeG"}],"hashtags":[],"user_mentions":[{"indices":[3,9],"screen_name":"jtLOL","id_str":"11203972","name":"Jim Treacher","id":11203972}]},"retweetCount":13,"gnip":{"matching_rules":[{"value":"from:20536357 OR from:378786790 OR from:33601736 OR from:54459679 OR from:80948607 OR from:19041199 OR from:13017662 OR from:27938990 OR from:177497027 OR from:58957417 OR from:188982269 OR from:35664799 OR from:71048920 OR from:274629078 OR from:198600686 OR from:801023155 OR from:82689705 OR from:625104277 OR from:43736643 OR from:75561626 OR from:278659206 OR from:18779683 OR from:18242668 OR from:7538352 OR from:439983001","tag":"red_hook"}],"urls":[{"url":"http://t.co/9DEz2PeG","expanded_url":"http://www.wsvn.com/news/articles/politics/21009052826783/almost-1k-ballots-found-in-broward-elections-warehouse/"}],"language":{"value":"en"}}}"""
    // val t1 = """{"id":"tag:search.twitter.com,2005:268923708150784000","objectType":"activity","actor":{"objectType":"person","id":"id:twitter.com:256795915","link":"http://www.twitter.com/JustSorinna","displayName":"Sorinna.","postedTime":"2011-02-24T02:49:30.000Z","image":"https://si0.twimg.com/profile_images/2829494544/276c3bab8a566b977d038851342ed446_normal.jpeg","summary":"Unpredictable to tell with the eyes of wonder and the mind of creativity. ","links":[{"href":"http://just-sorinna.tumblr.com","rel":"me"}],"friendsCount":322,"followersCount":532,"listedCount":2,"statusesCount":35718,"twitterTimeZone":"Eastern Time (US & Canada)","verified":false,"utcOffset":"-18000","preferredUsername":"JustSorinna","languages":["en"],"location":{"objectType":"place","displayName":"NYC"},"favoritesCount":54},"verb":"post","postedTime":"2012-11-15T03:49:43.000Z","generator":{"displayName":"web","link":"http://twitter.com"},"provider":{"objectType":"service","displayName":"Twitter","link":"http://www.twitter.com"},"link":"http://twitter.com/JustSorinna/statuses/268923708150784000","body":"@_LaurenLane lol. I was like OH NO. WHYYYY","object":{"objectType":"note","id":"object:search.twitter.com,2005:268923708150784000","summary":"@_LaurenLane lol. I was like OH NO. WHYYYY","link":"http://twitter.com/JustSorinna/statuses/268923708150784000","postedTime":"2012-11-15T03:49:43.000Z"},"inReplyTo":{"link":"http://twitter.com/_LaurenLane/statuses/268923493817655297"},"twitter_entities":{"urls":[],"hashtags":[],"user_mentions":[{"indices":[0,12],"screen_name":"_LaurenLane","id_str":"723028008","name":"Lois Lane","id":723028008}]},"retweetCount":0,"gnip":{"matching_rules":[{"value":"fake","tag":"test_tag"},{"value":"from:371668806 OR from:40380957 OR from:128126349 OR from:8394312 OR from:142820064 OR from:58365434 OR from:39257389 OR from:49546605 OR from:870707562 OR from:212665654 OR from:35220556 OR from:91923745 OR from:19345063 OR from:469339691 OR from:495582069 OR from:64631490 OR from:24826673 OR from:27569079 OR from:256795915 OR from:32841305 OR from:28341726 OR from:24091450 OR from:91686289 OR from:17399730 OR from:56737658","tag":"far_rockaway"}],"language":{"value":"en"}}}"""
    //val obj = EpicGNIP.getJsObject(t1)
    //val tweet = EpicGNIP.asGnipTweet(obj)
  }

  //Based on github.com/kenbod/scala_parse_json
  def get_tweets(string: String) = {
    val input  = Paths.get(string).toAbsolutePath.normalize
    val handle = io.Source.fromFile(input.toFile)
    val data   = handle.mkString
    handle.close // close input file
    data.split("\n")
  }

}
