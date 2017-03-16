ruleset track_trips {
  rule process_trip {
    select when echo message
    pre {
      mileage = event:attr("mileage")
    }
    send_directive("trip") with
      trip = mileage
  }
}
