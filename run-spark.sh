./gradlew clean && \
./gradlew shadowJar && \
/usr/local/Cellar/apache-spark/1.5.2/bin/spark-shell --jars build/libs/spark-tweets-all.jar