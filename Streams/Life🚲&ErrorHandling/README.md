## Stream Lifecycle and Error Handling

In Akka Streams, the lifecycle of a stream can be divided into three main phases:

### 1. Stream Definition
- A stream starts as a **blueprint**, which defines the source, flow, and sink.
- At this stage, the stream is not running yet; it's just a description of how data will flow.

Example:

``` scala
val source = Source(1 to 100)
val sink = Sink.foreach[Int](println)
val flow = Flow[Int].map(_ * 2)
```
Here, we've defined a simple stream that multiplies numbers from 1 to 100 by 2 and prints them out.

### 2. Materialization
- When you connect the source, flow, and sink and call `.run()`, the stream is **materialized**. This is when it starts processing data.
- Materialization returns a **materialized value**, which could be a `Future`, `ActorRef`, or other control structures.

Example:

>>> scala
val graph = source.via(flow).to(sink)
val materializedValue = graph.run()

This creates a runnable stream that processes numbers through the flow and sends the results to the sink.

### 3. Completion
- Once the stream finishes processing all elements, it completes.
- A stream can complete **successfully** or with **failure**.
- The sink usually determines when the stream finishes.

Example:

``` scala
val sink = Sink.foreach[Int](println)
val result: Future[Done] = source.via(flow).runWith(sink)

result.onComplete {
  case Success(_) => println("Stream completed successfully.")
  case Failure(e) => println(s"Stream failed with $e")
}
```
---

## Error Handling in Akka Streams

Failures can happen during stream processing (e.g., database errors, network timeouts). Akka Streams provide multiple ways to handle errors gracefully.

### 1. `recover`
- The `recover` stage allows you to handle errors by replacing the failed elements with alternative values.
- It intercepts the failure and continues the stream with fallback values.

Example:

```scala
val faultyFlow = Flow[Int].map { n =>
  if (n == 5) throw new RuntimeException("Boom!")
  else n * 2
}

val recoveredFlow = faultyFlow.recover {
  case _: RuntimeException => -1 // Fallback value in case of failure
}

source.via(recoveredFlow).runWith(sink)
```
In this example, if the number `5` is encountered, the stream throws an exception. The `recover` step catches the exception and replaces the failed element with `-1`.

### 2. `recoverWithRetries`
- This is similar to `recover`, but it allows retrying the stream a fixed number of times before failing permanently.

Example:

``` scala
val flowWithRetries = faultyFlow.recoverWithRetries(attempts = 3, {
  case _: RuntimeException => Source.single(-1)
})

source.via(flowWithRetries).runWith(sink)
```
This will retry up to 3 times when a `RuntimeException` occurs. After the retries are exhausted, the stream will output `-1`.

### 3. Supervision Strategy
- A **supervision strategy** lets you specify how the stream should handle failures: whether to stop, restart, or resume processing.
- You can define a strategy using `ActorAttributes`.

Example:

``` scala
val decider: Supervision.Decider = {
  case _: ArithmeticException => Supervision.Resume // Skip the faulty element
  case _                      => Supervision.Stop  // Stop the stream on other errors
}

val supervisedFlow = faultyFlow.withAttributes(ActorAttributes.supervisionStrategy(decider))

source.via(supervisedFlow).runWith(sink)
```
Here, the stream will **resume** if it encounters an `ArithmeticException`, but will **stop** on any other error.

### 4. `RestartSource`, `RestartSink`, and `RestartFlow`
- Akka Streams provide special **restartable** sources, sinks, and flows that automatically restart on failures.

Example:

```scala
val restartableSource = RestartSource.onFailuresWithBackoff(
  minBackoff = 1.second,
  maxBackoff = 30.seconds,
  randomFactor = 0.2
)(() => Source(1 to 100))

restartableSource.runWith(sink)
```
If the stream fails, it will automatically restart after an increasing backoff time (starting from 1 second up to 30 seconds).

---

### Example: Complete Error Handling Stream

Here’s a complete example that ties together these concepts:

```scala
val source = Source(1 to 100)
val faultyFlow = Flow[Int].map { n =>
  if (n == 5) throw new RuntimeException("Boom!")
  else n * 2
}

val decider: Supervision.Decider = {
  case _: RuntimeException => Supervision.Resume // Skip over faulty elements
  case _                   => Supervision.Stop  // Stop on other failures
}

val supervisedFlow = faultyFlow.withAttributes(ActorAttributes.supervisionStrategy(decider))

val sink = Sink.foreach[Int](println)

source.via(supervisedFlow).runWith(sink).onComplete {
  case Success(_) => println("Stream completed.")
  case Failure(e) => println(s"Stream failed with: $e")
}
```
