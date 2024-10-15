### What are Materialized Values?

In Akka Streams, when we define a **stream**, we don’t immediately run it. Instead, we define the blueprint of the stream—what data will flow, how it will flow, and where it will go. **Materialization** is the process of taking this stream blueprint and turning it into something that can execute. This process produces a **Materialized Value**, which can be useful for interacting with the stream while it's running or knowing when it has finished.

A **materialized value** is like a side product of the stream's execution, and it can represent:
- A control object (such as an `ActorRef`).
- A `Future` that completes when the stream finishes.
- Any value that allows you to interact with or track the progress of the stream.

---

### What Does "Keeping Materialized Value" Mean?

Each part of the stream (source, flow, or sink) can potentially produce its own materialized value. For example:
- A **source** could produce a value that allows you to control the stream.
- A **sink** might return a `Future` that tells you when the stream is finished.

When you connect a source, flow, and sink to build a complete stream, you don’t always want all of these materialized values—you might only care about the value from one part. **Keeping the materialized value** means deciding which part’s materialized value you want to retain.

For example, let’s say both the source and sink produce values. You can choose to:
- Keep the source's value.
- Keep the sink's value.
- Or keep both.

Akka Streams provides methods like **`Keep.left`**, **`Keep.right`**, and **`Keep.both`** to control which materialized values you want to keep.

---

### Example: Basic Stream with Materialized Value

Let's walk through a concrete example where we build a simple stream and control which materialized value we keep.

``` scala
val source = Source(1 to 10)   // A source of numbers from 1 to 10
val sink = Sink.foreach[Int](println)   // A sink that prints each number
```

In this stream:
- The `source` doesn’t produce a materialized value that we care about—it just emits numbers.
- The `sink`, however, produces a **Future[Done]** that completes when all numbers are printed (i.e., when the stream finishes).

Now, let’s connect the source and sink into a complete stream:

``` scala
val graph = source.toMat(sink)(Keep.right)   // Keep the sink’s materialized value
val materializedValue = graph.run()   // Start the stream and get the materialized value
```

- `source.toMat(sink)(Keep.right)` connects the source and sink. The `Keep.right` means "keep the sink’s materialized value."
- The materialized value in this case is a **Future[Done]**.
- When the stream finishes processing, the `Future` completes.

---

### Keep.left, Keep.right, Keep.both

- **Keep.left**: Keep the materialized value from the **left-hand side** of the stream (usually the source).
- **Keep.right**: Keep the materialized value from the **right-hand side** (usually the sink).
- **Keep.both**: Keep both the left and right materialized values.

Let’s see what happens if we use `Keep.both`:

``` scala
val graph = source.toMat(sink)(Keep.both)   // Keep both the source and sink values
val (sourceValue, sinkValue) = graph.run()  // Run the stream and get both materialized values
```

Now:
- `sourceValue`: This would be the value from the source (if it produced one).
- `sinkValue`: This is the `Future[Done]` from the sink that completes when the stream finishes.

---

### General Syntax Example

Here’s a general syntax structure you might follow:

``` scala
val sourceName = Source(startingNumber to endingNumber)   // A source emitting numbers
val flowName = Flow[Int].map(someTransformation)   // A flow transforming data
val sinkName = Sink.foreach[Int](someSideEffect)   // A sink processing data
val graph = sourceName.via(flowName).toMat(sinkName)(Keep.right)   // Combine them
val materializedValue = graph.run()   // Run the stream and get materialized value
```

- **Source**: Emits elements.
- **Flow**: Processes elements in the middle (optional).
- **Sink**: Receives and processes the final elements.
- **Materialized Value**: The result you get after running the stream (such as a `Future` or an `ActorRef`).

---

### To Sum Up

1. **Materialized Value**: A value returned when you *run* the stream. It helps you control or monitor the stream while it's running or after it completes.
2. **Keeping Materialized Values**: You choose which part of the stream’s materialized value to keep using `Keep.left`, `Keep.right`, or `Keep.both`.
3. **Materialization**: This is the point at which the stream is actually run, and the materialized value is produced.

This concept allows you to control the stream or know when it’s finished in a more flexible way, depending on what part of the stream you care about.
