# What are Actors?

An **actor** is the fundamental unit of computation in the Akka framework. It's different from regular objects in Scala or other programming languages. Actors are designed for concurrent and distributed systems, where multiple tasks can happen simultaneously without running into thread-safety issues.

Here are some key characteristics of actors:

1. **Encapsulation of State**:  
   - Each actor has its own state, and only that actor can modify its state. This means there's no shared mutable state between actors, which helps avoid concurrency issues like race conditions.

2. **Communication via Messages**:  
   - Actors communicate asynchronously by passing messages to one another. When you want one actor to do something, you send it a message instead of calling a method directly. Messages are processed one at a time, ensuring that the state remains consistent.

3. **Concurrency**:  
   - Unlike regular objects, where you might use synchronized blocks or locks to handle concurrency, actors handle their own concurrency internally. Each actor processes only one message at a time in a sequential manner. Akka's ActorSystem ensures this.

4. **Isolation**:  
   - Each actor is independent, meaning even if one actor crashes or fails, others are unaffected unless they're explicitly linked.
