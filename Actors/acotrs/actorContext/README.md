# ActorContext in Akka

**ActorContext** is a crucial component of Akka's actor model, providing a variety of functionalities that allow actors to interact with the Akka framework and manage their behavior. Below are the key aspects of `ActorContext`:

## 1. Definition and Purpose

* **ActorContext** is an implicit parameter available in the `receive` method of an actor. It gives actors access to the runtime context in which they operate.
* It allows actors to perform actions like sending messages, spawning new actors, stopping themselves or other actors, and more.

## 2. Key Features and Methods

* **Message Sending**: Actors can send messages to other actors using the `context` object. For example, `context.sender()` returns the reference of the actor that sent the current message.

```scala
context.sender() ! responseMessage
```

## 3. Creating child actors

* an actor can create child actors to handle specific tasks or encapsulate certain behaviors. This helps to structure your application better
### Child Actor Creation
 Suppose you have a ParentActor that manages multiple ChildActor instances:

```scala

class ParentActor extends Actor {
  override def receive: Receive = {
    case "createChild" =>
      val childActor = context.actorOf(Props[ChildActor], "childActor")
      childActor ! "start"
  }
}

class ChildActor extends Actor {
  override def receive: Receive = {
    case "start" =>
      // Child actor's behavior starts here
      println("Child actor started")
  }
}
```
In this example:

The `ParentActor` creates a `ChildActor` whenever it receives a `"createChild"` message.
The child actor then responds to the `"start"` message by executing its defined behavior.

### Global Actor Creation
When you create an actor at the system level, you typically use the ActorSystem reference like this:

```scala
val actorSystem = ActorSystem("MyActorSystem")
val globalActor = actorSystem.actorOf(Props[GlobalActor], "globalActor")
```
### Key Differences

#### Scope:

- **Global Actor**: Created within the context of the entire `ActorSystem`, which means it can be accessed globally within that system.
- **Child Actor**: Created within the context of a specific parent actor, which means it can interact directly with that parent actor.

#### Actor Hierarchy:

- **Global Actor**: Does not have a parent-child relationship with other actors unless explicitly set.
- **Child Actor**: Has the parent actor as its direct parent, allowing for built-in supervision and lifecycle management.

#### Fault Handling:

- **Global Actor**: Managed at the system level; failures are not automatically handled by a parent.
- **Child Actor**: Benefits from the supervision strategy of the parent actor, allowing for more robust fault tolerance.

Using `context.actorOf` in the parent actor helps you manage the lifecycle of the child actors effectively and maintain a clear actor hierarchy.

## 4. Stopping Actors  

### Code:  
\```scala  
context.stop(self) // Stop itself  
context.stop(childActor) // Stop a child actor  
\```  

### Purpose:  
These lines are used to stop the actor.  
- **`context.stop(self)`**: Stops the current actor (the one executing this code).  
- **`context.stop(childActor)`**: Stops the specified child actor. Once stopped, the actor will no longer process messages.  

## 5. Supervision  

### Code:  
\```scala  
context.watch(childActor) // Monitor the child actor  
\```  

### Purpose:  
This line enables the parent actor to monitor the lifecycle of the child actor.  
- **`context.watch`**: When you watch a child actor, the parent will receive a `Terminated` message when the child actor is stopped or crashes. This is useful for managing actor lifecycles and implementing fault tolerance strategies.  

## 6. Scheduling Messages  

### Code:  
\```scala  
import scala.concurrent.duration._  
context.system.scheduler.scheduleOnce(1.second) {  
  context.parent ! "Hello after delay"  
}(context.dispatcher) // Specify the execution context  
\```  

### Purpose:  
This allows you to send a message to the parent actor after a specified delay (1 second in this case).  

### Components:  
- **`context.system.scheduler`**: Accesses the scheduler of the actor system.  
- **`scheduleOnce`**: Schedules the execution of a block of code (sending a message in this case) after a delay.  
- **`context.dispatcher`**: Specifies the execution context for running this scheduled task, allowing it to execute in the right thread pool.  
