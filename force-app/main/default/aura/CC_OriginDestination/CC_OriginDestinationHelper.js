({
  doInit: function (component, event, helper) {
    var currentDate = new Date();
    var minDate = $A.localizationService.formatDate(
      currentDate.setDate(currentDate.getDate()),
      "YYYY-MM-DD"
    );
    component.set("v.minDate", minDate);
    this.initaliseOriginDestination(component, event, helper);
    this.setCrossOriginValues(component, event);
    console.log("cmp.get(bkwrp) ");
    console.log(component.get("v.bookingWrapper"));
  },
  setCrossOriginValues: function (component, event) {
    var bookingWrapper = component.get("v.bookingWrapper");
    if (
      bookingWrapper &&
      bookingWrapper.transportOrigin &&
      bookingWrapper.transportOrigin.transport &&
      bookingWrapper.transportOrigin.transport.Cross_Dock__c
    ) {
      component.set(
        "v.showCrossDockExport",
        bookingWrapper.transportOrigin.transport.Cross_Dock__c
      );
    }
    if (
      bookingWrapper &&
      bookingWrapper.transportDestination &&
      bookingWrapper.transportDestination.transport &&
      bookingWrapper.transportDestination.transport.Cross_Dock__c
    ) {
      component.set(
        "v.showCrossDockImport",
        bookingWrapper.transportOrigin.transport.Cross_Dock__c
      );
    }
  },
  getLocation: function (component, event, functionality, locationId) {
    var bookingWrapper = component.get("v.bookingWrapper");
    var action = component.get("c.fetchLocation");
    component.set("v.isLoading", true);
    action.setParams({
      recordId: locationId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var locations = response.getReturnValue();
        console.log(locations);
        if (functionality === "Quote:Origin") {
          bookingWrapper.originPort = locations[0].Port__c;
          bookingWrapper.originLocationCode = locations[0].LocationCode__c;
          bookingWrapper.booking.Origin_Drayage__c = "";
          if (locations[0].Location_Type__c == "PORT") {
            component.set("v.originMove", "P");
            this.setOriginData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Origin_Code__c = locations[0].Name;
          }
          if (locations[0].Location_Type__c == "RAIL RAMP") {
            component.set("v.originMove", "R");
            this.setOriginData(bookingWrapper.booking, locations[0]);
            //bookingWrapper.booking.Transportation_Management_System_Origin__c = 'M';
            bookingWrapper.booking.Customer_Origin_Code__c = locations[0].Name;
            this.getSubLocation(
              component,
              event,
              functionality,
              locations[0],
              bookingWrapper
            );
          }
          if (locations[0].Location_Type__c == "DOOR") {
            component.set("v.originMove", "D");
            this.setOriginData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Pickup_Location__c = "";
            bookingWrapper.booking.Customer_Origin_Zip__c = locations[0].Name;
            bookingWrapper.booking.Customer_Origin_Code__c =
              locations[0].LcCode__c;
            //bookingWrapper.booking.Customer_Origin_Country__c= locations[0].Country_Name__c;
            bookingWrapper.booking.Origin_Drayage__c = "LL";
          }
        }
        if (functionality === "Quote:Destination") {
          bookingWrapper.destinationPort = locations[0].Port__c;
          bookingWrapper.destinationLocationCode = locations[0].LocationCode__c;
          bookingWrapper.booking.Origin_Drayage__c = "";
          if (locations[0].Location_Type__c == "PORT") {
            component.set("v.destinationMove", "P");
            this.setDestinationData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].Name;
          }
          if (locations[0].Location_Type__c == "RAIL RAMP") {
            component.set("v.destinationMove", "R");
            this.setDestinationData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].Name;
            //bookingWrapper.booking.Transportation_Management_System_Destina__c = 'M';
            this.getSubLocation(
              component,
              event,
              functionality,
              locations[0],
              bookingWrapper
            );
          }
          if (locations[0].Location_Type__c == "DOOR") {
            component.set("v.destinationMove", "D");
            this.setDestinationData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].LcCode__c;
            bookingWrapper.booking.Customer_Destination_Zip__c =
              locations[0].Name;
            bookingWrapper.booking.Delivery_Location__c = "";
            //bookingWrapper.booking.Customer_Destination_Country__c= locations[0].Country_Name__c;
            bookingWrapper.booking.Destination_Drayage__c = "LL";
          }
        }
        if (functionality === "Quote:POL") {
          bookingWrapper.booking.Port_Of_Load__c = locations[0].Name;
        }
        if (functionality === "Quote:POD") {
          bookingWrapper.booking.Port_Of_Discharge__c = locations[0].Name;
        }
        var originMove = component.get("v.originMove");
        var destinationMove = component.get("v.destinationMove");
        bookingWrapper.booking.Description__c = originMove + destinationMove;
        component.set("v.bookingWrapper", bookingWrapper);
      } else {
        console.log("Error occured in In fetching Location");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  getSubLocation: function (
    component,
    event,
    functionality,
    location,
    bookingWrapper
  ) {
    component.set("v.isLoading", true);
    var action = component.get("c.fetchSubLocation");
    action.setParams({
      locCode: location.Name,
      locType: location.Location_Type__c
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var subLocations = response.getReturnValue();
        if (functionality === "Quote:Origin") {
          if (subLocations.length > 0) {
            bookingWrapper.booking.Pickup_Location__c = subLocations[0].Name;
          }
          component.set("v.originSubLocation", subLocations);
        }
        if (functionality === "Quote:Destination") {
          if (subLocations.length > 0) {
            bookingWrapper.booking.Delivery_Location__c = subLocations[0].Name;
          }

          component.set("v.destinationSubLocation", subLocations);
        }
      } else {
        console.log("Error occured in In fetching Sub Location");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  fetchContracts: function (component, event, helper, selectedAccountId) {
    component.set("v.isLoading", true);
    var action = component.get("c.fetchContractsList");
    action.setParams({
      accountId: selectedAccountId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var contracts = response.getReturnValue();
        console.log("contracts list");
        console.log(contracts);
        component.set("v.contractsList", contracts);
      } else {
        console.log("Error occured in In fetching Contracts");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  fetchCommodities: function (component, event, helper, contractId) {
    var action = component.get("c.getCommodities");
    action.setParams({
      contractId: contractId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var tariffsCommodities = response.getReturnValue();
        component.set("v.tariffsCommodities", tariffsCommodities);
        console.log(tariffsCommodities);
      } else {
        console.log("Error occured in In fetching Tariff Commodities");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  fetchCommoditiesVehicle: function (component, event, helper, contractId) {
    var action = component.get("c.getCommoditiesVehicle");
    action.setParams({
      contractId: contractId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var vehichleCommodities = response.getReturnValue();
        component.set("v.vehichleCommodities", vehichleCommodities);
        console.log(vehichleCommodities);
      } else {
        console.log("Error occured in In fetching Tariff Commodities");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  fetchEquipments: function (component, event, helper, contractId) {
    var action = component.get("c.getEquipments");
    action.setParams({
      contractId: contractId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var tariffsEquipments = response.getReturnValue();
        component.set("v.tariffsEquipments", tariffsEquipments);
        console.log(tariffsEquipments);
      } else {
        console.log("Error occured in In fetching Tariff Equipments");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
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

  setOriginData: function (booking, location) {
    booking.Customer_Origin_Code__c = location.Name;
    booking.Customer_Origin_City__c = location.City__c;
    booking.Customer_Origin_Country__c = location.Country_Code__c;
    booking.Customer_Origin_State__c = location.State__c;
    booking.Customer_Origin_Zip__c = location.ZipCode__c;
  },

  setDestinationData: function (booking, location) {
    booking.Customer_Destination_Code__c = location.Name;
    booking.Customer_Destination_City__c = location.City__c;
    booking.Customer_Destination_Country__c = location.Country_Code__c;
    booking.Customer_Destination_Zip__c = location.ZipCode__c;
    booking.Customer_Destination_State__c = location.State__c;
  },

  clearLocation: function (component, event, functionality) {
    var bookingWrapper = component.get("v.bookingWrapper");
    if (functionality === "Quote:Origin") {
      component.set("v.originMove", "");
      bookingWrapper.booking.Pickup_Location__c = "";
      bookingWrapper.booking.Customer_Origin_Code__c = "";
      bookingWrapper.booking.Transportation_Management_System_Origin__c = "";
      bookingWrapper.booking.Port_Of_Load__c = "";
      bookingWrapper.booking.Origin_Drayage__c = "";
      bookingWrapper.transportOrigin.listStop = [{}];
      bookingWrapper.originPort = "";
      bookingWrapper.originLocationCode = "";
    }
    if (functionality === "Quote:Destination") {
      component.set("v.destinationMove", "");
      bookingWrapper.booking.Customer_Destination_Code__c = "";
      bookingWrapper.booking.Delivery_Location__c = "";
      bookingWrapper.booking.Transportation_Management_System_Destina__c = "";
      bookingWrapper.booking.Port_Of_Discharge__c = "";
      bookingWrapper.booking.Destination_Drayage__c = "";
      bookingWrapper.transportDestination.listStop = [{}];
      bookingWrapper.destinationPort = "";
      bookingWrapper.destinationLocationCode = "";
    }
    if (functionality === "Quote:POL") {
      bookingWrapper.booking.Port_Of_Load__c = "";
    }
    if (functionality === "Quote:POD") {
      bookingWrapper.booking.Port_Of_Discharge__c = "";
    }
    component.set("v.showErrorMessageInRouteFinder", false);
    component.set("v.schedules", []);
    component.set("v.numberOfSchedules", 0);
    component.set("v.bookingWrapper", bookingWrapper);
  },
  getContractNameById: function (component, contractId) {
    var contractsList = component.get("v.contractsList");
    var contractName = "";
    contractsList.map((contract) => {
      if (contract.Id == contractId) {
        contractName = contract.Name;
      }
    });
    return contractName;
  },
  initaliseOriginDestination: function (component, event, helper) {
    component.set("v.isLoading", true);
    var bkWrap = component.get("v.bookingWrapper");
    if (bkWrap !== null && typeof bkWrap !== "undefined") {
      var accountName = "";
      var accountId = "";
      var contactName = "";
      var contactId = "";
      var addressName = "";
      var addressId = "";
      if (bkWrap.booking.Account__c) {
        accountId = bkWrap.booking.Account__c;
        if (bkWrap.AccountName) {
          accountName = bkWrap.AccountName;
        } else if (
          bkWrap.booking.Account__r &&
          bkWrap.booking.Account__r.Name
        ) {
          accountName = bkWrap.booking.Account__r.Name;
        }
      }
      if (bkWrap.booking.Contact__c) {
        contactId = bkWrap.booking.Contact__c;
        if (bkWrap.ContactName) {
          contactName = bkWrap.ContactName;
        } else if (
          bkWrap.booking.Contact__r &&
          bkWrap.booking.Contact__r.Name
        ) {
          contactName = bkWrap.booking.Contact__r.Name;
        }
      }
      if (bkWrap.booking.Address__c) {
        addressId = bkWrap.booking.Address__c;
        if (bkWrap.booking.Address__r && bkWrap.booking.Address__r.Name) {
          addressName = bkWrap.booking.Address__r.Name;
        }
      }
      if (accountId != "") {
        var contractId = bkWrap.booking.Contract__c;
        component.set("v.selectedAccountPolId", accountId);
        component.set("v.clickedItemIdAccount", accountId);
        component.set("v.selectedAccountPol", accountName);
        component.set("v.clickedItemAccount", accountName);

        if (component.get("v.clickedItemAccount") !== "") {
          var comp = component.find("accountId");
          comp.reInit();
          component.set("v.isLoading", false);
          bkWrap.booking.Contract__c = contractId;
        }
      }
      if (contactId != "") {
        component.set("v.selectedContactPolId", contactId);
        component.set("v.clickedItemIdContact", contactId);
        component.set("v.selectedContactPol", contactName);
        component.set("v.clickedItemContact", contactName);
        if (component.get("v.clickedItemContact") !== "") {
          var comp = component.find("contactId");
          comp.reInit();
          component.set("v.isLoading", false);
        }
      }
      if (addressId != "") {
        component.set("v.selectedAddressPolId", addressId);
        component.set("v.selectedAddressPol", addressName);
        if (component.get("v.selectedAddressPol") !== "") {
          var comp = component.find("addressId");
          comp.reInit();
          component.set("v.isLoading", false);
        }
      }
      if (bkWrap.booking.Contract__c) {
        component.set("v.selectedContractPolId", bkWrap.booking.Contract__c);
      }
      if (bkWrap.booking.Contract__r && bkWrap.booking.Contract__r.Id) {
        console.log("entered in condin");
        bkWrap.booking.Contract__c = bkWrap.booking.Contract__r.Id;
      }
      console.log(
        " bkWrap.booking.Contract__c 2222" + bkWrap.booking.Contract__c
      );
      if (bkWrap.booking.Customer_Origin_City__c) {
        this.getOriginLocationId(component, event);
      }
      if (bkWrap.booking.Customer_Destination_City__c) {
        this.getDestinationLocationId(component, event);
      }
      component.set("v.bookingWrapper", bkWrap);
    }
    component.set("v.isLoading", false);
  },
  getOriginLocationId: function (component, event) {
    component.set("v.isLoading", true);
    var action = component.get("c.fetchOriginDestinationLocation");
    var bookingWrapper = component.get("v.bookingWrapper");
    action.setParams({
      bookingWrap: JSON.stringify(bookingWrapper),
      locType: "origin"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var locations = response.getReturnValue();
        if (locations.length > 0) {
          if (locations[0].Location_Type__c == "PORT") {
            component.set("v.originMove", "P");
            this.setOriginData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Origin_Code__c = locations[0].Name;
          }
          if (locations[0].Location_Type__c == "RAIL RAMP") {
            component.set("v.originMove", "R");
            this.setOriginData(bookingWrapper.booking, locations[0]);
            //bookingWrapper.booking.Transportation_Management_System_Origin__c = 'M';
            bookingWrapper.booking.Customer_Origin_Code__c = locations[0].Name;
            var functionality = "Quote:Origin";
            this.getSubLocation(
              component,
              event,
              functionality,
              locations[0],
              bookingWrapper
            );
          }
          if (locations[0].Location_Type__c == "DOOR") {
            component.set("v.originMove", "D");
            this.setOriginData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Pickup_Location__c = "";
            bookingWrapper.booking.Customer_Origin_Zip__c = locations[0].Name;
            bookingWrapper.booking.Customer_Origin_Code__c =
              locations[0].LcCode__c;
            //bookingWrapper.booking.Customer_Origin_Country__c= locations[0].Country_Name__c;
            bookingWrapper.booking.Origin_Drayage__c = "LL";
          }
          var originSelected = "";
          if (
            locations[0].Location_Type__c === "DOOR" &&
            locations[0].Country_Name__c !== "United States"
          ) {
            originSelected =
              locations[0].Location_Type__c +
              " - " +
              locations[0].Location_Name__c;
          } else {
            originSelected =
              locations[0].Location_Type__c +
              " - " +
              locations[0].Location_Name__c +
              " (" +
              locations[0].Name +
              ")";
          }
          component.set("v.clickedItemOrigin", originSelected);
          component.set("v.clickedItemIdOrigin", locations[0].Id);
          if (component.get("v.clickedItemOrigin") !== "") {
            var comp = component.find("originId");
            comp.reInit();
          }
        }
        component.set("v.isLoading", false);
      } else {
        console.log("Error occured in fetching Origin Location");
        component.set("v.isLoading", false);
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  getDestinationLocationId: function (component, event) {
    component.set("v.isLoading", true);
    var action = component.get("c.fetchOriginDestinationLocation");
    var bookingWrapper = component.get("v.bookingWrapper");
    action.setParams({
      bookingWrap: JSON.stringify(bookingWrapper),
      locType: "destination"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var locations = response.getReturnValue();
        if (locations.length > 0) {
          if (locations[0].Location_Type__c == "PORT") {
            component.set("v.destinationMove", "P");
            this.setDestinationData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].Name;
          }
          if (locations[0].Location_Type__c == "RAIL RAMP") {
            component.set("v.destinationMove", "R");
            this.setDestinationData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].Name;
            //bookingWrapper.booking.Transportation_Management_System_Destina__c = 'M';
            var functionality = "Quote:Destination";
            this.getSubLocation(
              component,
              event,
              functionality,
              locations[0],
              bookingWrapper
            );
          }
          if (locations[0].Location_Type__c == "DOOR") {
            component.set("v.destinationMove", "D");
            this.setDestinationData(bookingWrapper.booking, locations[0]);
            bookingWrapper.booking.Customer_Destination_Code__c =
              locations[0].LcCode__c;
            bookingWrapper.booking.Customer_Destination_Zip__c =
              locations[0].Name;
            bookingWrapper.booking.Delivery_Location__c = "";
            //bookingWrapper.booking.Customer_Destination_Country__c= locations[0].Country_Name__c;
            bookingWrapper.booking.Destination_Drayage__c = "LL";
          }
          var destinationSelected = "";
          if (
            locations[0].Location_Type__c === "DOOR" &&
            locations[0].Country_Name__c !== "United States"
          ) {
            destinationSelected =
              locations[0].Location_Type__c +
              " - " +
              locations[0].Location_Name__c;
          } else {
            destinationSelected =
              locations[0].Location_Type__c +
              " - " +
              locations[0].Location_Name__c +
              " (" +
              locations[0].Name +
              ")";
          }
          component.set("v.clickedItemDestination", destinationSelected);
          component.set("v.clickedItemIdDestination", locations[0].Id);
          if (component.get("v.clickedItemDestination") !== "") {
            var comp = component.find("destinationId");
            comp.reInit();
          }
        }
        component.set("v.isLoading", false);
      } else {
        console.log("Error occured in fetching Origin Location");
        component.set("v.isLoading", false);
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  getAccountDetails: function (component, event, helper) {
    var action = component.get("c.fetchOriginDestinationLocation");
    action.setParams({
      locType: "destination"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var locations = response.getReturnValue();

        component.set("v.isLoading", false);
      } else {
        console.log("Error occured in fetching Origin Location");
        component.set("v.isLoading", false);
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  getAccount: function (component, event, helper, selectedAccountId) {
    if (
      selectedAccountId &&
      selectedAccountId != null &&
      selectedAccountId != ""
    ) {
      var action = component.get("c.fetchAccountDetails");
      action.setParams({
        accountId: selectedAccountId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var account = response.getReturnValue();
          component.set("v.account", account);
          component.set("v.selectedAccountPol", account.Name);
          component.set("v.selectedAccountPolId", account.Id);
        } else {
          console.log("Error occured in fetching Account Details");
          component.set("v.isLoading", false);
        }
        component.set("v.isLoading", false);
      });
      $A.enqueueAction(action);
    }
  },
  getAddress: function (component, event, helper, selectedAddressId) {
    if (
      selectedAddressId &&
      selectedAddressId != null &&
      selectedAddressId != ""
    ) {
      var action = component.get("c.fetchAddressDetails");
      action.setParams({
        addressId: selectedAddressId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var address = response.getReturnValue();
          component.set("v.address", address);
          component.set("v.selectedAddressPol", address.Name);
          component.set("v.selectedAddressPolId", address.Id);
        } else {
          console.log("Error occured in fetching Address Details");
          component.set("v.isLoading", false);
        }
        component.set("v.isLoading", false);
      });
      $A.enqueueAction(action);
    }
  },
  getContact: function (component, event, helper, selectedContactId) {
    if (
      selectedContactId &&
      selectedContactId != null &&
      selectedContactId != ""
    ) {
      var action = component.get("c.fetchContactDetails");
      action.setParams({
        contactId: selectedContactId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var contact = response.getReturnValue();
          component.set("v.contact", contact);
          component.set("v.selectedContactPol", contact.Name);
          component.set("v.selectedContactPolId", contact.Id);
        } else {
          console.log("Error occured in fetching Contact Details");
          component.set("v.isLoading", false);
        }
        component.set("v.isLoading", false);
      });
      $A.enqueueAction(action);
    }
  }
});
