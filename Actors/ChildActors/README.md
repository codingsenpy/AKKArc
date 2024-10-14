# Child Actors in Akka

In Akka, actors form a hierarchy in which each actor has a parent. When an actor creates another actor, the newly created actor becomes a **child actor** of the parent actor. The parent actor, in turn, supervises the child actor and handles failures. This relationship is fundamental in Akka's supervision and fault tolerance model.

### Key Concepts

1. **Parent Actor**: The actor that creates and supervises its child actors.
2. **Child Actor**: An actor that is created by another actor (the parent) and is supervised by it.
3. **Actor Hierarchy**: Actors in Akka are organized hierarchically. The top-level actor in the system is called the `ActorSystem`, and it creates other actors under it.

### How Child Actors are Created

In Akka, you can create child actors by calling the `context.actorOf` method within an actor. The `context` provides a reference to the parent actor's context, which is used to spawn child actors.

#### Example of Creating Child Actors

``` scala
 import akka.actor.{Actor, Props}

 class ParentActor extends Actor {
   // Creating a child actor
   val childActor = context.actorOf(Props[ChildActor], "childActor")

   def receive = {
     case "createChild" =>
       // Create another child dynamically
       val anotherChild = context.actorOf(Props[ChildActor], "anotherChild")
       sender() ! "Child created"
   }
 }
 class ChildActor extends Actor {
   def receive = {
     case msg => println(s"Child actor received: $msg")
  }
 }
```
In this example:
- The `ParentActor` creates a child actor using `context.actorOf(Props[ChildActor], "childActor")`.
- The parent actor can also create more child actors dynamically when needed, as shown in the `"createChild"` case.

### Supervising Child Actors

One of the most important roles of parent actors is to supervise their children. If a child actor encounters an error or crashes, the parent can decide how to handle it. This is done via the **supervision strategy**.

- **Restart**: Restart the child actor when it fails.
- **Stop**: Stop the child actor entirely.
- **Resume**: Keep the actor running, ignoring the failure.
- **Escalate**: Send the failure to the parent of the current parent actor.

#### Example of Supervision

``` scala
 import akka.actor.{Actor, Props, OneForOneStrategy, SupervisorStrategy}
 import akka.actor.SupervisorStrategy._

 class ParentActor extends Actor {
   val childActor = context.actorOf(Props[ChildActor], "childActor")

  override val supervisorStrategy: SupervisorStrategy = 
     OneForOneStrategy() {
       case _: ArithmeticException => Resume
       case _: NullPointerException => Restart
       case _: Exception => Stop
     }

   def receive = {
     case msg => childActor ! msg
   }
 }

 class ChildActor extends Actor {
   def receive = {
     case _ => throw new NullPointerException("Test exception")
   }
 }
```
In this example:
- The `ParentActor` defines a `OneForOneStrategy` to handle child failures:
  - **Resume** the child if an `ArithmeticException` occurs.
  - **Restart** the child if a `NullPointerException` occurs.
  - **Stop** the child if a general `Exception` occurs.

### Benefits of Child Actors

1. **Isolation**: Each actor's state is isolated, so failures in one child actor do not affect others.
2. **Supervision**: Parents can automatically handle the failures of their child actors without requiring manual intervention.
3. **Scalability**: Child actors allow you to break down complex tasks into smaller parts, handled by different actors, promoting scalability and parallelism.

### Terminating Child Actors

To terminate a child actor, you can:
- Send the child actor a special `PoisonPill` message, or
- Use `context.stop(childActor)` from within the parent actor.

For example:

``` scala
 context.stop(childActor) // Terminates the child actor
```
The actor will stop processing messages and be removed from the actor system.

### Actor Lifecycle in the Context of Child Actors

When a parent actor stops, all its child actors are also stopped automatically. This ensures proper cleanup of resources. Child actors cannot outlive their parents in Akka.

---
 **DeathWatch**:
   - `context.watch(child)` allows a parent actor to monitor a child’s lifecycle. When the child actor terminates, the parent will receive a `Terminated` message.
