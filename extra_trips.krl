ruleset extra_trips {
  rule process_trip {
    select when car new_trip
    pre {
      mileage = event:attr("mileage")
    }
    send_directive("trip") with
      trip = mileage
  }
}
