ruleset manage_fleet {

  global {
    nameFromID = function(vehicle_id) {
      "Vehicle " + vehicle_id + " Pico"
    }
  }

  rule create_vehicle {
    select when car new_vehicle
    pre {
      vehicle_id = event:attr("vehicle_id")
      exists = ent:vehicles >< vehicle_id
      eci = meta:eci
    }
    if exists then
      send_directive("vehicle_ready")
        with vehicle_id = vehicle_id
    fired {
    } else {
      ent:vehicle := ent:vehicle.union([vehicle_id]) || [];
      raise pico event "new_child_request"
        attributes { "dname": nameFromID(vehicle_id), "color": "#006400" }
    }
  }
}
