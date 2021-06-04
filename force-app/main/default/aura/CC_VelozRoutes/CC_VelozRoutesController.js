({
  doInit: function (component, event, helper) {
    helper.setInitValues(component, event, helper);
  },
  handlePriceSorting: function (component, event, helper) {
    component.set("v.sortingTransitClass", "");
    var sortingPriceClass = component.get("v.sortingDepartureClass");
    if (
      (sortingDepartureClass === "") |
      (sortingDepartureClass === "active desc")
    ) {
      component.set("v.sortingPriceClass", "active asc");
      this.sortDepartureDate(component, event, "asc");
    } else {
      component.set("v.sortingPriceClass", "active desc");
      this.sortDepartureDate(component, event, "desc");
    }
  },
  /*  sortingTransitTime : function(component, event) {
        component.set("v.sortingPriceClass","");
        var sortingTransitClass= component.get("v.sortingTransitClass");
        if(sortingTransitClass==="" || sortingTransitClass==="active desc"){
            component.set("v.sortingTransitClass", "active asc");
            this.sortTransitTime(component, event, 'asc');
        }else{
            component.set("v.sortingTransitClass", "active desc");
            this.sortTransitTime(component, event, 'desc');
        }
    },*/
  handleSorting: function (component, event, helper) {
    var sortBy = component.get("v.sortBy");
    var eventSortBy = event.currentTarget.id;
    if (eventSortBy === "Price") {
      component.set("v.sortingTransitClass", "");
      var sortingPriceClass = component.get("v.sortingPriceClass");
      if ((sortingPriceClass === "") | (sortingPriceClass === "active desc")) {
        component.set("v.sortingPriceClass", "active asc");
      } else {
        component.set("v.sortingPriceClass", "active desc");
      }
    }
    if (eventSortBy === "Duration") {
      component.set("v.sortingPriceClass", "");
      var sortingTransitClass = component.get("v.sortingTransitClass");
      if (
        (sortingTransitClass === "") |
        (sortingTransitClass === "active desc")
      ) {
        component.set("v.sortingTransitClass", "active asc");
      } else {
        component.set("v.sortingTransitClass", "active desc");
      }
    }
    var sortByDirection = component.get("v.sortByDirection");
    if (sortBy == eventSortBy) {
      if (sortByDirection == "desc") {
        component.set("v.sortByDirection", "asc");
      } else {
        component.set("v.sortByDirection", "desc");
      }
    } else {
      component.set("v.sortBy", eventSortBy);
      component.set("v.sortByDirection", "asc");
    }
    var responseWrapper = component.get("v.responseWrapper");
    helper.setRoutes(component, event, helper, responseWrapper);
  },

  /*handleWrapperChange: function (component, event, helper) {
        var responseWrapper = event.getParam("value");
        if (responseWrapper.result) {
            helper.setRoutes(component, event, helper, responseWrapper);
            component.set('v.showRates', true);
        } else {
            component.set('v.showRates', false);
        }
    },*/

  handleSelectedRouteListChange: function (component, event, helper) {
    var selectedList = event.getParam("value");
    if (selectedList.length > 2) {
      component.set("v.disableCheckBox", true);
    } else {
      component.set("v.disableCheckBox", false);
    }
  },
  selectedSchedulesListChange: function (component, event, helper) {
    var disableNext = true;
    var bookingWrapper = component.get("v.bookingWrapper");
    var selectedSchedulesList = component.get("v.selectedSchedulesList");
    var scheduleNumberRoutesMap = component.get("v.scheduleNumberRoutesMap");
    var schedules = component.get("v.schedules");
    bookingWrapper.shipmentMap.CONTAINER.listVogage = [];
    bookingWrapper.shipmentMap.VEHICLE.listVogage = [];
    bookingWrapper.shipmentMap.BREAKBULK.listVogage = [];
    bookingWrapper.shipment.shipment = {};
    bookingWrapper.selectedRouteId = 0;
    bookingWrapper.selectedScheduleSequence = 0;

    console.log(
      "velozRoutesController::selectedSchedulesList:: " +
        JSON.stringify(selectedSchedulesList)
    );

    if (
      !$A.util.isUndefined(selectedSchedulesList) &&
      !$A.util.isEmpty(selectedSchedulesList)
    ) {
      disableNext = false;

      var route = {};
      var selectedSchedule = {};
      var routeScheduleKey = selectedSchedulesList[0].routeScheduleKey.split(
        ":"
      );
      var routeId = routeScheduleKey[0];
      var selectedScheduleSequence = routeScheduleKey[1];

      for (var i = 0; i < schedules.length; i++) {
        if (schedules[i].sequenceNumber == selectedScheduleSequence) {
          selectedSchedule = schedules[i];
          break;
        }
      }
      for (var i = 0; i < scheduleNumberRoutesMap.length; i++) {
        if (scheduleNumberRoutesMap[i].value.RouteId == routeId) {
          route = scheduleNumberRoutesMap[i].value;
          break;
        }
      }

      if (
        !$A.util.isUndefined(route) &&
        !$A.util.isEmpty(route) &&
        !$A.util.isUndefined(selectedSchedule) &&
        !$A.util.isEmpty(selectedSchedule)
      ) {
        bookingWrapper.selectedScheduleSequence = parseInt(
          selectedScheduleSequence
        );
        bookingWrapper.selectedRouteId = route.RouteId;
        if (
          !$A.util.isUndefined(selectedSchedule.Segments) &&
          !$A.util.isEmpty(selectedSchedule.Segments)
        ) {
          for (var k = 0; k < selectedSchedule.Segments.length; k++) {
            if (selectedSchedule.Segments[k].IsOcean) {
              var Voyage = new Object();
              Voyage.Vessel_Name__c = selectedSchedule.Segments[k].VesselName;
              Voyage.Voyage_Number__c =
                selectedSchedule.Segments[k].VoyageNumber.NumberX;
              Voyage.Loading_Location_Code__c =
                selectedSchedule.Segments[k].FromLocation.Code;
              Voyage.Discharge_Location_Code__c =
                selectedSchedule.Segments[k].ToLocation.Code;
              Voyage.Estimate_Sail_Date__c = new Date(
                selectedSchedule.StartSailingDate.LocalPortTime
              );
              Voyage.Estimate_Arrival_Date__c = new Date(
                selectedSchedule.EndSailingDate.LocalPortTime
              );
              bookingWrapper.shipmentMap.CONTAINER.listVogage.push(Voyage);
              bookingWrapper.shipmentMap.VEHICLE.listVogage.push(Voyage);
              bookingWrapper.shipmentMap.BREAKBULK.listVogage.push(Voyage);
            }
          }
        }
      }
    }
    component.set("v.disableNext", disableNext);
    component.set("v.bookingWrapper", bookingWrapper);
    console.log(
      "velozRoutesController::bookingWrapper:: " +
        JSON.stringify(bookingWrapper)
    );
  }
});
