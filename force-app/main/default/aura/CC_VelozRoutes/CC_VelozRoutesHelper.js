({
  // $Label.c.CC_VC_Route_TC_1
  // $Label.c.CC_VC_Route_TC_2
  // $Label.c.CC_VC_Route_TC_3
  // $Label.c.CC_VC_Route_TC_4
  // $Label.c.CC_VC_Route_TC_5
  // $Label.c.CC_VC_Route_TC_6
  // $Label.c.CC_VC_Route_TC_7
  // $Label.c.CC_VC_Route_TC_8
  // $Label.c.CC_VC_Route_TC_9
  // $Label.c.CC_VC_Route_TC_10
  // $Label.c.CC_VC_Route_TC_11
  // $Label.c.CC_VC_Route_TC_12
  setInitValues: function (component, event, helper) {
    component.set("v.sortBy", "Price");
    component.set("v.sortByDirection", "asc");
    /*var rateMapping = [
      {
        "itemNum": 1,
        "containerName": "20'Dry Container",
        "quantity": 2,
        "containerCode": "20DS"
      },
      {
        "itemNum": 2,
        "containerName": "40'Dry Container",
        "quantity": 1,
        "containerCode": "40DS"
      },
    ];*/

    component.set("v.showRates", true);
    component.set("v.selectedRoutesList", []);
    //component.set("v.selectedSchedulesList", []);
    var screen = component.get("v.screen");
    //component.set("v.rateMapping", rateMapping);
    var response = component.get("v.responseWrapper");
    if (response) {
      try {
        var newResponseResult = this.addTransitTime(response.result);
        newResponseResult = this.addPrice(component, newResponseResult);
        response.result = newResponseResult;
      } catch (err) {
        console.log("Error in finding Transit Time or Price");
      }
      helper.fetchClauses(component, event, helper);
      helper.setOriginAndDestinationObj(component, event, helper);
      var schedules = [];
      var mapRouteSchedule = [];
      var count = 1;
      for (var i = 0; i < response.result.length; i++) {
        var route = response.result[i];
        for (var j = 0; j < route.Schedules.length; j++) {
          route.Schedules[j].sequenceNumber = count;
          route.Schedules[j].price = route.price;
          route.Schedules[j].departureDate = this.handleDates(
            route.Schedules[j].StartDate.LocalPortTime
          );
          route.Schedules[j].arrivalDate = this.handleDates(
            route.Schedules[j].EndDate.LocalPortTime
          );
          count++;
          schedules.push(route.Schedules[j]);
          mapRouteSchedule.push({
            key: route.Schedules[j].sequenceNumber,
            value: route
          });
        }
      }
      if (screen == "CreateBooking") {
        var selectedSchedulesList = component.get("v.selectedSchedulesList");
        if (
          !$A.util.isUndefined(selectedSchedulesList) &&
          !$A.util.isEmpty(selectedSchedulesList)
        ) {
          component.set("v.disableNext", false);
        } else {
          component.set("v.disableNext", true);
        }
      }
      component.set("v.schedules", schedules);
      component.set("v.scheduleNumberRoutesMap", mapRouteSchedule);
      helper.setRoutes(component, event, helper, response);
    }
  },

  handleDates: function (dates) {
    dates = dates.substr(0, 10);
    return $A.localizationService.formatDate(dates, "MMM dd, yyyy");
  },

  fetchClauses: function (component, event, helper) {
    var screen = component.get("v.screen");
    if (screen == "CreateBooking") {
      var TNC =
        $A.get("$Label.c.BookingConfirmationTermsAndConditions") +
        "\n" +
        $A.get("$Label.c.BookingConfirmationTermsAndConditions1") +
        "\n" +
        $A.get("$Label.c.BookingConfirmationTermsAndConditions2");
      var Terms = TNC.split("\n");
      var listTNC = [];
      for (var i = 0; i < Terms.length; i++) {
        var str1 = Terms[i].replace("\\n", "");
        listTNC.push(str1);
      }
      component.set("v.termsAndConditions", listTNC);
    } else {
      var action = component.get("c.fetchTermsAndConditions");
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var res = response.getReturnValue();
          var termsAndConditions = [];
          res.map((term) => {
            var termsString = $A.get("$Label.c." + term);
            termsAndConditions.push(termsString);
          });
          component.set("v.termsAndConditions", termsAndConditions);
        } else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              helper.showToast(
                "error",
                "Error!",
                "Something went wrong. Please try again."
              );
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    }
  },

  setOriginAndDestinationObj: function (component, event, helper) {
    var bookingWrapper = component.get("v.bookingWrapper");
    if (
      bookingWrapper &&
      bookingWrapper.booking &&
      bookingWrapper.booking.Description__c
    ) {
      var description = bookingWrapper.booking.Description__c;
      var originObject = {};
      var destinationObject = {};
      if (description.startsWith("D")) {
        originObject.type = "Door";
        var country = this.checkNull(
          bookingWrapper.booking.Customer_Origin_Country__c
        );
        if (country.toUpperCase() === "US") {
          originObject.code = this.checkNull(
            bookingWrapper.booking.Customer_Origin_Zip__c
          );
        } else {
          originObject.code = "";
        }
      }
      if (description.startsWith("P")) {
        originObject.type = "Port";
        originObject.code = bookingWrapper.booking.Customer_Origin_Code__c;
      }
      if (description.startsWith("R")) {
        originObject.type = "Rail";
        originObject.code = bookingWrapper.booking.Customer_Origin_Code__c;
      }
      if (description.endsWith("D")) {
        destinationObject.type = "Door";
        var country = this.checkNull(
          bookingWrapper.booking.Customer_Destination_Country__c
        );
        if (country.toUpperCase() === "US") {
          destinationObject.code = this.checkNull(
            bookingWrapper.booking.Customer_Destination_Zip__c
          );
        } else {
          destinationObject.code = "";
        }
      }
      if (description.endsWith("P")) {
        destinationObject.type = "Port";
        destinationObject.code =
          bookingWrapper.booking.Customer_Destination_Code__c;
      }
      if (description.endsWith("R")) {
        destinationObject.type = "Rail";
        destinationObject.code =
          bookingWrapper.booking.Customer_Destination_Code__c;
      }
      component.set("v.originObject", originObject);
      component.set("v.destinationObject", destinationObject);
    }
  },

  addTransitTime: function (routes) {
    var newRoutes = [];
    routes.map((item) => {
      var duration = item.Duration;
      item.Schedules = this.addScheduleTime(item.Schedules);
      var finalDay = 0;
      var daysVsHours = duration.AmountInDays + "";
      var time = 0;
      if (daysVsHours && daysVsHours != null && daysVsHours != "") {
        finalDay = Math.floor(parseInt(daysVsHours));
      }
      if (duration.AmountinHours && duration.AmountinHours != 0) {
        time = duration.AmountinHours % 24;
      }
      item.transitTime = finalDay;
      item.transitTimeHrs = parseInt(time);
      item.transitSum = finalDay * 24 + item.transitTimeHrs;
      newRoutes.push(item);
    });
    return newRoutes;
  },
  addScheduleTime: function (schedules) {
    var newSchedules = [];
    schedules.map((schedule) => {
      var totalDays = 0;
      var totalHours = 0;
      var totalDuration = schedule.TotalDuration + "";
      if (totalDuration && totalDuration != null && totalDuration != "") {
        if (!totalDuration.includes(".")) {
          totalDuration = "0." + totalDuration;
        }
        var duration = totalDuration.split(".");
        if (duration.length > 0) {
          totalDays = Math.floor(parseInt(duration[0]));
          if (duration.length > 1) {
            var hours = duration[1];
            if (hours.length > 0 && hours.includes(":")) {
              var totalHour = hours.split(":");
              totalHours =
                totalHour.length > 0 ? Math.floor(parseInt(totalHour[0])) : 0;
            }
          }
        }

        schedule.totalDays = totalDays;
        schedule.totalHours = totalHours;
      }
      newSchedules.push(schedule);
    });
    return newSchedules;
  },

  addPrice: function (component, routes) {
    var newRoutes = [];
    var totalQuantity = 0;
    var rateMapping = component.get("v.rateMapping");
    rateMapping.map((item) => {
      totalQuantity += parseInt(item.quantity);
    });
    //var EEICharge = parseInt($A.get('$Label.c.CC_EEI_Charge'));
    //var INSCharge = parseInt($A.get('$Label.c.CC_INS_Charge'));
    //var optionalCharges = totalQuantity*INSCharge+EEICharge;
    routes.map((item) => {
      var itemValues = item.CalculatedContributionResult.ItemValues;
      var finalPrice = 0;
      itemValues.map((itemValue) => {
        var contributionData = itemValue.ContributionData;
        contributionData.map((data) => {
          finalPrice += data.SumRevenue;
        });
      });
      item.price = finalPrice;
      newRoutes.push(item);
    });
    return newRoutes;
  },

  setRoutes: function (component, event, helper, responseWrapper) {
    var sortyBy = component.get("v.sortBy");
    var sortByDirection = component.get("v.sortByDirection");
    var routes = responseWrapper.result;
    var schedules = component.get("v.schedules");
    if (component.get("v.screen") === "Quote") {
      var newRoutes = this.sortData(sortyBy, sortByDirection, routes);
      component.set("v.routes", newRoutes);
    }
    if (component.get("v.screen") === "CreateBooking") {
      schedules = this.sortData(sortyBy, sortByDirection, schedules);
      component.set("v.schedules", schedules);
    }
  },

  sortData: function (sortBy, direction, parsedJson) {
    var parseData = parsedJson;
    var isReverse = direction === "asc" ? 1 : -1;
    parseData.sort((x, y) => {
      var xFactor;
      var yFactor;
      if (sortBy == "Price") {
        xFactor = x["price"];
        yFactor = y["price"];
      } else if (sortBy == "Duration") {
        xFactor = x["transitSum"];
        yFactor = y["transitSum"];
      }
      x = xFactor ? xFactor : "";
      y = yFactor ? yFactor : "";
      return isReverse * ((x > y) - (y > x));
    });
    return parseData;
  },

  checkNull: function (value) {
    return value && value != null ? value : "";
  }
});
