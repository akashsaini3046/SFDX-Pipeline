({
  setValues: function (component, event, helper, scheduleRecord) {
    var segments = [];
    if (scheduleRecord.Segments) {
      segments = scheduleRecord.Segments;
      console.log(segments);
    }
    console.log("abcd");
    var startModes = "";
    var endModes = "";
    var startLocation = {};
    var betweenLocations = [];
    var endLocation = {};
    var newLegList = [];
    segments.map((segment) => {
      var start = {};
      var end = {};
      /* if(segment.FromSubDisplayName !== null)
        	     start.locationName = segment.FromSubDisplayName;
              else        
                 start.locationName = segment.Leg.StartPosition.DisplayName;   */
      start.locationName = segment.Legs.StartPosition.DisplayName;
      start.locationCode = segment.Legs.StartPosition.LocationCode.Code;
      start.subLocationName = segment.Legs.StartPosition
        .SublocationCodeDisplayName
        ? segment.Legs.StartPosition.SublocationCodeDisplayName
        : "";
      start.subLocationCode =
        segment.Legs.StartPosition.SubLocationCode &&
        segment.Legs.StartPosition.SubLocationCode.Code
          ? segment.Legs.StartPosition.SubLocationCode.Code
          : "";
      start.transMode = segment.Legs.TransportMode.Code;
      start.transModeCode = segment.Legs.TransportMode.Type;
      start.arrival = segment.arrivalToDisplay;
      if (segment.IsOcean === true) {
        start.vesselName = segment.VesselName + " " + segment.VesselCode.Code;
        start.voyageNumber = segment.VoyageNumber.NumberX;
        end.vesselName = segment.VesselName + " " + segment.VesselCode.Code;
        end.voyageNumber = segment.VoyageNumber.NumberX;

        start.departure = segment.FromX.Berths[0].Departure.LocalPortTime;
        end.arrival = segment.To.Berths[0].Arrival.LocalPortTime;
      } else {
        start.departure = segment.DepartureTime.LocalPortTime;
        end.arrival = segment.ArrivalTime.LocalPortTime;
      }
      /* if(segment.ToSubDisplayName !== null)
            	end.locationName = segment.ToSubDisplayName;
             else             
            	end.locationName = segment.Leg.EndPosition.DisplayName;*/
      end.locationName = segment.Legs.EndPosition.DisplayName;
      end.locationCode = segment.Legs.EndPosition.LocationCode.Code;
      end.departure = segment.departureToDisplay;
      end.subLocationName = segment.Legs.EndPosition.SublocationCodeDisplayName
        ? segment.Legs.EndPosition.SublocationCodeDisplayName
        : "";
      end.subLocationCode =
        segment.Legs.EndPosition.SubLocationCode &&
        segment.Legs.EndPosition.SubLocationCode.Code
          ? segment.Legs.EndPosition.SubLocationCode.Code
          : "";
      end.transMode = segment.Legs.TransportMode.Code;
      end.transModeCode = segment.Legs.TransportMode.Type;
      newLegList.push(start);
      newLegList.push(end);
    });
    console.log("newLegList");
    console.log(newLegList);
    var allLegs = [];
    var finalLegs = [];
    newLegList.map((item) => {
      var flag = true;
      if (finalLegs.length == 0) {
        finalLegs.push(item);
        allLegs.push(item);
      } else {
        Object.entries(finalLegs[finalLegs.length - 1]).map((it) => {
          if (
            it[0] !== "transMode" &&
            it[0] !== "transModeCode" &&
            it[0] !== "vesselName" &&
            it[0] !== "voyageNumber"
          ) {
            if (item[it[0]] === it[1]) {
              flag = flag && true;
            } else {
              flag = false;
            }
          }
        });
        if (!flag) {
          finalLegs.push(item);
          allLegs.push(item);
        }
      }
    });
    var len = parseInt(finalLegs.length) - 1;
    for (var i = 1; i < len; i++) {
      i = parseInt(i);
      if (
        finalLegs[i + 1].transModeCode === "O" ||
        finalLegs[i + 1].transModeCode === "F"
      ) {
        finalLegs[i].vesselName = finalLegs[i + 1].vesselName;
        finalLegs[i].voyageNumber = finalLegs[i + 1].voyageNumber;
      } else {
        finalLegs[i].vesselName = "";
        finalLegs[i].voyageNumber = "";
      }
    }
    startLocation = this.processLeg(finalLegs[0], true, false);
    endLocation = this.processLeg(finalLegs[finalLegs.length - 1], false, true);

    if (finalLegs.length > 2) {
      finalLegs.splice(-1, 1);
      finalLegs.splice(0, 1);
      finalLegs.map((leg) => {
        var loc = this.processLeg(leg, false, false);
        betweenLocations.push(loc);
      });
    }
    console.log("betweenLocations");
    console.log(betweenLocations);

    var allLocations = [];
    allLegs.map((leg) => {
      if (
        (leg.transModeCode == "O" || leg.transModeCode == "F") &&
        allLocations.length > 1
      ) {
        var temp = allLocations[allLocations.length - 1];
        temp.orgDest = "Port";
        allLocations.splice(-1, 1);
        allLocations.push(temp);
      }
      allLocations.push(this.processLeg(leg, false, false));
    });

    var betweenPortsOnly = [];
    var index = 0;
    var isTruck = false;
    var isRail = false;
    allLocations.map((location) => {
      index++;
      if (location.orgDest == "Truck") {
        isTruck = true;
      } else if (location.orgDest == "Rail") {
        isRail = true;
      }
      if (location.orgDest == "Port") {
        if (startModes == "") {
          startModes = this.checkMotorsOrRails(isTruck, isRail);
          isTruck = false;
          isRail = false;
        }
        if (index != 1 && index != allLocations.length) {
          betweenPortsOnly.push(location);
        }
      }
    });
    if (startModes !== "") {
      endModes = this.checkMotorsOrRails(isTruck, isRail);
    } else {
      startModes = this.checkMotorsOrRails(isTruck, isRail);
    }

    var betPortFinal = [];
    if (betweenPortsOnly && betweenPortsOnly.length > 0) {
      if (startLocation.orgDest !== "Port") {
        betPortFinal.push(betweenPortsOnly[0]);
        betweenPortsOnly.splice(0, 1);
      }
      if (
        endLocation.orgDest !== "Port" &&
        betweenPortsOnly &&
        betweenPortsOnly.length > 0
      ) {
        betPortFinal.push(betweenPortsOnly[betweenPortsOnly.length - 1]);
      }
    }

    scheduleRecord.betweenLocations = betweenLocations;
    scheduleRecord.betweenPortsOnly = betPortFinal;
    scheduleRecord.originMove = component.get("v.originMove");
    scheduleRecord.destMove = component.get("v.destinationMove");
    scheduleRecord.startMode = startModes;
    scheduleRecord.endMode = endModes;
    scheduleRecord.startLoc = startLocation;
    scheduleRecord.endLoc = endLocation;
    scheduleRecord.startPoint = component.get("v.startPoint");
    scheduleRecord.endPoint = component.get("v.endPoint");
    component.set("v.schedule", scheduleRecord);
    component.set("v.startModes", startModes);
    component.set("v.endModes", endModes);
    component.set("v.startLocation", startLocation);
    component.set("v.betweenLocations", betweenLocations);
    component.set("v.betweenPortsOnly", betPortFinal);
    component.set("v.endLocation", endLocation);
  },

  checkMotorsOrRails: function (isTruck, isRail) {
    if (isTruck && isRail) {
      return "MOTOR / RAIL";
    } else if (isTruck) {
      return "ALL MOTOR";
    }
  },
  processLeg: function (leg, isStart, isEnd) {
    var item = {};
    if (leg.transModeCode == "T") {
      if (isStart || isEnd) {
        item.orgDest = "Door";
      } else {
        item.orgDest = "Truck";
      }
    }
    if (leg.transModeCode == "R") {
      if (isStart || isEnd) {
        item.orgDest = "Door";
      } else {
        item.orgDest = "Rail";
      }
    }
    if (leg.transModeCode == "O" || leg.transModeCode == "F") {
      item.orgDest = "Port";
    }
    item.displayName = leg.locationName;
    item.displayNameSubLoc = leg.subLocationName;
    item.displayCode = leg.locationCode;
    item.displayCodeSubLoc = leg.subLocationCode;
    item.iconShown = leg.transModeCode;
    item.arrival = leg.arrival;
    item.departure = leg.departure;
    item.vesselName = leg.vesselName;
    item.voyageNumber = leg.voyageNumber;

    return item;
  },
  sortData: function (fieldname, direction, parsedJson) {
    var parseData = parsedJson;
    var isReverse = direction === "asc" ? 1 : -1;
    parseData.sort((x, y) => {
      x = x[fieldname] ? x[fieldname] : "";
      y = y[fieldname] ? y[fieldname] : "";
      return isReverse * ((x > y) - (y > x));
    });
    return parseData;
  }
});
