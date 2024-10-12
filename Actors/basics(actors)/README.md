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

# How Actors Fit into Scala?

Actors fit naturally into Scala because of its functional programming paradigms (immutability, message-passing, etc.). You can think of actors as a way to model independent units of work that don’t share state directly but communicate via immutable messages.

## Basic Actor Concepts in Akka

### 1. ActorSystem:
- This is the environment or container that manages actors. It’s like the engine that runs all the actors.
- You create an **ActorSystem** first, and all actors are created inside this system.

### 2. Actor:
- This is the class that represents the actor. It contains the behavior of the actor (how it reacts to different messages).
- In Scala with Akka, you define your own actor by extending the **Actor** trait and implementing the **receive** method, which handles incoming messages.

### 3. Messages:
- These are the instructions actors send to one another. Messages can be any immutable object (commonly case classes or case objects in Scala).

### 4. ActorRef:
- When you create an actor, Akka gives you an **ActorRef**. This is a reference to the actor, and it’s the only way to interact with the actor. You send messages to this reference rather than directly invoking methods on the actor.

---

## Let’s Start Simple:

### 1. Defining an Actor:
Here’s how to define a simple actor in Akka:

```scala
import akka.actor.{Actor, ActorSystem, Props}

// Define the HelloWorldActor
class HelloWorldActor extends Actor {
  // The 'receive' method defines how this actor will respond to messages
  def receive = {
    case "hello" => println("Hello, world!")
    case _       => println("Unknown message")
  }
}
```

- **HelloWorldActor**: This is a class that extends **Actor**.
- **receive**: This is a special method where you define how the actor will react to messages. Here, the actor prints "Hello, world!" when it receives the message "hello". For any other message (case _), it prints "Unknown message."

### 2. Creating an Actor System and Actor Instance:
Now that we have the actor class, let’s create an instance of it using an **ActorSystem** and **Props**.

```scala
object Main extends App {
  // Create the ActorSystem
  val system = ActorSystem("HelloWorldSystem")
  
  // Create the HelloWorldActor using Props
  val helloWorldActor = system.actorOf(Props[HelloWorldActor], "helloWorldActor")
  
  // Send the "hello" message to the actor
  helloWorldActor ! "hello"  // This sends the "hello" message to the actor
  
  // Send another message
  helloWorldActor ! "goodbye"
  
  // Shutdown the ActorSystem
  system.terminate()
}
```

- **system.actorOf(Props[HelloWorldActor], "helloWorldActor")**: This creates an instance of the **HelloWorldActor**. Notice how we use **Props** to tell Akka to create the actor.
- **! (bang operator)**: This is how you send a message to an actor. In this case, we send "hello" and "goodbye" messages to the **helloWorldActor**.

### Breakdown:
- **helloWorldActor ! "hello"** sends the "hello" message.
- The **receive** method in **HelloWorldActor** receives this and matches "hello" in the case statement, printing "Hello, world!".
- The "goodbye" message doesn't match "hello", so it prints "Unknown message".


#1. What are Props?

In Akka, **Props** is a configuration class used to create actors. It defines how to create an instance of an actor. It's similar to saying, "Here's the blueprint or recipe to create this actor."

When we pass `Props[HelloWorldActor]`, we are telling Akka to create an actor of type **HelloWorldActor**. Thus, it acts as a factory for actor creation, managing how they are set up.

#2. Syntax Breakdown:
```scala
val system = ActorSystem("HelloWorldSystem")
```
`ActorSystem`:
This is like the container that manages actors. It sets up the environment (threads, memory, etc.) where the actors will live and interact.
-`"HelloWorldSystem"`:
The name given to the actor system (you can choose any name). It helps organize and identify your actor system.
```scala
val helloWorldActor = system.actorOf(Props[HelloWorldActor], "helloWorldActor")
```
`system.actorOf(...)`: This creates a new actor in the system. You’re asking the actor system to create an actor using a recipe (i.e., Props).

`Props[HelloWorldActor]`: This tells the actor system which class (in this case, HelloWorldActor) to instantiate. So, Akka creates a new instance of HelloWorldActor behind the scenes.

`"helloWorldActor"`: This is the name given to the actor, similar to a unique identifier. You can use this name to identify the actor in logs or for debugging purposes.
