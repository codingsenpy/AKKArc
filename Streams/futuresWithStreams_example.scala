import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl._
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global

implicit val system = ActorSystem("FuturesInAkkaStreams")
implicit val materializer = ActorMaterializer()

// A func returning a future
def asyncComputation(num: Int): Future[Int] = Future {
  Thread.sleep(500) // Simulate async work
  num * 2
}

// Source producing integers 1 to 10
val source = Source(1 to 10)

// Using mapAsync to process each element with the future
val flow = source.mapAsync(parallelism = 4)(asyncComputation)

// Print each processed element
flow.runForeach(println)
