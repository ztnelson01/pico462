ruleset trip_store {

  meta {
    provides trips, long_trips, short_trips
    shares trips, long_trips, short_trips
  }

  global {

    tripsArr = []

    long_tripsArr = []

    trips = function() {
      tripsArr.klog("Trips being retrieved")
    }

    long_trips = function() {
      long_tripsArr.klog("Long trips being retrieved")
    }

    short_trips = function() {
      tripsArr.difference(long_tripsArr).klog("Short trips being retrieved")
    }

  }

  rule collect_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    fired {
      tripsArr.append({"mileage": mileage, "timestamp": timestamp}).klog("Added trip")
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
    }
    fired {
      long_tripsArr.append({"mileage": mileage, "timestamp": timestamp}).klog("Added long trip")
    }
  }
}
