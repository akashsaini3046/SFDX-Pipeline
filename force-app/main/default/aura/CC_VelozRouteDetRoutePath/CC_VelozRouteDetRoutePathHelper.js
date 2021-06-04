({
  setValues: function (component, event, helper, routeRecord) {
    var legs = [];
    if (routeRecord.Legs) {
      legs = routeRecord.Legs;
    }
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
    newLegList.map((item) => {
      var flag = true;
      if (finalLegs.length == 0) {
        finalLegs.push(item);
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
      item.orgDest = "Rail";
    }
    if (leg.transModeCode == "O" || leg.transModeCode == "F") {
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
