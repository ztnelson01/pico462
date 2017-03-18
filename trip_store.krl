ruleset trip_store {

  global {

    long_trip = 1500

    trips = function() {
      ent:trips
    }

    long_trips = function() {
      ent:long_trips
    }

    short_trips = function() {
      ent.trips.difference(ent:long_trips)
    }

  }

  rule collect_trips {
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    select when explicit trip_processed
      ent:trips.append({mileage, timestamp})
  }

  rule collect_long_trips {
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    select when explicit found_long_trips
      ent:long_trips.append({mileage, timestamp})
  }

  rule clear_trips {
    select when car trip_reset
      ent:trips := []
      ent:long_trips := []
      ent:short_trips := []
  }
}
