({
  modifyData: function (component, event, helper) {
    console.log("QuoteData", component.get("v.data"));
    var data = component.get("v.data");
    var modifiedData = [];
    data.map((item) => {
      var modItem = item;
      if (modItem.quote.Description__c) {
        modItem.quote.movementType = this.handleDescription(
          modItem.quote.Description__c
        );
        modItem.quote.locations = this.handleLocations(
          modItem,
          modItem.quote.movementType
        );
      }
      if (modItem.quote.Transit_Time_Day_Hours__c) {
        modItem.quote.transDays = this.handleTransitDays(
          modItem.quote.Transit_Time_Day_Hours__c
        );
      }
      if (modItem.quote.Valid_To__c) {
        modItem.quote.dateOfDischarge = this.handleDates(
          modItem.quote.Valid_To__c
        );
      }
      if (modItem.quote.Grand_Total_Amount__c) {
        modItem.quote.Price = this.handleAmount(
          modItem.quote.Grand_Total_Amount__c
        );
      } else {
        modItem.quote.Price = "NA";
      }
      if (modItem.quote.Contract_Number__c) {
        modItem.quote.ContractName = this.handleContractName(
          modItem.quote.Contract_Number__c
        );
      } else {
        modItem.quote.ContractName = " NA";
      }
      if (modItem.freightdetails) {
        if (modItem.requirements) {
          modItem.quote.commodityName = this.handlerequirementsCommodityName(
            modItem.requirements
          );
        } else {
          modItem.quote.commodityName = this.handlefreightdetailsCommodityName(
            modItem.freightdetails
          );
        }
      }
      if (modItem.quote.No_of_Stop__c) {
        modItem.quote.noOfStops = this.handleStops(modItem.quote.No_of_Stop__c);
      }
      if (modItem.quote.Vessel_Name__c) {
        modItem.quote.vesselName = this.handleVesselName(
          modItem.quote.Vessel_Name__c
        );
      } else {
        modItem.quote.vesselName = "TBN";
      }
      if (modItem.quote.Voyage_Number__c) {
        modItem.quote.voyageNumber = this.handleVoyageNumber(
          modItem.quote.Voyage_Number__c
        );
      } else {
        modItem.quote.voyageNumber = "TBN";
      }
      if (modItem.quote.Quote_Type__c) {
        modItem.quote.quoteType = this.checkValue(modItem.quote.Quote_Type__c);
      }
      modifiedData.push(modItem);
    });
    component.set("v.modifiedData", modifiedData);
  },
  handleDates: function (dates) {
    return $A.localizationService.formatDate(dates, "MMM dd, yyyy");
  },
  handleDescription: function (description) {
    var movementType = {};
    if (description.startsWith("D")) {
      movementType.originType = "Door";
    }
    if (description.startsWith("P")) {
      movementType.originType = "Port";
    }
    if (description.startsWith("R")) {
      movementType.originType = "Rail Ramp";
    }
    if (description.endsWith("D")) {
      movementType.destinationType = "Door";
    }
    if (description.endsWith("P")) {
      movementType.destinationType = "Port";
    }
    if (description.endsWith("R")) {
      movementType.destinationType = "Rail Ramp";
    }
    return movementType;
  },
  handleContractName: function (name) {
    if (name) {
      return " " + name;
    } else {
      return " NA";
    }
  },
  handleAmount: function (amount) {
    if (amount) {
      var formatter = new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD"
      });
      return formatter.format(amount);
    } else {
      return "NA";
    }
  },
  handleTransitDays: function (transDays) {
    if (transDays) {
      return " (" + transDays.toString() + ")";
    } else {
      return "";
    }
  },
  handleStops: function (noofStops) {
    if (
      noofStops !== null &&
      noofStops.toString() !== "0" &&
      noofStops.toString() !== "1" &&
      typeof noofStops !== "undefined"
    ) {
      return noofStops + " Stops ";
    } else if (
      noofStops !== null &&
      noofStops.toString() === "0" &&
      typeof noofStops !== "undefined"
    ) {
      return "NonStop ";
    } else if (
      noofStops !== null &&
      noofStops.toString() === "1" &&
      typeof noofStops !== "undefined"
    ) {
      return noofStops + " Stop ";
    } else {
      return "";
    }
  },
  handleVesselName: function (vesselName) {
    if (
      vesselName !== null &&
      vesselName.toString() !== "TBN" &&
      typeof vesselName !== "undefined"
    ) {
      return vesselName;
    } else {
      return "TBN";
    }
  },
  handleVoyageNumber: function (voyageNumber) {
    if (
      voyageNumber !== null &&
      voyageNumber.toString() !== "TBN" &&
      typeof voyageNumber !== "undefined"
    ) {
      return voyageNumber;
    } else {
      return "TBN";
    }
  },
  handleLocations: function (item, movementType) {
    var locations = {};
    if (
      movementType.originType == "Door" ||
      movementType.originType == "Port" ||
      movementType.originType == "Rail Ramp"
    ) {
      if (movementType.originType == "Door") {
        locations.originCode = this.checkValue(
          item.quote.Customer_Origin_Zip__c
        );
      } else if (
        movementType.originType == "Port" ||
        movementType.originType == "Rail Ramp"
      ) {
        locations.originCode = this.checkValue(
          item.quote.Customer_Origin_Code__c
        );
      }
      if (item.quote.Customer_Origin_Country__c == "US") {
        locations.originName =
          this.checkValue(item.quote.Customer_Origin_City__c) +
          ", " +
          this.checkValue(item.quote.Customer_Origin_State__c);
      } else {
        if (movementType.originType == "Door") {
          locations.originName =
            this.checkValue(item.quote.Customer_Origin_City__c) +
            ", " +
            this.checkStateValue(item.quote.Customer_Origin_State__c) +
            this.checkValue(item.quote.Customer_Origin_Country__c);
        } else if (
          movementType.originType == "Port" ||
          movementType.originType == "Rail Ramp"
        ) {
          locations.originName =
            this.checkValue(item.quote.Customer_Origin_City__c) +
            ", " +
            this.checkValue(item.quote.Customer_Origin_Country__c);
        }
      }
    }
    if (
      movementType.destinationType == "Door" ||
      movementType.destinationType == "Port" ||
      movementType.destinationType == "Rail Ramp"
    ) {
      if (movementType.destinationType == "Door") {
        locations.destinationCode = this.checkValue(
          item.quote.Customer_Destination_Zip__c
        );
      } else if (
        movementType.destinationType == "Port" ||
        movementType.destinationType == "Rail Ramp"
      ) {
        locations.destinationCode = this.checkValue(
          item.quote.Customer_Destination_Code__c
        );
      }
      if (item.quote.Customer_Destination_Country__c == "US") {
        locations.destinationName =
          this.checkValue(item.quote.Customer_Destination_City__c) +
          ", " +
          this.checkValue(item.quote.Customer_Destination_State__c);
      } else {
        if (movementType.destinationType == "Door") {
          locations.destinationName =
            this.checkValue(item.quote.Customer_Destination_City__c) +
            ", " +
            this.checkStateValue(item.quote.Customer_Destination_State__c) +
            this.checkValue(item.quote.Customer_Destination_Country__c);
        } else if (
          movementType.destinationType == "Port" ||
          movementType.destinationType == "Rail Ramp"
        ) {
          locations.destinationName =
            this.checkValue(item.quote.Customer_Destination_City__c) +
            ", " +
            this.checkValue(item.quote.Customer_Destination_Country__c);
        }
      }
    }
    return locations;
  },
  handlerequirementsCommodityName: function (requirements) {
    return this.checkFieldValue(requirements, "Commodity_Name__c");
  },
  handlefreightdetailsCommodityName: function (freightdetails) {
    return this.checkFieldValue(freightdetails, "Commodity_Name__c");
  },
  checkValue: function (value) {
    if (value) {
      return value;
    } else {
      return "";
    }
  },
  checkStateValue: function (value) {
    if (value) {
      return value + " , ";
    } else {
      return "";
    }
  },
  checkFieldValue: function (value, field) {
    if (value && value.length > 0 && value[0] && value[0][field]) {
      if (value.length > 1) {
        return value[0][field] + ".. & more";
      } else {
        return value[0][field];
      }
    } else {
      return "";
    }
  },
  fetchURL: function (component, event, helper) {
    var quoteId = component.get("v.recordId");
    var action = component.get("c.fetchIframeUrl");
    action.setParams({
      QuoteId: quoteId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("response.getReturnValue()", response.getReturnValue());
        component.set("v.downloadURL", response.getReturnValue());
        this.download(component, event);
        component.set("v.downloadFile", "true");
      } else if (state === "ERROR") {
        console.log("error");
        let errors = response.getError();
        let message = "";
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        console.error(message);
      }
    });
    $A.enqueueAction(action);
  },
  handleReQuoteClick: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idQuote = component.get("v.recordId");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "get-a-quote"
      },
      state: {
        id: idQuote
      }
    };
    navService.navigate(pageReference);
  },
  handleBookClick: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idQuote = component.get("v.recordId");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "create-booking"
      },
      state: {
        qId: idQuote
      }
    };
    navService.navigate(pageReference);
  },
  download: function (component, event, helper) {
    var nameQuote = component.get("v.quoteName");
    var source = component.get("v.downloadURL");
    var hiddenElement = document.createElement("a");
    hiddenElement.href = source;
    hiddenElement.target = "_self"; //
    hiddenElement.download = nameQuote; // CSV file Name* you can change it.[only name not .csv]
    document.body.appendChild(hiddenElement); // Required for FireFox browser
    hiddenElement.click(); // using click() js function to download csv file
  }
});
