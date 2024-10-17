### Building Custom Graphs in Akka Streams with GraphDSL

In Akka Streams, when you need to build more complex data flows than the linear ones (source → flow → sink), you can use the **GraphDSL**. The GraphDSL allows you to create custom stream topologies, meaning you can introduce things like merging multiple sources, broadcasting data to multiple sinks, and more advanced flow control.

---

### Key Components

#### 1. **GraphDSL.create()**

This is where we define a custom graph. The `create()` method takes a block where the components of the graph are defined and connected.

- **Usage**: Inside the block, we define and wire up the sources, sinks, and flows.
- **GraphBuilder**: The block receives an implicit **builder**, which provides methods to add elements (sources, flows, sinks) and wire them together.

```scala
GraphDSL.create() { implicit builder =>
  // Define graph components here
}
```

---

#### 2. **GraphBuilder**

The **builder** is responsible for managing the layout of the graph. It ensures that the connections between different elements (like sources, flows, and sinks) are correctly handled.

- **Purpose**: The builder is implicitly passed into the block within `GraphDSL.create()`. You will use it to declare and connect the stages of the graph.

The **builder** works closely with components like flows and sinks. You use it to define the edges and connect them, ensuring that data can flow between different components.

---

#### 3. **GraphDSL.Implicits._**

This is an important import that you need to make when working with GraphDSL. It brings in some helpful implicit methods that simplify the process of connecting graph components.

```scala
import GraphDSL.Implicits._
```

- This import allows us to use operators like **~>** (connects stages) in the graph. Without it, you'd have to manually write out more verbose code for every connection.

---

#### 4. **ClosedShape**

When building a graph, you must define the overall shape of the graph. A **ClosedShape** represents a complete, executable graph. This means the graph has no unconnected inputs or outputs—everything is wired up.

- **ClosedShape**: Indicates that all the inputs and outputs are connected, and the graph is ready to run.

```scala
RunnableGraph.fromGraph(GraphDSL.create() { implicit builder =>
  // Define components here
  ClosedShape
})
```
---

#### 5. **RunnableGraph.fromGraph()**

This is used to turn a graph into a **RunnableGraph**. A **RunnableGraph** is a complete stream that can be run by invoking `.run()` on it.

- **RunnableGraph**: Takes the graph that you defined with GraphDSL and converts it into something you can execute.

```scala
val runnableGraph = RunnableGraph.fromGraph(graph)
```

---

### Example: Merging Two Sources and Sending to a Sink

Let’s look at an example where we merge two sources and send the combined data to a sink. This example uses all of the components discussed above.

```scala
import akka.actor.ActorSystem
import akka.stream.scaladsl._
import akka.stream._
import akka.{ Done, NotUsed }

import scala.concurrent.Future

implicit val system = ActorSystem("GraphDSLExample")
implicit val materializer = Materializer(system)

// Define two sources
val source1 = Source(1 to 5)
val source2 = Source(6 to 10)

// Define a sink
val sink = Sink.foreach[Int](println)

// Create the graph
val graph = RunnableGraph.fromGraph(GraphDSL.create() { implicit builder =>

  // Import the implicit helpers to connect stages
  import GraphDSL.Implicits._

  // Define a merge junction (it will merge two inputs into one output)
  val merge = builder.add(Merge )

  // Connect the sources to the merge junction
  source1 ~> merge.in(0)
  source2 ~> merge.in(1)

  // Connect the merge output to the sink
  merge.out ~> sink

  ClosedShape
})

// Run the graph
graph.run()
```
---

### Explanation

1. **Sources**: We define two sources: `source1` and `source2`, which generate sequences of numbers (1-5 and 6-10, respectively).

2. **Sink**: We define a sink that simply prints each number it receives.

3. **Merge Junction**: The `Merge` junction takes two inputs (our two sources) and merges them into a single stream. This is done by the `builder.add(Merge )` call.

4. **Connecting Sources to Merge**: The `~>` operator is used to connect the two sources to the merge junction.

5. **Connecting Merge to Sink**: Finally, the merged output is connected to the sink, completing the stream.

6. **ClosedShape**: The graph is fully connected, so we use `ClosedShape` to indicate the graph is complete and can be run.

7. **RunnableGraph**: We create a `RunnableGraph` from the graph definition and run it with `graph.run()`.

---

### Summary

Akka Streams provides powerful tools for building complex stream topologies with GraphDSL. Using components like `Merge` and `Broadcast`, you can build non-linear stream structures. Understanding how to use the `builder`, connect stages, and use operators like `~>` will enable you to design sophisticated processing pipelines in Akka Streams.
