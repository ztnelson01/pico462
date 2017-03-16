ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Hunter Rees"
    logging on
    shares hello
  }

  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }

  rule hello_world {
    select when echo hello
    send_directive("what-up") with
      something = "Hello World"
  }

}