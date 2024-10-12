### Using `actorSelection` for Message Routing

Using `actorSelection` in Akka allows an actor to locate and send messages to other actors based on their paths, rather than needing a direct reference to those actors. This is especially useful when:

- You don’t have the `ActorRef` of the actor you want to communicate with.
- You need to route messages dynamically within an actor hierarchy.

### How `actorSelection` Works
The `actorSelection` method allows you to specify an actor path, which could be a relative or absolute path. Once you get the selection, you can send messages to the selected actor(s), and Akka will attempt to resolve the path to the appropriate `ActorRef`.

### Example Usage
In this example, the actor sends a message to another actor without holding its `ActorRef`, but instead by using its logical path:

```scala
// Sending a message to a sibling actor using actorSelection
context.actorSelection("../someOtherActor") ! message
```

- `"../someOtherActor"` is a relative path that navigates up one level (`..`) in the hierarchy and looks for the sibling actor named `someOtherActor`.
- The `message` will be sent to that actor if it exists.

### Actor Path Types
1. **Relative Path**: As seen in the example above, `../someOtherActor` refers to a sibling actor by moving up one level from the current actor's path.
   
   Example:
   ```scala
   context.actorSelection("../siblingActor") ! "Hi!"
   ```

2. **Absolute Path**: You can also use the absolute path starting from the root of the `ActorSystem`. For example:
   
   ```scala
   val system = context.system
   system.actorSelection("/user/someActor") ! "Hello"
   ```

In this case, `"/user/someActor"` refers to an actor under the root `/user` guardian.

### When to Use `actorSelection`
- **When you don't have direct access**: If your actor does not have a direct reference to the target actor but knows its path.
- **Dynamic Routing**: When you want to route messages to actors dynamically based on their logical position in the actor hierarchy.

### Limitations
- **Asynchronous resolution**: `actorSelection` resolves to an `ActorRef` asynchronously, meaning the message might fail if the actor doesn’t exist or the path is invalid.
- **Less efficient**: Since `actorSelection` involves path resolution, it can be less efficient compared to holding direct references.

### Summary
In summary, `actorSelection` provides flexibility by allowing actors to communicate using logical paths rather than holding strict references. However, it should be used with awareness of its limitations, particularly in terms of resolution overhead and potential message delivery failures.
