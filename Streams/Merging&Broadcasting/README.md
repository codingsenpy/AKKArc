### Merging and Broadcasting in Akka Streams

Akka Streams provides powerful constructs to merge multiple streams into one or broadcast a single stream to multiple downstream processors. This is essential in scenarios where you want to combine data from different sources or split a single data stream into multiple consumers. Below are the key concepts:

---

### 1. **Merging Streams**

**Merging** in Akka Streams means combining multiple input streams into a single output stream. The merge operation can be useful when you have multiple sources of data that you want to process in the same pipeline.

#### **Types of Merge Operations**

1. **Merge**:
   - Merges multiple input streams into one. The output stream will emit elements as soon as they arrive from any of the input streams.
   - There is **no strict ordering** of the emitted elements between sources; whichever source provides the next element first, that element will be pushed downstream.

   **Syntax:**
   >>> scala
   val merged = Source.combine(source1, source2)(Merge(_))
   >>>

2. **MergePreferred**:
   - A variant of `Merge` that prioritizes one input stream over the other. When the preferred input has elements, they are emitted first, regardless of whether other sources have elements ready to be emitted.
   
   **Syntax:**
   >>> scala
   val mergePreferred = MergePreferred[Int](preferred = 1)
   >>>

3. **MergeSorted**:
   - Merges two **pre-sorted** streams into a single **sorted** stream. This is useful when you need to maintain the order of elements.

   **Syntax:**
   >>> scala
   val mergeSorted = MergeSorted[Int]()
   >>>

---

#### **Example of Merging Two Sources**

Here is a simple example that demonstrates merging of two streams:

``` scala
import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{Merge, Sink, Source}

implicit val system = ActorSystem("MergeExample")
implicit val materializer = ActorMaterializer()

val source1 = Source(1 to 5)
val source2 = Source(6 to 10)

// Correct the merge syntax to include the number of input ports
val mergedSource = Source.combine(source1, source2)(Merge(_))

// Run with Sink
mergedSource.runWith(Sink.foreach(println))

```

- **Explanation:**
  - `Source(1 to 5)` is the first source, producing numbers from 1 to 5.
  - `Source(6 to 10)` is the second source, producing numbers from 6 to 10.
  - `Merge` combines the two sources into a single stream.
  - The `Sink.foreach(println)` prints each element from the merged stream.
  - Output is not guaranteed to be ordered due to the nature of the merge.

---

#### **Example of MergePreferred**

The following example prioritizes one source over another when merging:

```scala
import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{MergePreferred, Sink, Source, GraphDSL, RunnableGraph, ClosedShape}

implicit val system = ActorSystem("MergePreferredExample")
implicit val materializer = ActorMaterializer()

val source1 = Source(1 to 5)
val source2 = Source(6 to 10)

val graph = RunnableGraph.fromGraph {
  GraphDSL.create() { implicit builder =>
    import GraphDSL.Implicits._

    // Define MergePreferred with one preferred input and one regular input
    val mergePreferred = builder.add(MergePreferred[Int](preferred = 0))

    source1 ~> mergePreferred.preferred
    source2 ~> mergePreferred.in(0)

    mergePreferred.out ~> Sink.foreach(println)

    ClosedShape
  }
}

// Run the graph
graph.run()

```

- **Explanation:**
  - `mergePreferred` gives preference to `source1`. As long as `source1` has elements, they will be emitted first.
  - Once `source1` is exhausted, `source2`’s elements will be emitted.

---

### 2. **Broadcasting Streams**

**Broadcasting** allows you to take a single input stream and distribute it to multiple downstream consumers. This is useful when you want to fan out data to multiple processing stages.

#### **Types of Broadcast Operations**

1. **Broadcast**:
   - Duplicates a stream to multiple sinks. Each downstream consumer gets all the elements emitted by the source. The flow proceeds only when all downstreams are ready to process the next element.

   **Syntax:**
   >>> scala
   val broadcast = Broadcast[Int](outputCount = 2)
   >>>

2. **Balance**:
   - Sends elements to downstreams in a **round-robin** fashion, distributing the load across multiple consumers. This is useful when you want to balance the processing load across parallel flows.

   **Syntax:**
   >>> scala
   val balance = Balance[Int](outputCount = 2)
   >>>

---

#### **Example of Broadcasting to Multiple Sinks**

Here’s a simple example that demonstrates broadcasting:

``` scala
import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{Broadcast, Sink, RunnableGraph, Source, GraphDSL, ClosedShape}

implicit val system = ActorSystem("BroadcastExample")
implicit val materializer = ActorMaterializer()

val source = Source(1 to 10)
val sink1 = Sink.foreach[Int](x => println(s"Sink1 received: $x"))
val sink2 = Sink.foreach[Int](x => println(s"Sink2 received: $x"))

val graph = RunnableGraph.fromGraph {
  GraphDSL.create() { implicit b =>
    import GraphDSL.Implicits._

    // Specify the output count for Broadcast
    val broadcast = b.add(Broadcast ) // Set outputCount to 2

    source ~> broadcast.in
    broadcast.out(0) ~> sink1
    broadcast.out(1) ~> sink2

    ClosedShape
  }
}

// Run the graph
graph.run()

```

- **Explanation:**
  - The `Broadcast` operator is used to send the elements from the `source` to both `sink1` and `sink2`.
  - Each sink receives the full range of elements from 1 to 10.

---

#### **Example of Balancing**

The following example uses `Balance` to distribute elements evenly between two sinks:

```scala
import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{Balance, Sink, RunnableGraph, Source, GraphDSL, ClosedShape}

implicit val system = ActorSystem("BalanceExample")
implicit val materializer = ActorMaterializer()

val source = Source(1 to 10)
val sink1 = Sink.foreach[Int](x => println(s"Sink1 received: $x"))
val sink2 = Sink.foreach[Int](x => println(s"Sink2 received: $x"))

val graph = RunnableGraph.fromGraph {
  GraphDSL.create() { implicit b =>
    import GraphDSL.Implicits._

    // Specify the output count for Balance
    val balance = b.add(Balance[Int](outputCount = 2))

    source ~> balance.in
    balance.out(0) ~> sink1
    balance.out(1) ~> sink2

    ClosedShape
  }
}

// Run the graph
graph.run()

```

- **Explanation:**
  - The `Balance` operator ensures that the elements from the `source` are distributed between `sink1` and `sink2` in a round-robin manner.
  - Each sink receives roughly half of the elements.

---

### Summary

- **Merging**: Combines multiple input streams into a single output stream. Variants include:
  - `Merge`: Combines streams without any specific order.
  - `MergePreferred`: Prioritizes one stream over others.
  - `MergeSorted`: Merges already sorted streams while maintaining order.
  
- **Broadcasting**: Distributes a single input stream to multiple downstream consumers.
  - `Broadcast`: Sends elements to all downstreams.
  - `Balance`: Distributes elements in a round-robin fashion to balance load.

These mechanisms help in designing systems where data flows need to be either combined or split efficiently, maintaining the resilience and scalability of Akka Streams.
