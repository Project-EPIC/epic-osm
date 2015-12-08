gradle clean
gradle jar && \
scala -cp "dependencies/spray-json.jar:build/libs/spark-tweets.jar" edu.colorado.cs.epic.SparkTweets

