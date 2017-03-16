ruleset echo {

  global {
    __testing = { "queries": [ { "name": "hello", "args": [ "obj" ] },
                             { "name": "__testing" } ],
                "events": [ { "domain": "echo", "type": "hello",
                              "attrs": [ "name" ] } ]
              }
  }


  rule hello {
    select when echo hello
    send_directive("say") with
      something = "Hello World"
  }

  rule message {
    select when echo message
    pre {
      input = event:attr("input")
    }
    send_directive("say") with
      something = input
  }
}
