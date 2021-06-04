({
  fireEvent: function (component, event, helper) {
    var selectedItemID = component.get("v.item.Id");
    var getSelectItem = component.get("v.item.Name");
    var functionality = component.get("v.functionality");
    var originDestinationFunctionality = [
      "RouteFinder:Origin",
      "RouteFinder:Destination",
      "Quote:Origin",
      "Quote:Destination",
      "Quote:POL",
      "Quote:POD",
      "BOLEdit:Location",
      "BOLEdit:LoadPort"
    ];
    if (originDestinationFunctionality.indexOf(functionality) >= 0) {
      if (
        component.get("v.item.Location_Type__c") === "DOOR" &&
        component.get("v.item.Country_Name__c") !== "United States"
      ) {
        getSelectItem =
          component.get("v.item.Location_Type__c") +
          " - " +
          component.get("v.item.Location_Name__c");
      } else {
        getSelectItem =
          component.get("v.item.Location_Type__c") +
          " - " +
          component.get("v.item.Location_Name__c") +
          " (" +
          component.get("v.item.Name") +
          ")";
      }
    }
    if (
      functionality == "QuoteListFilter:Origin" ||
      functionality == "QuoteListFilter:Destination"
    ) {
      if (
        component.get("v.item.Location_Type__c") === "DOOR" &&
        component.get("v.item.Country_Name__c") !== "United States"
      ) {
        getSelectItem = component.get("v.item.Location_Name__c");
      } else {
        getSelectItem =
          component.get("v.item.Location_Name__c") +
          " (" +
          component.get("v.item.Name") +
          ")";
      }
    }
    if (functionality == "Container:Size_Type") {
      getSelectItem = component.get("v.item.Description__c");
    }
    if (functionality == "QuoteListFilter:Contract") {
      getSelectItem = component.get("v.item.Softship_Contract_Number__c");
    }
    if (functionality == "Idea:AssignedTo") {
      getSelectItem = component.get("v.item.Full_Name__c");
    }

    if (functionality == "BOL:hts") {
      selectedItemID = component.get("v.item.Id");
      getSelectItem =
        component.get("v.item.Type__c") +
        " " +
        component.get("v.item.Name") +
        " - " +
        component.get("v.item.Description__c");
    }
    if (functionality == "BOLEdit:VesselName") {
      var flagValue = component.get("v.item.Flag__c");
    }
    var compEvent = component.getEvent("selectedItemEvent");
    compEvent.setParams({
      selectedItem: getSelectItem,
      selectedItemID: selectedItemID,
      functionality: functionality,
      selectedFlag: flagValue
    });
    compEvent.fire();
  },
  mouseOut: function (component, event, helper) {
    component.set("v.clickedItem", "");
    component.set("v.clickedItemId", "");
  },
  mouseOver: function (component, event, helper) {
    var functionality = component.get("v.functionality");
    var getSelectItem = component.get("v.item.Name");
    var originDestinationFunctionality = [
      "RouteFinder:Origin",
      "RouteFinder:Destination",
      "Quote:Origin",
      "Quote:Destination",
      "Quote:POL",
      "Quote:POD",
      "BOLEdit:Location",
      "BOLEdit:LoadPort"
    ];
    if (originDestinationFunctionality.indexOf(functionality) >= 0) {
      if (
        component.get("v.item.Location_Type__c") === "DOOR" &&
        component.get("v.item.Country_Name__c") !== "United States"
      ) {
        console.log(
          component.get("v.item.Location_Type__c") +
            "   " +
            component.get("v.item.Country_Name__c")
        );
        getSelectItem =
          component.get("v.item.Location_Type__c") +
          " - " +
          component.get("v.item.Location_Name__c");
      } else {
        getSelectItem =
          component.get("v.item.Location_Type__c") +
          " - " +
          component.get("v.item.Location_Name__c") +
          " (" +
          component.get("v.item.Name") +
          ")";
      }
      //getSelectItem = '('+component.get("v.item.Location_Type__c")+') '+ component.get("v.item.Location_Name__c")+' ('+component.get("v.item.Name")+')';
    }
    if (
      functionality == "QuoteListFilter:Origin" ||
      functionality == "QuoteListFilter:Destination"
    ) {
      if (
        component.get("v.item.Location_Type__c") === "DOOR" &&
        component.get("v.item.Country_Name__c") !== "United States"
      ) {
        getSelectItem = component.get("v.item.Location_Name__c");
      } else {
        getSelectItem =
          component.get("v.item.Location_Name__c") +
          " (" +
          component.get("v.item.Name") +
          ")";
      }
    }
    if (functionality == "Container:Size_Type") {
      getSelectItem = component.get("v.item.Description__c");
    }
    if (functionality == "QuoteListFilter:Contract") {
      getSelectItem = component.get("v.item.Softship_Contract_Number__c");
    }

    if (functionality == "BOLListFilter:Booking") {
      getSelectItem = component.get("v.item.Booking_Number__c");
    }
    if (functionality == "BOLListFilter:LoadPort") {
      getSelectItem = component.get("v.item.Location_Name__c");
    }
    if (functionality == "Idea:AssignedTo") {
      getSelectItem = component.get("v.item.Full_Name__c");
    }

    if (functionality == "BOL:hts") {
      getSelectItem =
        component.get("v.item.Type__c") +
        " " +
        component.get("v.item.Name") +
        " - " +
        component.get("v.item.Description__c");
    }
    component.set("v.clickedItem", getSelectItem);
    component.set("v.clickedItemId", component.get("v.item.Id"));
  }
});
