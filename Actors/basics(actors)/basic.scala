mport akka.actor.{Actor, ActorSystem, Props}

class HelloWorldActor extends Actor{
   def receive = {
     case "hello"=>println("helloworld")
     case _=>println("undefined")
   }
}

object Main extends App {
  val system=ActorSystem("HelloWorldSystem")
  val helloworldactr=system.actorOf(Props[HelloWorldActor],"helloworldactr")
  helloworldactr ! "hello"
}
