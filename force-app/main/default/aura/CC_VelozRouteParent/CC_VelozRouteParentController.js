({
  doInit: function (component, event, helper) {
    var routeRecord = component.get("v.routeRecord");
    helper.setInitValues(component, event, helper, routeRecord);
  },
  handleSelectedRoute: function (component, event, helper) {
    var selectedRouteNum = event.target.value;
    var selectedRouteChecked = event.target.checked;
    var selectedRoutesList = component.get("v.selectedRoutesList");
    var selectedRoute = {};
    selectedRoute.routeId = selectedRouteNum;
    selectedRoute.startModes = component.get("v.startModes");
    selectedRoute.endModes = component.get("v.endModes");
    selectedRoute.betweenPortsOnly = JSON.stringify(
      component.get("v.betweenPortsOnly")
    );
    selectedRoute.startLocation = JSON.stringify(
      component.get("v.startLocation")
    );
    selectedRoute.endLocation = JSON.stringify(component.get("v.endLocation"));

    selectedRoutesList.push(selectedRoute);
    var newList = [];
    console.log("selectedRoutesList", selectedRoutesList);
    selectedRoutesList.map((item) => {
      if (item.routeId == selectedRouteNum) {
        if (selectedRouteChecked) {
          newList.push(item);
        }
      } else {
        newList.push(item);
      }
    });
    component.set("v.selectedRoutesList", newList);
    var outerDiv = component.find("outer-div");
    if (selectedRouteChecked) {
      $A.util.addClass(outerDiv, "selected-route");
      component.set("v.isSelected", true);
    } else {
      $A.util.removeClass(outerDiv, "selected-route");
      component.set("v.isSelected", false);
    }
    console.log(newList);
  },

  handleShowDetails: function (component, event, helper) {
    var showDetails = component.get("v.showDetails");
    component.set("v.showDetails", !showDetails);
    if (showDetails) {
      component.set("v.showDetailsText", "Show Details");
    } else {
      component.set("v.showDetailsText", "Hide Details");
    }
  }
});
