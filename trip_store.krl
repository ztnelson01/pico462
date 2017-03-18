ruleset trip_store {

  global {

    trips = function() {
      ent:trips.klog("Trips being retrieved")
    }

    long_trips = function() {
      ent:long_trips.klog("Long trips being retrieved")
    }

    short_trips = function() {
      ent:trips.difference(ent:long_trips).klog("Short trips being retrieved")
    }

  }

  rule collect_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    fired {
      trips.append({"mileage": mileage, "timestamp" :timestamp}).klog("Added trip")

    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    fired {
      long_trips.append({"mileage": mileage, "timestamp" :timestamp}).klog("Added long trip")
    }
  }
}
