Epic + Scala + Spark + Uber Jars
================================

The purpose of this repository is a collection of re-usable modules that handle all dependencies for:

1. Spark
1. Tweet Objects

These will be built to uberJars with Gradle & ShadowJar and then the uber jar may be included when submitting the project to spark.

##Building
	
	./gradlew shadowJar

##Running Locally
You can run this repository locally with the following script. 

	./run-local.sh

This will launch a scala REPL with the UberJar in the classpath, where you can import the library and use it, like so:

	scala> import edu.colorado.cs.epic.SparkTweets;
	scala> SparkTweets.main(Array(""))

##Running Tests

	TODO

##Dependencies