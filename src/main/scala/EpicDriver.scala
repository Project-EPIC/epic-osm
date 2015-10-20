
//Import the two objects
import EpicOSM._
import EpicTwitter._

import java.nio.file.{Files,Path,Paths}
import java.io.{File,PrintWriter}


object EpicDriver {

  def main(args: Array[String]) {

    println("Hello World")

    //Lets import some tweets
    val tweet_file = Paths.get("test/sandy_tweets.json").toAbsolutePath.normalize
    val tweets = get_tweets(tweet_file)

   	val tweet_objs = tweets.map{t => EpicTwitter.parseJsonToTweet(t)}

   	tweet_objs.take(10).foreach(println)

  }

  //Based on github.com/kenbod/scala_parse_json

  private def get_tweets(input: Path) = {
    val handle = io.Source.fromFile(input.toFile)
    val data   = handle.mkString
    handle.close // close input file
    data.split("\n")
  }

}
