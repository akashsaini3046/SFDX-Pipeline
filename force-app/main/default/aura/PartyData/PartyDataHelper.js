({
  fetchTypeData: function (component) {
    var partyListMap = [];
    var parties = component.get("v.parties");
    console.log("parties", JSON.stringify(parties));
    //OUTER LOOP
    for (var p in parties) {
      var partyMapList = parties[p];
      var partyAddress = [];
      var otherPartyData = [];
      //MID LOOP
      for (var c in partyMapList) {
        var partyMap = partyMapList[c];
        var listType;
        //INNER LOOP
        for (var key in partyMap) {
          var key = key;
          var val = partyMap[key];
          if (
            val == "Address Line1" ||
            val == "Address Line2" ||
            val == "City" ||
            val == "State" ||
            val == "Country" ||
            val == "Zip"
          )
            listType = "address";
          else listType = "others";
          break;
        }
        //END
        if (listType == "address") partyAddress.push(partyMap);
        if (listType == "others") otherPartyData.push(partyMap);
      }
      //END
      partyListMap.push({
        addressData: partyAddress,
        otherData: otherPartyData
      });
    }
    //END
    component.set("v.partyMap", partyListMap);
    console.log(JSON.stringify(partyListMap));
  }
});
