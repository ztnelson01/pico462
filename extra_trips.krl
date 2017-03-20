ruleset extra_trips {

  global {
    long_trip = 1500
  }

  rule process_trip {
    select when car new_trip
    pre {
      mileage = event:attr("mileage")
      timestamp = time:now()
    }
    send_directive("trip") with
      trip = mileage
    fired {
       raise explicit event "trip_processed"
         attributes {"mileage": mileage, "timestamp": timestamp}
     }
  }

  rule find_long_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("mileage")
      timestamp = event:attr("timestamp")
    }
    fired {
      raise explicit event "found_long_trip"
        attributes{"mileage": mileage, "timestamp": timestamp}
      if mileage.as("Number") >= long_trip
    }
  }
}
