({
  searchHelper: function (component, event, getInputkeyWord) {
    var functionality = component.get("v.functionality");
    var searchlen = getInputkeyWord.length;
    if (this.checkSearchLength(searchlen, functionality)) {
      if (functionality === "AccountDetailFilter:ChildAcc") {
        this.findAccounts(component, event, getInputkeyWord);
      }
      if (functionality === "AccountFilter:AccountName") {
        this.findAccounts(component, event, getInputkeyWord);
      }
      if (functionality === "AccountFilter:ParentAccountName") {
        this.findParentAccounts(component, event, getInputkeyWord);
      }
      if (functionality === "AccountDetailFilter:Contract") {
        this.findAccounts(component, event, getInputkeyWord);
      }
      if (
        functionality === "BookingListFilter:Account" ||
        functionality === "QuoteListFilter:Account"
      ) {
        this.findAccountsBooking(component, event, getInputkeyWord);
      }
      if (functionality === "BookingListFilter:Contract") {
        this.findContractsBooking(component, event, getInputkeyWord);
      }
      if (
        functionality === "BookingListFilter:Origin" ||
        functionality === "QuoteListFilter:Origin"
      ) {
        this.findDoorOrPortBooking(component, event, getInputkeyWord);
        component.set("v.displayType", "half-comb");
      }
      if (
        functionality === "BookingListFilter:Destination" ||
        functionality === "QuoteListFilter:Destination"
      ) {
        this.findDoorOrPortBooking(component, event, getInputkeyWord);
        component.set("v.displayType", "half-comb");
      }
      if (functionality === "QuoteListFilter:Contract") {
        this.findContracts(component, event, getInputkeyWord);
      }
      if (
        functionality === "RouteFinder:Origin" ||
        functionality === "RouteFinder:Destination" ||
        functionality === "Quote:Origin" ||
        functionality === "Quote:Destination"
      ) {
        this.findRouteOriginDestination(component, event, getInputkeyWord);
        component.set("v.displayType", "Combine");
      }
      if (functionality === "Quote:POL" || functionality === "Quote:POD") {
        this.findPOLandPOD(component, event, getInputkeyWord);
        component.set("v.displayType", "Combine");
      }
      if (functionality === "Container:Size_Type") {
        this.container(component, event, getInputkeyWord);
        component.set("v.displayType", "Description");
      }
      if (
        functionality === "Quote:PostLoginAccount" ||
        functionality === "Booking:PostLoginAccount" ||
        functionality === "Party:PostLoginAccount"
      ) {
        this.findAccounts(component, event, getInputkeyWord);
      }
      if (
        functionality === "Quote:PostLoginContact" ||
        functionality === "Booking:PostLoginContact" ||
        functionality === "Party:PostLoginContact"
      ) {
        this.findContacts(component, event, getInputkeyWord);
      }
      if (
        functionality === "Booking:BusinessLocation" ||
        functionality === "Consignee:BusinessLocation" ||
        functionality === "Party:BusinessLocation"
      ) {
        this.findBusinessLocations(component, event, getInputkeyWord);
      }
      if (functionality === "Booking:BusinessLocationAccountDependent") {
        this.findBusinessLocationsByAccount(component, event, getInputkeyWord);
      }
      if (functionality === "Booking:ContactAccountDependent") {
        this.findContactsByAccount(component, event, getInputkeyWord);
      }
      if (functionality === "BOLListFilter:Account") {
        this.findBOLAccounts(component, event, getInputkeyWord);
      }
      if (functionality === "BOLListFilter:Booking") {
        this.findBOLBookings(component, event, getInputkeyWord);
      }
      if (
        functionality === "BOLListFilter:LoadPort" ||
        functionality === "BOLEdit:LoadPort"
      ) {
        this.findPOLandPOD(component, event, getInputkeyWord);
        component.set("v.displayType", "half-comb");
      }
      if (functionality === "BOLEdit:Location") {
        this.findBOLLocation(component, event, getInputkeyWord);
        component.set("v.displayType", "Combine");
      }
      if (functionality === "BOLEdit:VesselName") {
        this.findVesselName(component, event, getInputkeyWord);
        component.set("v.displayType", "Combine");
      }
      if (functionality === "Combo:Account") {
        this.findAccountsCombo(component, event, getInputkeyWord);
      }
      if (functionality === "Combo:Address") {
        this.findAddressesCombo(component, event, getInputkeyWord);
      }
      if (functionality === "Combo:Contact") {
        this.findContactsCombo(component, event, getInputkeyWord);
      }
      if (functionality === "BOL:hts") {
        this.findHts(component, event, getInputkeyWord);
      }
      if (functionality === "Idea:AssignedTo") {
        this.findUsers(component, event, getInputkeyWord);
        component.set("v.displayType", "fullName");
      }
    } else {
      component.set("v.Message", "Keep typing... Type some more characters");
      component.set("v.showmessageDialog", true);
      component.set("v.loading", false);
      component.set("v.listOfSearchRecords", null);
      component.set("v.clickedItem", "");
      component.set("v.clickedItemId", "");
    }
  },
  findHts: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchHts");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The HTS you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  setWarningMessage: function (component, event, helper) {
    let oldValue = component.get("v.oldValue");
    let message = "Booking value in record:<br/><b>";
    if ($A.util.isEmpty(oldValue)) {
      message += "&quot;is blank&quot;";
    } else {
      message += oldValue;
    }
    message +=
      "</b><br/><br/>The value entered is different than that in Booking. You can change it back by clicking on this &quot;<b>Reset</b>&quot;";
    component.set("v.warningMessage", message);
  },
  warningChangeHandler: function (component, event) {
    let cmp = component.find("inputSearch");
    let isWarnedInput = $A.util.hasClass(cmp, "warninginput");
    let oldValue = component.get("v.oldValue");
    let currValue = component.get("v.SearchKeyWord");
    if ($A.util.isEmpty(oldValue)) {
      oldValue = "";
    }
    if ($A.util.isEmpty(currValue)) {
      currValue = "";
    }
    if (currValue != oldValue) {
      if (isWarnedInput == false) {
        $A.util.addClass(cmp, "warninginput");
      }
      component.set("v.showWarning", true);
    } else {
      if (isWarnedInput == true) {
        $A.util.removeClass(cmp, "warninginput");
      }
      component.set("v.showWarning", false);
    }
    this.warningEvent(component, event);
  },
  warningEvent: function (component, event) {
    var compEvent = component.getEvent("WarningInputChanged");
    compEvent.setParams({
      Id: component.getGlobalId(),
      isWarned: component.get("v.showWarning")
    });
    compEvent.fire();
  },
  checkSearchLength: function (searchlen, functionality) {
    if (functionality === "AccountDetailFilter:ChildAcc" && searchlen > 2) {
      return true;
    }
    if (functionality === "AccountDetailFilter:Contract" && searchlen > 2) {
      return true;
    }
    if (
      (functionality === "BookingListFilter:Account" && searchlen > 2) ||
      (functionality === "QuoteListFilter:Account" && searchlen > 2)
    ) {
      return true;
    }
    if (
      functionality === "BookingListFilter:Contract" ||
      functionality === "QuoteListFilter:Contract"
    ) {
      return true;
    }
    if (
      functionality === "BookingListFilter:Origin" ||
      functionality === "QuoteListFilter:Origin"
    ) {
      return true;
    }
    if (functionality === "AccountFilter:AccountName" && searchlen > 2) {
      return true;
    }
    if (functionality === "AccountFilter:ParentAccountName" && searchlen > 2) {
      return true;
    }
    if (
      functionality === "BookingListFilter:Destination" ||
      functionality === "QuoteListFilter:Destination"
    ) {
      return true;
    }
    if (
      (functionality === "RouteFinder:Origin" ||
        functionality === "RouteFinder:Destination" ||
        functionality === "Quote:Origin" ||
        functionality === "Quote:Destination") &&
      searchlen > 2
    ) {
      return true;
    }
    if (
      (functionality === "Quote:POL" ||
        functionality === "Quote:POD" ||
        functionality === "Container:Size_Type") &&
      searchlen > 1
    ) {
      return true;
    }
    if (
      (functionality === "Quote:PostLoginAccount" ||
        functionality === "Quote:PostLoginContact" ||
        functionality === "Booking:PostLoginAccount" ||
        functionality === "Booking:PostLoginContact" ||
        functionality === "Party:PostLoginAccount") &&
      searchlen > 2
    ) {
      return true;
    }
    if (
      (functionality === "Booking:PostLoginAccount" ||
        functionality === "Quote:PostLoginContact" ||
        functionality === "Booking:PostLoginAccount" ||
        functionality === "Booking:PostLoginContact" ||
        functionality === "Party:PostLoginContact") &&
      searchlen > 2
    ) {
      return true;
    }
    if (
      (functionality === "Booking:BusinessLocation" ||
        functionality === "Consignee:BusinessLocation" ||
        functionality === "Party:BusinessLocation") &&
      searchlen > 2
    ) {
      return true;
    }
    if (
      (functionality === "Booking:BusinessLocationAccountDependent" ||
        functionality === "Booking:ContactAccountDependent") &&
      searchlen > 2
    ) {
      return true;
    }
    if (functionality === "BOLListFilter:Account" && searchlen > 2) {
      return true;
    }
    if (functionality === "BOLListFilter:Booking" && searchlen > 2) {
      return true;
    }
    if (
      (functionality === "BOLListFilter:LoadPort" ||
        functionality === "BOLEdit:LoadPort") &&
      searchlen > 2
    ) {
      return true;
    }
    if (functionality === "BOL:hts" && searchlen > 2) {
      return true;
    }
    if (functionality === "BOLEdit:Location" && searchlen > 2) {
      return true;
    }
    if (functionality === "BOLEdit:VesselName" && searchlen > 2) {
      return true;
    }
    if (functionality === "Combo:Account" && searchlen > 2) {
      return true;
    }
    if (functionality === "Combo:Address" && searchlen > 2) {
      return true;
    }
    if (functionality === "Combo:Contact" && searchlen > 2) {
      return true;
    }
    if (functionality === "Idea:AssignedTo" && searchlen > 2) {
      return true;
    }
  },
  findAccounts: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchAccounts");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Account you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        responseData = this.hasCreateProspect(component, responseData);
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findParentAccounts: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchParentAccounts");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Account you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findContacts: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchContacts");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Contact you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        responseData = this.hasCreateContact(component, responseData);
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findAccountsBooking: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchAccountsBooking");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Account you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findContractsBooking: function (component, event, getInputkeyWord) {
    var selectedAccountId = component.get("v.dependentId");
    if (selectedAccountId) {
      var action = component.get("c.fetchContractsBooking");
      action.setParams({
        searchKeyWord: getInputkeyWord,
        accountId: selectedAccountId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseData = response.getReturnValue();
          if (responseData.length == 0) {
            component.set("v.resultMessage", "No Results Found.");
            component.set(
              "v.Message",
              "The Contract you are searching for is unavailable."
            );
            component.set("v.showmessageDialog", true);
          } else {
            component.set("v.resultMessage", "Search Result...");
            component.set("v.showmessageDialog", false);
          }
          component.set("v.listOfSearchRecords", responseData);
        } else if (state === "ERROR") {
          console.log("Error in fetching Accounts !");
        }
        component.set("v.loading", false);
      });
      $A.enqueueAction(action);
    }
  },
  findDoorOrPortBooking: function (component, event, getInputkeyWord) {
    var originOrDestination = component.get("v.dependentId");
    var action = component.get("c.fetchDoorOrPort");
    action.setParams({
      searchKeyWord: getInputkeyWord,
      originOrDestination: originOrDestination
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Location you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },

  findRouteOriginDestination: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchOriginDestination");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Location you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findPOLandPOD: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchLoadPortDestinationPort");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Location you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findBOLLocation: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchBOLLocation");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Location you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findVesselName: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchVesselName");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Location you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  container: function (component, event, getInputkeyWord) {
    var action = component.get("c.getContainer");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        this.setResult(component, responseData, "Container");
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findContracts: function (component, event, getInputkeyWord) {
    var action = component.get("c.getContracts");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        this.setResult(component, responseData, "Contract");
        component.set("v.displayType", "Contract");
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  setResult: function (component, responseData, searchType) {
    if (responseData.length == 0) {
      component.set("v.resultMessage", "No Results Found.");
      component.set(
        "v.Message",
        searchType + " you are searching for is unavailable."
      );
      component.set("v.showmessageDialog", true);
    } else {
      component.set("v.resultMessage", "Search Result...");
      component.set("v.showmessageDialog", false);
    }
    component.set("v.listOfSearchRecords", responseData);
  },
  findBOLAccounts: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchBOLAccounts");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        this.setResult(component, responseData, "Account");
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findBOLBookings: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchBOLBookings");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        this.setResult(component, responseData, "Booking");
      } else if (state === "ERROR") {
        console.log("Error in fetching Bookings !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findBOLCreatedBy: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchBOLCreatedByUsers");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        this.setResult(component, responseData, "User");
      } else if (state === "ERROR") {
        console.log("Error in fetching Users !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findAccountsCombo: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchAccountsCombo");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Account you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        responseData = this.hasCreateProspect(component, responseData);
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findAddressesCombo: function (component, event, getInputkeyWord) {
    var selectedAccountId = component.get("v.dependentId");
    if (selectedAccountId) {
      var action = component.get("c.fetchAddressesCombo");
      action.setParams({
        searchKeyWord: getInputkeyWord,
        accountId: selectedAccountId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseData = response.getReturnValue();
          if (responseData.length == 0) {
            component.set("v.resultMessage", "No Results Found.");
            component.set(
              "v.Message",
              "The Address you are searching for is unavailable for this account."
            );
            component.set("v.showmessageDialog", true);
          } else {
            component.set("v.resultMessage", "Search Result...");
            component.set("v.showmessageDialog", false);
          }
          responseData = this.hasCreateAddress(component, responseData);
          component.set("v.listOfSearchRecords", responseData);
        } else if (state === "ERROR") {
          console.log("Error in fetching Accounts !");
        }
        component.set("v.loading", false);
      });
      $A.enqueueAction(action);
    }
  },
  findContactsCombo: function (component, event, getInputkeyWord) {
    var selectedAccountId = component.get("v.dependentId");
    if (selectedAccountId) {
      var action = component.get("c.fetchContactsCombo");
      action.setParams({
        searchKeyWord: getInputkeyWord,
        accountId: selectedAccountId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseData = response.getReturnValue();
          if (responseData.length == 0) {
            component.set("v.resultMessage", "No Results Found.");
            component.set(
              "v.Message",
              "The Contacts you are searching for is unavailable for this account."
            );
            component.set("v.showmessageDialog", true);
          } else {
            component.set("v.resultMessage", "Search Result...");
            component.set("v.showmessageDialog", false);
          }
          responseData = this.hasCreateContact(component, responseData);
          component.set("v.listOfSearchRecords", responseData);
        } else if (state === "ERROR") {
          console.log("Error in fetching Accounts !");
        }
        component.set("v.loading", false);
      });
      $A.enqueueAction(action);
    }
  },
  findBusinessLocations: function (component, event, getInputkeyWord) {
    var action = component.get("c.fetchBusinessLocations");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Address you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        responseData = this.hasCreateAddress(component, responseData);
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Accounts !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  findBusinessLocationsByAccount: function (component, event, getInputkeyWord) {
    var selectedAccountId = component.get("v.dependentId");
    if (selectedAccountId) {
      var action = component.get("c.fetchBusinessLocationsByAccount");
      action.setParams({
        searchKeyWord: getInputkeyWord,
        accountId: selectedAccountId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseData = response.getReturnValue();
          if (responseData.length == 0) {
            component.set("v.resultMessage", "No Results Found.");
            component.set(
              "v.Message",
              "The Address you are searching for is unavailable for this account."
            );
            component.set("v.showmessageDialog", true);
          } else {
            component.set("v.resultMessage", "Search Result...");
            component.set("v.showmessageDialog", false);
          }
          responseData = this.hasCreateAddress(component, responseData);
          component.set("v.listOfSearchRecords", responseData);
        } else if (state === "ERROR") {
          console.log("Error in fetching Business Locations !");
        }
        component.set("v.loading", false);
      });
      $A.enqueueAction(action);
    }
  },
  findContactsByAccount: function (component, event, getInputkeyWord) {
    var selectedAccountId = component.get("v.dependentId");
    if (selectedAccountId) {
      var action = component.get("c.fetchContactsByAccount");
      action.setParams({
        searchKeyWord: getInputkeyWord,
        accountId: selectedAccountId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseData = response.getReturnValue();
          if (responseData.length == 0) {
            component.set("v.resultMessage", "No Results Found.");
            component.set(
              "v.Message",
              "The Contact you are searching for is unavailable for this account."
            );
            component.set("v.showmessageDialog", true);
          } else {
            component.set("v.resultMessage", "Search Result...");
            component.set("v.showmessageDialog", false);
          }
          responseData = this.hasCreateContact(component, responseData);
          component.set("v.listOfSearchRecords", responseData);
        } else if (state === "ERROR") {
          console.log("Error in fetching Contacts !");
        }
        component.set("v.loading", false);
      });
      $A.enqueueAction(action);
    }
  },
  hasCreateProspect: function (component, responseData) {
    var hasCreateProspectButton = component.get("v.hasCreateProspectButton");
    if (hasCreateProspectButton) {
      var item = {};
      item.Id = "CreateProspectButton";
      item.Name = "Create New Prospect";
      item.displayType = "Button";
      responseData.push(item);
    }
    return responseData;
  },
  hasCreateAddress: function (component, responseData) {
    var hasCreateAddressButton = component.get("v.hasCreateAddressButton");
    if (hasCreateAddressButton) {
      var item = {};
      item.Id = "CreateAddressButton";
      item.Name = "Create New Address";
      item.displayType = "Button";
      responseData.push(item);
    }
    return responseData;
  },
  hasCreateContact: function (component, responseData) {
    var hasCreateContactButton = component.get("v.hasCreateContactButton");
    if (hasCreateContactButton) {
      var item = {};
      item.Id = "CreateContactButton";
      item.Name = "Create New Contact";
      item.displayType = "Button";
      responseData.push(item);
    }
    return responseData;
  },
  hasCreateProspect: function (component, responseData) {
    var hasCreateProspectButton = component.get("v.hasCreateProspectButton");
    var createAccountButtonLabel = component.get("v.createAccountButtonLabel");
    if (!(createAccountButtonLabel && createAccountButtonLabel != "")) {
      createAccountButtonLabel = "Create New Prospect";
    }
    if (hasCreateProspectButton) {
      var item = {};
      item.Id = "CreateProspectButton";
      item.Name = createAccountButtonLabel;
      item.displayType = "Button";
      responseData.push(item);
    }
    return responseData;
  },

  hasCreateAddress: function (component, responseData) {
    var hasCreateAddressButton = component.get("v.hasCreateAddressButton");
    var createAddressButtonLabel = component.get("v.createAddressButtonLabel");
    if (!(createAddressButtonLabel && createAddressButtonLabel != "")) {
      createAddressButtonLabel = "Create New Address";
    }
    if (hasCreateAddressButton) {
      var item = {};
      item.Id = "CreateAddressButton";
      item.Name = createAddressButtonLabel;
      item.displayType = "Button";
      responseData.push(item);
    }
    return responseData;
  },

  hasCreateContact: function (component, responseData) {
    var hasCreateContactButton = component.get("v.hasCreateContactButton");
    var createContactButtonLabel = component.get("v.createContactButtonLabel");
    if (!(createContactButtonLabel && createContactButtonLabel != "")) {
      createContactButtonLabel = "Create New Contact";
    }
    if (hasCreateContactButton) {
      var item = {};
      item.Id = "CreateContactButton";
      item.Name = createContactButtonLabel;
      item.displayType = "Button";
      responseData.push(item);
    }
    return responseData;
  },
  handleCreateProspect: function (component, event, helper) {
    component.set("v.showCreateProspect", true);
    component.set("v.clickedItem", "");
    component.set("v.clickedItemId", "");
  },
  handleCreateAddress: function (component, event, helper) {
    component.set("v.showCreateAddress", true);
    component.set("v.clickedItem", "");
    component.set("v.clickedItemId", "");
  },
  handleCreateContact: function (component, event, helper) {
    component.set("v.showCreateContact", true);
    component.set("v.clickedItem", "");
    component.set("v.clickedItemId", "");
  },
  findUsers: function (component, event, getInputkeyWord) {
    console.log("findUsers");
    var action = component.get("c.fetchUsers");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        console.log(responseData);
        this.setResult(component, responseData, "User");
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  }
});
