#./gradlew jar && \
#scala -classpath dependencies/*  build/libs/epic-spark.jar EpicDriver
#scala -classpath build/libs/epic-spark.jar EpicDriver

./gradlew jar && \
scala -classpath build/libs/epic-spark.jar EpicDriver