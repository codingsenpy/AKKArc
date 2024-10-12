# What is Props?
In Akka, `Props` is a configuration class used to specify how actors are created. It encapsulates the instructions for actor instantiation and configuration, making it possible to define actor behavior, constructor parameters, dispatcher, and router settings.

`Props` is the main way to create new actor instances. It can be considered a "blueprint" or "factory" that the `ActorSystem` uses to create actors.

---

## Key Features of Props

1. **Actor Instantiation**:  
   `Props` allows the `ActorSystem` to know how to create instances of your actor. It handles the instantiation of the actor class.

2. **Configuration**:  
   You can configure `Props` to specify which dispatcher the actor should run on or how to configure routers for actor distribution.

3. **Immutability**:  
   `Props` are immutable, meaning once a `Props` object is created, it cannot be modified. This ensures thread-safety in Akka’s concurrent environment.

4. **Constructor Arguments**:  
   `Props` can be used to pass constructor arguments to actors. This is especially important for actors that need to be initialized with certain values.

---

## Basic Syntax of Props
Here’s how to define and use `Props` to create an actor:

```scala
// Define an actor class
class MyActor extends Actor {
  def receive = {
    case msg => println(s"Received message: $msg")
  }
}

// Create an ActorSystem
val system = ActorSystem("MyActorSystem")

// Create a Props object for MyActor
val props = Props[MyActor]

// Use the ActorSystem to create an instance of the actor
val myActorRef = system.actorOf(props, "myActor")
```

In this example:
- `Props[MyActor]` tells Akka to use `MyActor` as the actor's class.
- `system.actorOf(props, "myActor")` creates an instance of the actor in the `ActorSystem`, using the specified `Props`.

---

## Passing Parameters to Actors Using Props
When your actor requires parameters, you can use `Props` to pass them:

```scala
class MyActor(param1: String, param2: Int) extends Actor {
  def receive = {
    case msg => println(s"Actor initialized with: $param1 and $param2")
  }
}

// Use Props to pass parameters to the actor
val props = Props(classOf[MyActor], "Akka", 42)
val myActorRef = system.actorOf(props, "myActor")
```

Here, the constructor parameters `"Akka"` and `42` are passed to the actor when it is created.

---

## Props with Factory Methods
Sometimes you might want more control over how an actor is created, or you want to avoid reflection when using `Props`. In this case, you can use factory methods:

```scala
class MyActor(param1: String, param2: Int) extends Actor {
  def receive = {
    case msg => println(s"Actor initialized with: $param1 and $param2")
  }
}

object MyActor {
  def props(param1: String, param2: Int): Props = Props(new MyActor(param1, param2))
}

// Use the factory method to create Props
val myActorRef = system.actorOf(MyActor.props("Akka", 42), "myActor")
```

In this example, the `props` method acts as a factory for creating `Props` objects. This is preferred when you want to avoid using the `classOf` approach.

---

## Advanced Usage of Props
You can also configure `Props` with more advanced options, such as specifying the dispatcher or configuring a router:

1. **Specifying the Dispatcher**:  
   A dispatcher controls how messages are processed by actors. You can configure `Props` to use a specific dispatcher for an actor.

   ```scala
   val props = Props[MyActor].withDispatcher("my-dispatcher")
   val myActorRef = system.actorOf(props, "myActor")
   ```

2. **Configuring Routers**:  
   Routers are used to distribute messages across multiple actors. You can configure a router within `Props`.

   ```scala
   import akka.routing.FromConfig
   val props = Props[MyActor].withRouter(FromConfig())
   val myActorRef = system.actorOf(props, "myRouter")
   ```
