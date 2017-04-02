ruleset manage_fleet {

  meta {
    use module Subscriptions
    shares vehicles, get_all_vehicle_trips, last_five_reports, __testing
  }

  global {
    __testing = {
       "queries": [
           {"name":"get_all_vehicle_trips"},
           {"name":"vehicles"},
           {"name": "last_five_reports"}
       ],
       "events": [
           {
               "domain": "car",
               "type": "new_vehicle",
               "attrs": ["vehicle_id"]
           },
           {
               "domain": "car",
               "type": "unneeded_vehicle",
               "attrs": ["vehicle_id"]
           },
           {
                "domain": "car",
                "type": "start_report"
           },
           {
                "domain": "car",
                "type": "clear_reports"
           }
       ]
    }

    nameFromId = function(vehicle_id) {
      "Vehicle " + vehicle_id + " Pico"
    }

    vehicles = function() {
      ent:vehicles
    }

    childFromId = function(vehicle_id) {
      ent:vehicles{vehicle_id}
    }

    subscriptionFromId = function(vehicle_id) {
      "vehicle_" + vehicle_id
    }

    subscriptionName = function(vehicle_id) {
      "car:" + subscriptionFromId(vehicle_id)
    }

    urlForQuery = function(subscription) {
      "http://localhost:8080/sky/cloud/" + subscription{"attributes"}{"subscriber_eci"} + "/trip_store/trips"
    }

    get_all_vehicle_trips = function() {
      Subscriptions:getSubscriptions().filter(function(x) {x{"attributes"}{"subscriber_role"} == "vehicle"}).map(function(x) {
        result = http:get(urlForQuery(x));
        result{"content"}.decode()
      })
    }

    last_five_reports = function() {
      length = ent:reports.values().length();
      (length > 5) => ent:reports.values().slice(length - 5, length - 1) | ent:reports.values()
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
      eci = meta:eci
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
    event:send({ "eci": eci, "eid": "subscription",
      "domain": "wrangler", "type": "subscription",
      "attrs": { "name": subscriptionFromId(vehicle_id),
                 "name_space": "car",
                 "my_role": "fleet",
                 "subscriber_role": "vehicle",
                 "channel_type": "subscription",
                 "subscriber_eci": vehicle.eci} } )
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
      raise wrangler event "subscription_cancellation"
        with subscription_name = subscriptionName(vehicle_id);
      raise pico event "delete_child_request"
        attributes child_to_delete;
      ent:vehicles{[vehicle_id]} := null
    }
  }

  rule start_report {
    select when car start_report
    pre {
      rcn = time:now().replace(".", ":")
      eci = meta:eci
    }
    fired {
      raise explicit event "generate_report"
        attributes {"rcn": rcn, "eci": eci}
    }
  }

  rule generate_report {
    select when explicit generate_report
    foreach Subscriptions:getSubscriptions() setting (subscription)
      pre {
        eci = event:attr("eci")
        rcn = event:attr("rcn")
      }
      if subscription{"attributes"}{"subscriber_role"} == "vehicle" then
        event:send({ "eci": subscription{"attributes"}{"subscriber_eci"}, "eid": "generate_report", "domain": "car", "type": "generate_report", "attrs": {"rcn": rcn, "sender_eci": eci, "vehicle_id": subscription{"name"}}})
  }

  rule collect_report {
    select when car send_report
    pre {
      rcn = event:attr("rcn")
      vehicle_id = event:attr("vehicle_id")
      trips = event:attr("trips")
    }
    always {
      ent:reports := ent:reports.defaultsTo({});
      ent:reports{[rcn, "vehicles_responded"]} := ent:vehicles.length();
      ent:reports{[rcn, vehicle_id]} := trips
    }
  }

  rule clear_reports {
    select when car clear_reports
    always {
      ent:reports := {};
      ent:counter := 0
    }
  }
}
