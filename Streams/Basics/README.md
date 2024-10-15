## Akka Streams: Introduction

**Akka Streams** is a module designed for handling large streams of data in a **non-blocking**, **asynchronous** way. It simplifies working with continuous data streams using a **pipeline** approach while being built on top of Akka's actor model. Streams help process data efficiently by managing backpressure and processing data in chunks.

---

### Key Concepts in Akka Streams

#### 1. **Source**

A **Source** is the starting point of a stream, where data is emitted from. It can generate or pull data from a given source, and passes this data downstream to other components like **Flows** or **Sinks**.

- **General Syntax**:
  ```scala
  val sourceName = Source(startingNumber to endingNumber)
  ```

- **Specific Example**:
 ```scala
  val source = Source(1 to 10)  // A source emitting numbers 1 to 10
  ```

#### 2. **Flow**

A **Flow** represents a processing stage in the stream that takes input, applies some transformation, and outputs the processed data.

- **General Syntax**:
  ```scala
  val flowName = Flow[Int].map(element => transformation)
  ```

- **Specific Example**:
```scala
  val flow = Flow[Int].map(x => x * 2)  // Multiply each element by 2
  ```

#### 3. **Sink**

A **Sink** is the end of the stream, where data is finally collected or consumed. It can write the processed data to a file, database, or simply print it.

- **General Syntax**:
  ```scala
  val sinkName = Sink.foreach(element => action)
  ```

- **Specific Example**:
  ```scala
  val sink = Sink.foreach[Int](println)  // Print each element to the console
  ```

---

### Putting It Together

To create a full stream, you need to connect a `Source`, a `Flow`, and a `Sink`. 

- **Example of a Complete Stream**:
  ```scala 
  val runnableGraph = source.via(flow).to(sink)
  runnableGraph.run()
  ```

This example takes a `Source` that emits numbers from 1 to 10, applies a `Flow` that multiplies each number by 2, and sends the results to a `Sink` that prints each value.

---

### Example: Simple Akka Stream
Here’s a simple example that generates numbers from a source, doubles them through a flow, and prints the results via a sink:

```scala

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{Source, Flow, Sink}

implicit val system = ActorSystem("AkkaStreamsExample")
implicit val materializer = ActorMaterializer()

// Define source, flow, and sink
val source = Source(1 to 10)  // Source: emits numbers 1 to 10
val flow = Flow[Int].map(_ * 2)  // Flow: doubles each number
val sink = Sink.foreach[Int](println)  // Sink: prints each element

// Combine source, flow, and sink into a graph
val runnableGraph = source.via(flow).to(sink)

// Materialize the stream (run it)
runnableGraph.run()
```
