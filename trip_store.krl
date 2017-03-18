ruleset trip_store {

  global {

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
    select when explicit trip_processed
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    fired {
      trips.append({"mileage": mileage, "timestamp" :timestamp})
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trips
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    fired {
      long_trips.append({"mileage": mileage, "timestamp" :timestamp})
    }
  }
}
