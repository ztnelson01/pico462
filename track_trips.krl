ruleset track_trips {
  rule process_trip {
    pre {
      mileage = event:attr("mileage")
    }
    select when echo message
    send_directive("trip") with
      trip = mileage
  }
}
