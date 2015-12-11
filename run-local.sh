./gradlew clean && \
./gradlew shadowJar && \
scala -classpath build/libs/spark-tweets-all.jar