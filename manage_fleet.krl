ruleset manage_fleet {

  meta {
    shares vehicles
  }

  global {
    nameFromId = function(vehicle_id) {
      "Vehicle " + vehicle_id + " Pico"
    }

    vehicles = function() {
      ent:vehicles
    }

    childFromId = function(vehicle_id) {
      ent:vehicles{vehicle_id}
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
      raise pico event "new_child_request"
        attributes { "dname": nameFromId(vehicle_id),
                     "color": "#006400",
                     "vehicle_id": vehicle_id }
    }
  }

  rule pico_child_initialized {
    select when pico child_initialized
    pre {
      vehicle = event:attr("new_child")
      vehicle_id = event:attr("rs_attrs"){"vehicle_id"}
    }
    event:send({ "eci": vehicle.eci, "eid": "install-ruleset",
     "domain": "pico", "type": "new_ruleset",
     "attrs": { "rid": "Subscriptions", "vehicle_id": vehicle_id } } )
    event:send({ "eci": vehicle.eci, "eid": "install-ruleset",
      "domain": "pico", "type": "new_ruleset",
      "attrs": { "rid": "extra_trips", "vehicle_id": vehicle_id } } )
    event:send({ "eci": vehicle.eci, "eid": "install-ruleset",
      "domain": "pico", "type": "new_ruleset",
      "attrs": { "rid": "trip_store", "vehicle_id": vehicle_id } } )
    fired {
      ent:vehicles := ent:vehicles.defaultsTo({});
      ent:vehicles{vehicle_id} := vehicle
    }
  }

  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
      vehicle_id = event:attr("vehicle_id")
      exists = ent:vehicles >< vehicle_id
      eci = meta:eci
      child_to_delete = childFromId(vehicle_id)
    }
    if exists then
      send_directive("vehicle removed")
        with vehicle_id = vehicle_id
    fired {
      raise pico event "delete_child_request"
        attributes child_to_delete;
      ent:vehicles{[vehicle_id]} := null
    }
  }
}
