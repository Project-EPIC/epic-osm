<<<<<<< HEAD
#./gradlew jar && \
#scala -classpath dependencies/*  build/libs/epic-spark.jar EpicDriver
#scala -classpath build/libs/epic-spark.jar EpicDriver

./gradlew jar && \
scala -classpath build/libs/epic-spark.jar EpicDriver
=======
./gradlew jar && scala -classpath build/libs/epic-spark.jar dependencies/spray-json_2.11-1.3.2.jar EpicDriver
>>>>>>> 9577702199ae603cba1b45dedaacc508bc75ea2f
