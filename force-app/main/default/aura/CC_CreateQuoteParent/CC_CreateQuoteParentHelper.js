({
  getURLParameter: function (key) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1));
    var sURLVariables = sPageURL.split("&");
    var sParameterName;
    var i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("=");
      if (sParameterName[0] == key) {
        return sParameterName[1];
      }
    }
    return "";
  },
  getBookingWrap: function (component, event, actionType) {
    component.set("v.isLoading", true);
    var action = component.get("c.getBookingWrapper");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var bookingWrapper = response.getReturnValue();
        var urlParam = this.getURLParameter("booking");
        if (urlParam !== "") {
          var booking = JSON.parse(urlParam);
          bookingWrapper.booking = booking;
        }

        var urlQuoteParam = this.getURLParameter("id");
        if (urlQuoteParam !== "") {
          var returnValue = this.getPrefilledBookingWrap(
            component,
            event,
            urlQuoteParam
          );
          if (returnValue != null) {
            bookingWrapper = returnValue;
          }
        }
        if (component.get("v.isPostLogin") === true) {
          bookingWrapper.shipmentMap.VEHICLE.listCargo[0].listFreightDetailWrapper[0].commodityCode =
            "";
          bookingWrapper.shipmentMap.VEHICLE.listCargo[0].listFreightDetailWrapper[0].commodityDesc =
            "";
        }
        console.log(bookingWrapper);
        if (actionType == "newQuote") {
          var oldQuote = component.get("v.bookingWrapper");
          bookingWrapper.booking.Customer_Email__c =
            oldQuote.booking.Customer_Email__c;
          bookingWrapper.booking.Contact_Name__c =
            oldQuote.booking.Contact_Name__c;
          bookingWrapper.booking.Company_Name__c =
            oldQuote.booking.Company_Name__c;
          bookingWrapper.booking.Contact_Number__c =
            oldQuote.booking.Contact_Number__c;
        }
        component.set("v.isLoading", false);
        component.set("v.bookingWrapper", bookingWrapper);
      } else if (state === "ERROR") {
        console.log("error");
        component.set("v.isLoading", false);
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  getPrefilledBookingWrap: function (component, event, quoteId) {
    var action = component.get("c.getBookingWrapperFromQuote");
    component.set("v.isLoadingCreateQuote", true);
    action.setParams({
      QuoteId: quoteId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseValue = response.getReturnValue();
        component.set("v.bookingWrapper", responseValue);
        var childComponent = component.find("originDestinationId");
        childComponent.ReinitaliseData();
        component.set("v.isLoadingCreateQuote", false);
        childComponent.setContractRelatedData(
          responseValue.booking.Contract__c
        );
        return responseValue;
      } else if (state === "ERROR") {
        console.log("error");
        component.set("v.isLoadingCreateQuote", false);
        return null;
      }
      component.set("v.isLoadingCreateQuote", false);
    });
    $A.enqueueAction(action);
  },

  callRates: function (component, event) {
    component.set("v.createdQuoteIds", []);
    component.set("v.isLoadingFindRates", true);
    component.set("v.serverError", "");
    var isdisplayRatePage = true;
    var action = component.get("c.getRates");
    var bookingWrap = component.get("v.bookingWrapper");
    component.set("v.softshipRatingResponse", {
      success: false
    });
    action.setParams({
      stringWrapperRequest: JSON.stringify(bookingWrap)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var isTimeoutError = false;
      var isErrorMessage = "";
      var showAdditionalInfo = false;
      if (state === "SUCCESS") {
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
              /*var contribution = [];
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
                            }*/
            }
          }
          var finalResultArray = [];
          /*if(resultArray.length>0){
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
                    }*/
          if (resultArray.length > 0) {
            responseValue.result = resultArray;
          } else {
            isdisplayRatePage = false;
          }
        } else {
          isdisplayRatePage = false;
        }
        responseValue.success = isdisplayRatePage;
        if (!responseValue.success || responseValue.isTimeoutError) {
          if (responseValue.isTimeoutError) {
            isTimeoutError = responseValue.isTimeoutError;
            this.createCaseAndSendEmail(
              component,
              event,
              JSON.stringify(responseValue)
            );
          } else if (
            responseValue.errorMessage &&
            responseValue.errorMessage != null &&
            responseValue.errorMessage != ""
          ) {
            isErrorMessage = responseValue.errorMessage;
            if (
              isErrorMessage.includes("Value cannot be null") ||
              isErrorMessage.includes("No routes found")
            ) {
              component.set("v.softshipRatingResponse", {
                success: false
              });
              component.set("v.isdisplayRatePage", false);
              showAdditionalInfo = true;
            } else {
              this.createCaseAndSendEmail(
                component,
                event,
                JSON.stringify(responseValue)
              );
            }
          }
        }
        component.set("v.isdisplayRatePage", isdisplayRatePage);
        component.set("v.softshipRatingResponse", responseValue);
      } else if (state === "ERROR") {
        console.log("error");
        component.set("v.softshipRatingResponse", {
          success: false
        });
        component.set("v.isdisplayRatePage", false);
      }
      component.set("v.isLoadingFindRates", false);
      if (isTimeoutError) {
        component.set("v.serverError", "Timeout");
      } else if (isErrorMessage != "") {
        if (showAdditionalInfo) {
          component.set("v.currentStep", "3");
        } else {
          component.set("v.serverError", "NotReachable");
        }
      } else {
        component.set("v.currentStep", "3");
      }
    });

    $A.enqueueAction(action);
  },

  createCaseAndSendEmail: function (component, event, responseString) {
    var bookingWrap = component.get("v.bookingWrapper");
    var selectedRoutesList = component.get("v.selectedRoutesList");
    var rateMapping = component.get("v.rateMapping");
    var action = component.get("c.createCaseAndNotify");
    action.setParams({
      bookingWrapperString: JSON.stringify(bookingWrap),
      responseString: responseString,
      selectedRoutesList: JSON.stringify(selectedRoutesList),
      rateMapping: JSON.stringify(rateMapping)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseValue = response.getReturnValue();
      } else if (state === "ERROR") {
        console.log("error");
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

  setContainerItemsMapping: function (component, event) {
    var itemMappings = [];
    var bookingWrapper = component.get("v.bookingWrapper");
    bookingWrapper.booking.Is_Hazardous__c =
      bookingWrapper.shipmentMap.CONTAINER.listCargo[0].isHazardous;
    var listFreightDetailWrappers =
      bookingWrapper.shipmentMap.CONTAINER.listCargo[0]
        .listFreightDetailWrapper;
    var k = 1;
    var commodityTypes = component.get("v.commodityTypes");
    var tariffsCommodities = component.get("v.tariffsCommodities");
    for (var i in listFreightDetailWrappers) {
      var listRequirement = listFreightDetailWrappers[i].listRequirementWrapper;
      for (var j in listRequirement) {
        var commodityDesc = "";
        var optionalInfo = "";
        if (bookingWrapper.shipmentMap.CONTAINER.listCargo[0].isHazardous) {
          optionalInfo = ", Hazardous";
        }
        if (listRequirement[j].requirement.OutOfGauge__c) {
          optionalInfo += ", Out of Gauge";
        }
        if (listRequirement[j].requirement.IsShippersOwn__c) {
          optionalInfo += ", Shipper Owned";
        }
        if (listRequirement[j].requirement.IsNonOperativeReefer__c) {
          optionalInfo += ", NOR";
        }
        for (var l in commodityTypes) {
          if (
            commodityTypes[l].Commodity_Code__c ==
            listRequirement[j].commodityCode
          ) {
            commodityDesc = commodityTypes[l].Commodity_Name__c;
            break;
          }
        }
        if (
          commodityDesc == "" &&
          tariffsCommodities &&
          tariffsCommodities.length > 0
        ) {
          for (var l in tariffsCommodities) {
            if (
              tariffsCommodities[l].Commodity_Code__c ==
              listRequirement[j].commodityCode
            ) {
              commodityDesc = tariffsCommodities[l].Commodity_Name__c;
              break;
            }
          }
        }
        listRequirement[j].commodityDesc = commodityDesc;
        if (optionalInfo != "") {
          optionalInfo =
            ")<br/>(" + optionalInfo.substring(1, optionalInfo.length);
        }

        var item = {};
        item["itemNum"] = k++;
        item["containerName"] =
          listRequirement[j].containerDesc +
          "___" +
          commodityDesc +
          optionalInfo;
        item["quantity"] = listRequirement[j].requirement.Quantity__c;
        item["containerCode"] = listRequirement[j].containerType;
        itemMappings.push(item);
      }
    }
    component.set("v.rateMapping", itemMappings);
    component.set("v.bookingWrapper", bookingWrapper);
  },
  setBreakbulkItemsMapping: function (component, event) {
    var itemMappings = [];
    var bookingWrapper = component.get("v.bookingWrapper");
    var listFreightDetailWrappers =
      bookingWrapper.shipmentMap.BREAKBULK.listCargo[0]
        .listFreightDetailWrapper;
    var k = 1;
    for (var i in listFreightDetailWrappers) {
      var item = {};
      var additionalInfo = "";
      additionalInfo += this.setMeasurement(
        component,
        listFreightDetailWrappers[i].freightDetail.Length_Major__c,
        listFreightDetailWrappers[i].freightDetail.Length_Minor__c,
        listFreightDetailWrappers[i].measureUnit,
        "length"
      );
      additionalInfo += this.setMeasurement(
        component,
        listFreightDetailWrappers[i].freightDetail.Width_Major__c,
        listFreightDetailWrappers[i].freightDetail.Width_Minor__c,
        listFreightDetailWrappers[i].measureUnit,
        "width"
      );
      additionalInfo += this.setMeasurement(
        component,
        listFreightDetailWrappers[i].freightDetail.Height_Major__c,
        listFreightDetailWrappers[i].freightDetail.Height_Minor__c,
        listFreightDetailWrappers[i].measureUnit,
        "height"
      );

      if (listFreightDetailWrappers[i].measureUnit === "lb/ft") {
        additionalInfo +=
          ", " +
          listFreightDetailWrappers[i].freightDetail.Declared_Weight_Value__c +
          "lb";
      }
      if (listFreightDetailWrappers[i].measureUnit === "kg/m") {
        additionalInfo +=
          ", " +
          listFreightDetailWrappers[i].freightDetail.Declared_Weight_Value__c +
          "kg";
      }
      var packageType =
        listFreightDetailWrappers[i].typeOfPackage == "BOAT"
          ? "Boat on Trailer"
          : "Cargo, Not In Container";
      item["itemNum"] = k++;
      item["containerName"] = packageType + "___" + additionalInfo;
      item["quantity"] =
        listFreightDetailWrappers[i].freightDetail.Freight_Quantity__c;
      item["containerCode"] = listFreightDetailWrappers[i].typeOfPackage;
      itemMappings.push(item);
    }
    component.set("v.rateMapping", itemMappings);
  },

  setMeasurement: function (
    component,
    majorValue,
    minorValue,
    unitMajor,
    measureType
  ) {
    var measure = "";
    majorValue = majorValue == "" || majorValue == null ? 0 : majorValue;
    minorValue = minorValue == "" || minorValue == null ? 0 : minorValue;
    if (unitMajor === "kg/m") {
      if (majorValue > 0) {
        measure = majorValue + "." + minorValue + " m ";
      } else {
        measure = minorValue + " cm ";
      }
    }
    if (unitMajor === "lb/ft") {
      if (majorValue > 0) {
        measure = majorValue + "." + minorValue + " ft ";
      } else {
        measure = minorValue + " in ";
      }
    }
    if (measureType == "height") {
      return measure;
    } else {
      return measure + "x ";
    }
  },

  setVehicleItemsMapping: function (component, event) {
    var itemMappings = [];
    var bookingWrapper = component.get("v.bookingWrapper");
    var listFreightDetailWrappers =
      bookingWrapper.shipmentMap.VEHICLE.listCargo[0].listFreightDetailWrapper;
    var k = 1;
    for (var i in listFreightDetailWrappers) {
      var packageType =
        listFreightDetailWrappers[i].typeOfPackage == "PVEH"
          ? "Passenger"
          : "Commercial";
      var item = {};
      var additionalInfo = "";
      additionalInfo += this.setMeasurement(
        component,
        listFreightDetailWrappers[i].freightDetail.Length_Major__c,
        listFreightDetailWrappers[i].freightDetail.Length_Minor__c,
        listFreightDetailWrappers[i].measureUnit,
        "length"
      );
      additionalInfo += this.setMeasurement(
        component,
        listFreightDetailWrappers[i].freightDetail.Width_Major__c,
        listFreightDetailWrappers[i].freightDetail.Width_Minor__c,
        listFreightDetailWrappers[i].measureUnit,
        "width"
      );
      additionalInfo += this.setMeasurement(
        component,
        listFreightDetailWrappers[i].freightDetail.Height_Major__c,
        listFreightDetailWrappers[i].freightDetail.Height_Minor__c,
        listFreightDetailWrappers[i].measureUnit,
        "height"
      );

      if (listFreightDetailWrappers[i].measureUnit === "lb/ft") {
        additionalInfo +=
          ", " +
          listFreightDetailWrappers[i].freightDetail.Declared_Weight_Value__c +
          " lb";
      }
      if (listFreightDetailWrappers[i].measureUnit === "kg/m") {
        additionalInfo +=
          ", " +
          listFreightDetailWrappers[i].freightDetail.Declared_Weight_Value__c +
          " kg";
      }

      if (additionalInfo != "") {
        additionalInfo = " )<br/>( " + additionalInfo;
      }
      item["itemNum"] = k++;
      item["year"] = listFreightDetailWrappers[i].freightDetail.Year__c;
      item["containerName"] =
        listFreightDetailWrappers[i].freightDetail.Vehicle_Name__c +
        "___" +
        packageType +
        additionalInfo;
      item["quantity"] =
        listFreightDetailWrappers[i].freightDetail.Freight_Quantity__c;
      item["containerCode"] =
        listFreightDetailWrappers[i].freightDetail.Vehicle_Name__c;
      itemMappings.push(item);
    }
    component.set("v.rateMapping", itemMappings);
  },

  validateCargoDetails: function (component, event) {
    var cargoType = component.get("v.cargoType");
    var isvalid = true;
    var cargoDetailcmp = component.find("cargoDetailId");
    if (cargoType == "container") {
      isvalid = cargoDetailcmp.validateContainerData();
      this.setContainerItemsMapping(component, event);
    }
    if (cargoType == "breakbulk") {
      isvalid = cargoDetailcmp.validateBreakbulData();
      this.setBreakbulkItemsMapping(component, event);
    }
    if (cargoType == "vehicle") {
      isvalid = cargoDetailcmp.validateVehicleData();
      this.setVehicleItemsMapping(component, event);
    }
    return isvalid;
  },

  validateContainer: function (component, event) {
    let errors = new Set();
    var isValid = true;
    var bookingWrapper = component.get("v.bookingWrapper");
    var listFreightDetailWrappers =
      bookingWrapper.shipmentMap.CONTAINER.listCargo[0]
        .listFreightDetailWrapper;
    for (var i in listFreightDetailWrappers) {
      var listRequirement = listFreightDetailWrappers[i].listRequirementWrapper;
      for (var j in listRequirement) {
        if (listRequirement[j].containerType.length == 0) {
          errors.add("Required fields missing");
          isValid = false;
        }
        if (listRequirement[j].commodityCode.length == 0) {
          errors.add("Required fields missing");
          isValid = false;
        }
        if (!listRequirement[j].requirement.Quantity__c) {
          errors.add("Required fields missing");
          isValid = false;
        }
      }
    }
    var validationError = [];
    const iterator1 = errors.values();
    for (var i = 0; i < errors.size; i++) {
      validationError[i] = iterator1.next().value;
    }
    component.set("v.validationError", validationError);
    console.log(errors);
    return isValid;
  },
  validateBreakbulk: function (component, event) {
    let errors = new Set();
    var isValid = true;
    var bookingWrapper = component.get("v.bookingWrapper");
    var listFreightDetailWrappers =
      bookingWrapper.shipmentMap.BREAKBULK.listCargo[0]
        .listFreightDetailWrapper;
    for (var i in listFreightDetailWrappers) {
      if (listFreightDetailWrappers[i].typeOfPackage.length == 0) {
        errors.add("Required fields missing");
        isValid = false;
      }
      if (!listFreightDetailWrappers[i].freightDetail.Freight_Quantity__c) {
        errors.add("Required fields missing");
        isValid = false;
      }
      /*if(isNaN(listFreightDetailWrappers[i].freightDetail.Length_Major__c)){

            }
            if(listFreightDetailWrappers[i].freightDetail.Length_Minor__c){
                    
            }
            if(listFreightDetailWrappers[i].freightDetail.Width_Major__c){
                    
            }
            if(listFreightDetailWrappers[i].freightDetail.Width_Minor__c){
                    
            }
            if(listFreightDetailWrappers[i].freightDetail.Height_Major__c){
                    
            }
            if(listFreightDetailWrappers[i].freightDetail.Height_Minor__c){
                    
            }
            if(listFreightDetailWrappers[i].freightDetail.Length_Major__c){
                    
            }*/
    }
    var validationError = [];
    const iterator1 = errors.values();
    for (var i = 0; i < errors.size; i++) {
      validationError[i] = iterator1.next().value;
    }
    component.set("v.validationError", validationError);
    console.log(errors);
    return isValid;
  },

  validateVehicle: function (component, event) {
    let errors = new Set();
    var isValid = true;
    var bookingWrapper = component.get("v.bookingWrapper");
    var listFreightDetailWrappers =
      bookingWrapper.shipmentMap.VEHICLE.listCargo[0].listFreightDetailWrapper;
    for (var i in listFreightDetailWrappers) {
      if (listFreightDetailWrappers[i].typeOfPackage.length == 0) {
        errors.add("Required fields missing");
        isValid = false;
      }
      if (
        listFreightDetailWrappers[i].freightDetail.Manufacturer__c.length == 0
      ) {
        errors.add("Required fields missing");
        isValid = false;
      }
      if (listFreightDetailWrappers[i].freightDetail.Model__c.length == 0) {
        errors.add("Required fields missing");
        isValid = false;
      }
      if (!listFreightDetailWrappers[i].freightDetail.Freight_Quantity__c) {
        errors.add("Required fields missing");
        isValid = false;
      }
    }
    var validationError = [];
    const iterator1 = errors.values();
    for (var i = 0; i < errors.size; i++) {
      validationError[i] = iterator1.next().value;
    }
    component.set("v.validationError", validationError);
    console.log(errors);
    return isValid;
  },

  validateOriginDestination: function (component, event) {
    var originLocation = component.find("originDestinationId");
    var isValid = originLocation.validateOriginDestination();
    return isValid;
  },
  submit: function (component, event, isEmail) {
    component.set("v.isLoadingCreateQuote", true);
    var action = component.get("c.submitQuote");
    var bookingWrap = component.get("v.bookingWrapper");
    var softshipRatingResponse = component.get("v.softshipRatingResponse");
    var selectedRoutesList = component.get("v.selectedRoutesList");
    var rateMapping = component.get("v.rateMapping");
    var isSendEmail = false;
    action.setParams({
      stringWrapperRequest: JSON.stringify(bookingWrap),
      softshipRatingResponseString: JSON.stringify(softshipRatingResponse),
      selectedRoutesList: JSON.stringify(selectedRoutesList),
      rateMapping: JSON.stringify(rateMapping)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseValue = response.getReturnValue();
        component.set("v.bookingWrapper", responseValue);
        if (responseValue) {
          var quoteIds = [];
          responseValue.listQuote.map((item) => {
            var quote = {};
            quote.quoteId = item.Id;
            quote.quoteName = item.Name;
            quoteIds.push(quote);
          });
          this.updateQuoteForCaseCreation(component, event);
        }
        var sendQuoteEmailId = "";
        if (
          isEmail &&
          responseValue.listQuote &&
          responseValue.listQuote.length > 0
        ) {
          var bookingWrapper = component.get("v.bookingWrapper");
          sendQuoteEmailId = bookingWrapper.booking.Customer_Email__c;
          if (sendQuoteEmailId) {
            this.sendQuoteEmail(
              component,
              event,
              sendQuoteEmailId,
              quoteIds,
              softshipRatingResponse
            );
          }
        }
        if (component.get("v.isPostLogin")) {
          var bookingWrapper = component.get("v.bookingWrapper");
          var firstName = bookingWrapper.booking.Contact_Name__c;
          var accountName = bookingWrapper.booking.Company_Name__c;
          var contactNumber = bookingWrapper.booking.Contact_Number__c;
          var emailAddress = bookingWrapper.booking.Customer_Email__c;
          var accountLookup = bookingWrapper.booking.Account__c
            ? bookingWrapper.booking.Account__c[0]
            : null;

          component.set("v.firstName", firstName);
          component.set("v.accountName", accountName);
          component.set("v.contactNumber", contactNumber);
          component.set("v.emailAddress", emailAddress);
          component.set("v.accountLookup", accountLookup);
        }
        if (sendQuoteEmailId == "") {
          component.set("v.sendQuoteEmailId", "");
          if (
            softshipRatingResponse.success &&
            quoteIds &&
            quoteIds.length > 0
          ) {
            component.set("v.createdQuoteIds", quoteIds);
            component.set("v.isQuoteSummary", true);
          } else {
            component.set("v.createdQuoteIds", quoteIds);
            component.set("v.isQuoteSummary", false);
          }
          component.set("v.isLoadingCreateQuote", false);
        }
      } else if (state === "ERROR") {
        console.log("error");
        component.set("v.isLoadingCreateQuote", false);
      }
    });

    $A.enqueueAction(action);
  },

  sendQuoteEmail: function (
    component,
    event,
    emailAddress,
    quoteIds,
    softshipRatingResponse
  ) {
    var bookingWrapper = component.get("v.bookingWrapper");
    var action = component.get("c.sendQuoteEmail");
    action.setParams({
      emailAddress: emailAddress,
      bookingwrapper: JSON.stringify(bookingWrapper)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.sendQuoteEmailId", emailAddress);
        if (softshipRatingResponse.success && quoteIds && quoteIds.length > 0) {
          component.set("v.createdQuoteIds", quoteIds);
          component.set("v.isQuoteSummary", true);
        } else {
          component.set("v.createdQuoteIds", quoteIds);
          component.set("v.isQuoteSummary", false);
        }
        component.set("v.isLoadingCreateQuote", false);
      } else if (state === "ERROR") {
        component.set("v.isLoadingCreateQuote", false);
        console.log("error");
      }
      component.set("v.isLoadingCreateQuote", false);
    });
    $A.enqueueAction(action);
  },
  updateQuoteForCaseCreation: function (component, event) {
    var bookingWrapper = component.get("v.bookingWrapper");
    var action = component.get("c.quoteForCaseCreation");
    action.setParams({
      stringWrapperRequest: JSON.stringify(bookingWrapper)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("SUCCESS");
      } else if (state === "ERROR") {
        console.log("error");
      }
    });
    $A.enqueueAction(action);
  }
});
