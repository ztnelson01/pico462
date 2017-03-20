ruleset trip_store {

  meta {
    provides trips, long_trips, short_trips
    shares trips, long_trips, short_trips
  }

  global {

    trips = function() {
      ent:trips
    }

    long_trips = function() {
      ent:long_trips
    }

    short_trips = function() {
      ent:trips.difference(ent:long_trips)
    }

  }

  rule collect_trips {
    select when explicit trip_processed
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
      trip = {"mileage": mileage, "time": timestamp}
      all_trips = ent:trips.append(trip).klog("Adding trip")
    }
    always {
      ent:trips := all_trips
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre {
      mileage = event:attr("trip")
      timestamp = time:now()
      trip = {"mileage": mileage, "time": timestamp}
      all_long_trips = ent:long_trips.append(trip).klog("Adding trip")
    }
    always {
      ent:long_trips := all_long_trips
    }
  }

  rule clear_trips {
    select when car trip_reset
    always {
    }
  }
}
