({
  setInitValues: function (component, event, helper, routeRecord) {
    if (routeRecord.RouteId) {
      component.set("v.routeId", routeRecord.RouteId);
    }
    var legs = [];
    if (routeRecord.Legs) {
      legs = routeRecord.Legs;
    }

    var startModes = "";
    var endModes = "";
    var startLocation = {};
    var betweenLocations = [];
    var endLocation = {};
    var newLegList = [];
    legs.map((leg) => {
      var start = {};
      start.locationName = leg.StartPosition.DisplayName;
      start.locationCode = leg.StartPosition.LocationCode.Code;
      start.subLocationName = leg.StartPosition.SublocationCodeDisplayName
        ? leg.StartPosition.SublocationCodeDisplayName
        : "";
      start.subLocationCode =
        leg.StartPosition.SubLocationCode &&
        leg.StartPosition.SubLocationCode.Code
          ? leg.StartPosition.SubLocationCode.Code
          : "";
      start.transMode = leg.TransportMode.Code;
      start.transModeCode = leg.TransportMode.Type;
      var end = {};
      end.locationName = leg.EndPosition.DisplayName;
      end.locationCode = leg.EndPosition.LocationCode.Code;
      end.subLocationName = leg.EndPosition.SublocationCodeDisplayName
        ? leg.EndPosition.SublocationCodeDisplayName
        : "";
      end.subLocationCode =
        leg.EndPosition.SubLocationCode && leg.EndPosition.SubLocationCode.Code
          ? leg.EndPosition.SubLocationCode.Code
          : "";
      end.transMode = leg.TransportMode.Code;
      end.transModeCode = leg.TransportMode.Type;
      newLegList.push(start);
      newLegList.push(end);
    });

    var finalLegs = [];
    var allLegs = [];
    newLegList.map((item) => {
      var flag = true;
      if (finalLegs.length == 0) {
        finalLegs.push(item);
        allLegs.push(item);
      } else {
        Object.entries(finalLegs[finalLegs.length - 1]).map((it) => {
          if (it[0] !== "transMode" && it[0] !== "transModeCode") {
            if (item[it[0]] == it[1]) {
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
    startLocation = this.processLeg(finalLegs[0], true, false);
    endLocation = this.processLeg(finalLegs[finalLegs.length - 1], false, true);
    if (finalLegs.length > 2) {
      finalLegs.splice(-1, 1);
      finalLegs.splice(0, 1);
      finalLegs.map((leg) => {
        betweenLocations.push(this.processLeg(leg, false, false));
      });
    }
    component.set("v.startLocation", startLocation);
    component.set("v.betweenLocations", betweenLocations);
    component.set("v.endLocation", endLocation);

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
      if (location.iconShown == "T") {
        isTruck = true;
      } else if (location.iconShown == "R") {
        isRail = true;
      }
      if (location.iconShown == "O" || location.iconShown == "F") {
        if (startModes == "") {
          startModes = this.checkMotorsOrRails(isTruck, isRail);
          isTruck = false;
          isRail = false;
        }
      }
    });
    index = 0;
    allLocations.map((location) => {
      index++;
      if (location.orgDest == "Port") {
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

    if (betPortFinal && betPortFinal.length > 0) {
      var originObject = component.get("v.originObject");
      var destinationObject = component.get("v.destinationObject");
      if (
        originObject &&
        originObject.type &&
        originObject.type.toUpperCase() === "DOOR"
      ) {
        var modes = "";
        if (startModes != "") {
          modes = startModes;
        }
        if (endModes != "" && modes == "") {
          modes = endModes;
        }
        startModes = modes;
      }
      if (
        destinationObject &&
        destinationObject.type &&
        destinationObject.type.toUpperCase() === "DOOR"
      ) {
        if (startModes != "" && endModes == "") {
          endModes = startModes;
        }
      }
    }
    component.set("v.betweenPortsOnly", betPortFinal);
    component.set("v.startModes", startModes);
    component.set("v.endModes", endModes);
  },

  checkMotorsOrRails: function (isTruck, isRail) {
    if (isTruck && isRail) {
      return "MOTOR / RAIL";
    } else if (isTruck) {
      return "ALL MOTOR";
    } else if (isRail) {
      return "RAIL";
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
    } else if (leg.transModeCode == "R") {
      item.orgDest = "Rail";
    } else if (leg.transModeCode == "O" || leg.transModeCode == "F") {
      item.orgDest = "Port";
      leg.transModeCode = "O";
    }
    item.displayName = leg.locationName;
    item.displayNameSubLoc = leg.subLocationName;
    item.displayCode = leg.locationCode;
    item.displayCodeSubLoc = leg.subLocationCode;
    item.iconShown = leg.transModeCode;
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
