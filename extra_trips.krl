ruleset extra_trips {

  global {
    long_trip = 1500
  }
  rule process_trip {
    select when car new_trip
    pre {
      mileage = event:attr("mileage")
    }
    send_directive("trip") with
      trip = mileage
    fired {
       raise explicit event "trip_processed"
         attributes {"trip": mileage}
     }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("trip")
    }
    if mileage.as("Number") < long_trip then
      noop()
    fired {
    } else {
      raise explicit event "found_long_trip"
        attributes{}
    }
  }
}
