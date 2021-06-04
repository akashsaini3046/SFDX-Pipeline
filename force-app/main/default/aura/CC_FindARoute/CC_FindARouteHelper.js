({
  doInit: function (component, event) {
    var currentDate = new Date();
    var minDate = $A.localizationService.formatDate(
      currentDate.setDate(currentDate.getDate()),
      "YYYY-MM-DD"
    );
    //var maxDate = $A.localizationService.formatDate(currentDate.setDate(currentDate.getDate() + 365), "YYYY-MM-DD");
    component.set("v.minDate", minDate);
    //component.set("v.maxDate", maxDate);
  },
  getBookingWrap: function (component, event) {
    var action = component.get("c.getBookingWrapper");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var bookingWrapper = response.getReturnValue();
        console.log(bookingWrapper);
        component.set("v.bookingWrapper", bookingWrapper);
      } else if (state === "ERROR") {
        console.log("error");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  getLocation: function (component, event, functionality, locationId) {
    component.set("v.isLoading", true);
    var bookingWrapper = component.get("v.bookingWrapper");
    var action = component.get("c.fetchLocation");
    action.setParams({
      recordId: locationId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var locations = response.getReturnValue();
        console.log(locations);
        if (functionality === "RouteFinder:Origin") {
          if (locations[0].Location_Type__c == "PORT") {
            component.set("v.originMove", "P");
            bookingWrapper.booking.Customer_Origin_Code__c = locations[0].Name;
            this.getSubLocation(component, event, functionality, locations[0]);
          }
          if (locations[0].Location_Type__c == "RAIL RAMP") {
            component.set("v.originMove", "R");
            bookingWrapper.booking.Transportation_Management_System_Origin__c =
              "M";
            bookingWrapper.booking.Customer_Origin_Code__c = locations[0].Name;
            this.getSubLocation(component, event, functionality, locations[0]);
          }
          if (locations[0].Location_Type__c == "DOOR") {
            component.set("v.originMove", "D");
            bookingWrapper.booking.Pickup_Location__c = "";
            bookingWrapper.booking.Customer_Origin_Zip__c = locations[0].Name;
            bookingWrapper.booking.Customer_Origin_Code__c =
              locations[0].LcCode__c;
          }
        }
        if (functionality === "RouteFinder:Destination") {
          if (locations[0].Location_Type__c == "PORT") {
            component.set("v.destinationMove", "P");
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].Name;
            this.getSubLocation(component, event, functionality, locations[0]);
          }
          if (locations[0].Location_Type__c == "RAIL RAMP") {
            component.set("v.destinationMove", "R");
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].Name;
            bookingWrapper.booking.Transportation_Management_System_Destina__c =
              "M";
            this.getSubLocation(component, event, functionality, locations[0]);
          }
          if (locations[0].Location_Type__c == "DOOR") {
            component.set("v.destinationMove", "D");
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].LcCode__c;
            bookingWrapper.booking.Customer_Destination_Zip__c =
              locations[0].Name;
            bookingWrapper.booking.Delivery_Location__c = "";
          }
        }
        component.set("v.bookingWrapper", bookingWrapper);
      } else {
        console.log("Error occured in In fetching Location");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  getSubLocation: function (component, event, functionality, location) {
    var action = component.get("c.fetchSubLocation");
    action.setParams({
      locCode: location.Name,
      locType: location.Location_Type__c
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var locations = response.getReturnValue();
        if (functionality === "RouteFinder:Origin") {
          component.set("v.originSubLocation", locations);
        }
        if (functionality === "RouteFinder:Destination") {
          component.set("v.destinationSubLocation", locations);
        }
      } else {
        console.log("Error occured in In fetching Location");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  searchFindRoute: function (component, event, helper) {
    /*if(!this.validateForm(component,event)){
           return false; 
        }*/
    component.set("v.isLoading", true);
    var action = component.get("c.getSoftShipResponse");
    var bookingWrap = component.get("v.bookingWrapper");
    var originMove = component.get("v.originMove");
    var destinationMove = component.get("v.destinationMove");
    bookingWrap.booking.Description__c = originMove + destinationMove;
    console.log(originMove + destinationMove);
    action.setParams({
      stringBookingWrapper: JSON.stringify(bookingWrap)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.showErrorMessage", false);
        var responseValue = response.getReturnValue();
        console.log(responseValue);
        if (
          responseValue != null &&
          responseValue.success &&
          responseValue.result != null &&
          responseValue.result.length > 0
        ) {
          var resultArray = [];
          var itemObj = {};
          for (var j in responseValue.result) {
            var isValidRatePage = true;
            if (responseValue.result[j].Legs.length == 0) {
              isValidRatePage = false;
            }
            if (responseValue.result[j].Schedules.length == 0) {
              isValidRatePage = false;
            }
            if (
              responseValue.result[j].CalculatedContributionResult.ItemValues
                .length == 0
            ) {
              isValidRatePage = false;
            } else if (
              responseValue.result[j].CalculatedContributionResult.ItemValues[0]
                .ValuesDataRevenue.length == 0
            ) {
              isValidRatePage = false;
            } else if (
              responseValue.result[j].CalculatedContributionResult.ItemValues[0]
                .ContributionData.length == 0
            ) {
              isValidRatePage = false;
            } else if (
              responseValue.result[j].CalculatedContributionResult.ItemValues[0]
                .ContributionData[0].SumRevenue == 0
            ) {
              isValidRatePage = false;
            }

            if (isValidRatePage) {
              resultArray.push(responseValue.result[j]);
              /*  var contribution = [];
                            var item = {};
                            var sumrevenue = responseValue.result[j].CalculatedContributionResult.ItemValues[0].ContributionData[0].SumRevenue;
                            item ["routeId"] =responseValue.result[j].RouteId;
                            item ["ContributionAmount"] = responseValue.result[j].CalculatedContributionResult.ItemValues[0].ContributionData[0].ContributionAmount;
                            item ["SumRevenue"] = sumrevenue;
                            item ["TransitTime"] = this.getdays(responseValue.result[j].Duration.AmountInDays);
                            item ["isDisplay"] = false;
                            if(itemObj[sumrevenue] && itemObj[sumrevenue].length>0){
                                itemObj[sumrevenue].push(item);                                
                            }else{
                                contribution.push(item);
                                itemObj[sumrevenue] = contribution;
                            }   */
            }
          }
          var finalResultArray = [];
          /* if(resultArray.length>0){
                        console.log(itemObj);
                        var objectKeys =Object.keys(itemObj);
                        var finalRoutesToDisplay = [];
                        for(var j in objectKeys){
                            if(itemObj[objectKeys[j]].length>0){   
                                
                                itemObj[objectKeys[j]].sort(function(a, b){								
                                    return b.ContributionAmount-a.ContributionAmount
                                });
                                
                                var countSameContribution = 0;
                                var contributionAmount = itemObj[objectKeys[j]][0].ContributionAmount;							
                                itemObj[objectKeys[j]].forEach(function(value, index, array) {
                                    if(contributionAmount == value.ContributionAmount){
                                        value.isDisplay = true;
                                        countSameContribution++;
                                    }else{
                                        value.isDisplay = false;
                                        //array.splice(index, 1);
                                    }
                                    
                                });
                                if(countSameContribution>1){
                                    itemObj[objectKeys[j]].sort(function(a, b){								
                                        return a.TransitTime-b.TransitTime
                                    });	
                                    var transitTime = itemObj[objectKeys[j]][0].TransitTime;
                                    var countTransitTime = 0;
                                    itemObj[objectKeys[j]].forEach(function(value, index, array) {
                                        if(value.isDisplay){
                                            if(transitTime == value.TransitTime){
                                                countTransitTime++;
                                            }else{
                                                value.isDisplay=false;
                                                //array.splice(index, 1);
                                            }
                                        }
                                    });
                                    if(countTransitTime>1){
                                        itemObj[objectKeys[j]].forEach(function(value, index, array) {
                                            if(value.isDisplay){
                                            	finalRoutesToDisplay.push(value);
                                            }
                                        });
                                    }else{
                                        finalRoutesToDisplay.push(itemObj[objectKeys[j]][0]);
                                    }
                                }else{
                                    finalRoutesToDisplay.push(itemObj[objectKeys[j]][0]);
                                }							
                            }
                        }
                        for(var i in finalRoutesToDisplay){
                            for(var j in resultArray){
                                if(finalRoutesToDisplay[i].routeId == resultArray[j].RouteId ){
                                    finalResultArray.push(resultArray[j]);
                                    break;
                                }                            
                            }
                        }
                    }  */

          if (resultArray.length > 0) {
            //responseValue.result=resultArray;
            responseValue.result = resultArray;
            this.processSchedules(component, JSON.stringify(responseValue));
          } else {
            component.set("v.numberOfSchedules", 0);
            component.set(
              "v.errorMessage",
              "No Schedules found for the selected date and route, please try again for a different route & date combination"
            );
            component.set("v.showErrorMessage", true);
            component.set("v.isLoading", false);
          }
        } else {
          component.set("v.numberOfSchedules", 0);
          component.set(
            "v.errorMessage",
            "No Schedules found for the selected date and route, please try again for a different route & date combination"
          );
          component.set("v.showErrorMessage", true);
          component.set("v.isLoading", false);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            component.set("v.numberOfSchedules", 0);
            component.set(
              "v.errorMessage",
              "No Schedules found for the selected date and route, please try again for a different route & date combination"
            );
            component.set("v.showErrorMessage", true);
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
        console.log(" searchFindRoute error ");
        component.set("v.isLoading", false);
      }
    });
    $A.enqueueAction(action);
  },

  getdays: function (duration) {
    var finalDay = 0;
    var daysVsHours = duration + "";
    if (daysVsHours && daysVsHours != null && daysVsHours != "") {
      finalDay = Math.round(parseFloat(daysVsHours));
      if (finalDay == 0) {
        finalDay = 1;
      }
    }
    return finalDay;
  },

  validateForm: function (component, event) {
    var controlAuraIds = ["readyDateId"];
    let isAllValid = controlAuraIds.reduce(function (
      isValidSoFar,
      controlAuraId
    ) {
      var inputCmp = component.find(controlAuraId);
      inputCmp.reportValidity();
      return isValidSoFar && inputCmp.checkValidity();
    },
    true);
    var originLocation = component.find("originId");
    var isOriginValid = originLocation.doValidityCheck();
    var destinationLocation = component.find("destinationId");
    var isdestinationValid = destinationLocation.doValidityCheck();
    return isAllValid && isOriginValid && isdestinationValid;
  },

  clearLocation: function (component, event, functionality) {
    var bookingWrapper = component.get("v.bookingWrapper");
    if (functionality === "RouteFinder:Origin") {
      component.set("v.originMove", "");
      bookingWrapper.booking.Pickup_Location__c = "";
      bookingWrapper.booking.Pickup_Location__c = "";
      bookingWrapper.booking.Customer_Origin_Code__c = "";
      bookingWrapper.booking.Transportation_Management_System_Origin__c = "";
    }
    if (functionality === "RouteFinder:Destination") {
      component.set("v.destinationMove", "");
      bookingWrapper.booking.Customer_Destination_Code__c = "";
      bookingWrapper.booking.Delivery_Location__c = "";
      bookingWrapper.booking.Transportation_Management_System_Destina__c = "";
    }
    component.set("v.schedules", []);
    component.set("v.numberOfSchedules", 0);
    component.set("v.bookingWrapper", bookingWrapper);
  },
  checkGuestUser: function (component, event) {
    console.log("inisde check guest user");
    var action = component.get("c.getIsOpenCommunity");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        console.log("responseData " + responseData);
        if (responseData === true) component.set("v.isGuestUser", true);
        else component.set("v.isGuestUser", false);

        console.log("v.isGuestUser " + component.get("v.isGuestUser"));
      }
    });
    $A.enqueueAction(action);
  },
  processSchedules: function (component, responseString) {
    var originMove = component.get("v.originMove");
    var destinationMove = component.get("v.destinationMove");
    var action = component.get("c.getSchedules");
    action.setParams({
      responseString: responseString
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.showErrorMessage", false);
        var responseData = response.getReturnValue();
        console.log(responseData);
        component.set("v.loading", false);
        var numberOfSchedules = 0;
        var countSegmentSequence = 1;
        var schedules = responseData;
        numberOfSchedules = numberOfSchedules + schedules.length;
        console.log("numberOfSchedules " + numberOfSchedules);
        for (var j in schedules) {
          schedules[j].sequenceNumber = countSegmentSequence;
          countSegmentSequence++;
          var lastSegmentIndex = schedules[j].Segments.length - 1;
          schedules[j].numberOfStops = schedules[j].Segments.length - 1;
          // schedules[j].numberOfSegments = schedules[j].Segments.length;
          schedules[j].startLocationCode =
            schedules[j].Segments[0].FromLocation.Code;
          schedules[j].endLocationCode =
            schedules[j].Segments[lastSegmentIndex].ToLocation.Code;

          if (originMove == "P" || originMove == "R") {
            schedules[j].startLocation =
              schedules[j].Segments[0].FromSubDisplayName;
          }
          if (originMove == "D") {
            schedules[j].startLocation =
              schedules[j].Segments[0].Legs.StartPosition.DisplayName;
          }
          if (destinationMove == "P" || destinationMove == "R") {
            schedules[j].endLocation =
              schedules[j].Segments[lastSegmentIndex].ToSubDisplayName;
          }
          if (destinationMove == "D") {
            schedules[j].endLocation =
              schedules[j].Segments[
                lastSegmentIndex
              ].Legs.EndPosition.DisplayName;
          }
          /* if(schedules[j].Segments[0].FromSubDisplayName !== null)
                        schedules[j].startLocation = schedules[j].Segments[0].FromSubDisplayName;
                    else
                        schedules[j].startLocation = schedules[j].Segments[0].Leg.StartPosition.DisplayName;
                    if(schedules[j].Segments[lastSegmentIndex].ToSubDisplayName !== null)
                        schedules[j].endLocation = schedules[j].Segments[lastSegmentIndex].ToSubDisplayName;
                    else
                        schedules[j].endLocation = schedules[j].Segments[lastSegmentIndex].Leg.EndPosition.DisplayName;  */
          for (var k in schedules[j].Segments) {
            k = parseInt(k);
            if (k > 0) {
              if (!schedules[j].Segments[k - 1].IsOcean) {
                schedules[j].Segments[k].arrivalToDisplay =
                  schedules[j].Segments[k - 1].ArrivalTime.LocalPortTime;
              }
              if (schedules[j].Segments[k - 1].IsOcean) {
                schedules[j].Segments[k].arrivalToDisplay =
                  schedules[j].Segments[
                    k - 1
                  ].To.Berths[0].Arrival.LocalPortTime;
              }
            }

            var loopCount = schedules[j].Segments.length - 1;
            if (k < loopCount) {
              if (!schedules[j].Segments[k + 1].IsOcean) {
                schedules[j].Segments[k].departureToDisplay =
                  schedules[j].Segments[k + 1].DepartureTime.LocalPortTime;
              }
              if (schedules[j].Segments[k + 1].IsOcean) {
                schedules[j].Segments[k].departureToDisplay =
                  schedules[j].Segments[
                    k + 1
                  ].FromX.Berths[0].Departure.LocalPortTime;
              }
            }
          }
        }

        console.log(" searchFindRoute success ");
        console.log(schedules);
        component.set("v.schedules", schedules);
        component.set("v.numberOfSchedules", numberOfSchedules);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            component.set("v.numberOfSchedules", 0);
            component.set(
              "v.errorMessage",
              "No Schedules found for the selected date and route, please try again for a different route & date combination"
            );
            component.set("v.showErrorMessage", true);
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
        console.log(" searchFindRoute error ");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  }
});
