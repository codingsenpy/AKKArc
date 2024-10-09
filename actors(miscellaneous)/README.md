### Best Practices for Actors

1. **Actors should work efficiently**:
   Like good co-workers, actors should do their tasks without unnecessarily bothering others or wasting resources. In programming, this means they should handle events and generate responses (or make requests) in an **event-driven** manner. Avoid **blocking** (i.e., passively waiting while occupying a thread) for external resources like locks, network sockets, etc., unless absolutely necessary. If blocking is unavoidable, there are other techniques to handle it.

2. **Use immutable messages**:
   **Do not pass mutable objects between actors**. Prefer using **immutable messages** to ensure that the actor's internal state isn’t exposed to others. If actors expose mutable state, it returns to the same problems as regular Java concurrency, which defeats the purpose of the actor model.

3. **Keep behavior within actors**:
   Actors are designed to manage **behavior** and **state**. Avoid sending behavior in messages, such as **Scala closures** (small functions). Doing so risks sharing mutable state between actors, which breaks the core principles of the actor model.

4. **Use a hierarchical system for top-level actors**:
   **Top-level actors** are critical for error handling (known as the **Error Kernel**), so they should be created sparingly. Prefer building a clear **actor hierarchy** to handle faults and manage performance. This also reduces the load on the **guardian actor**, which manages all top-level actors. Overusing top-level actors can make the guardian actor a bottleneck.
`____________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________`

Depending on the type of work being supervised and the nature of the failure, a supervisor has four options for handling failures:

1. **Resume** the subordinate, keeping its accumulated internal state.
2. **Restart** the subordinate, clearing out its accumulated internal state.
3. **Stop** the subordinate permanently.
4. **Escalate** the failure, causing the supervisor itself to fail.
`_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________`

### Actor Selection in Akka

* **Absolute Path Lookup**: You can look up an actor using the `actorSelection` method of the `ActorSystem` for absolute paths.
  
  * **Example**:
  
    ```scala
    system.actorSelection("/user/serviceA") ! msg
    ```

* **Relative Path Lookup**: Inside an actor, you can use `context.actorSelection` to look up actors relative to the current actor.
  
  * **Example**:
  
    ```scala
    context.actorSelection("../brother") ! msg
    ```

    This allows you to send messages to a specific sibling actor.

### Key Differences Between `actorSelection` and `context.actorSelection`:

1. **Starting Point**:
   * **`ActorSystem.actorSelection`**: Starts looking up from the root of the actor hierarchy.
   * **`context.actorSelection`**: Starts looking up from the current actor context.

2. **Path Elements**:
   * **`context.actorSelection`**: Can use relative paths (e.g., `..` to access parent actors).
   * **Absolute paths** may also be looked up on `context` in the usual way (e.g., `context.actorSelection("/user/serviceA") ! msg`).
