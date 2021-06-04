({
  doInit: function (component, event, helper) {
    helper.getBookingWrap(component, event, "init");
    var selectedOriginLocation = helper.getURLParameter(
      "selectedOriginLocation"
    );
    if (selectedOriginLocation !== "") {
      component.set("v.selectedOriginLocation", selectedOriginLocation);
    }
    var selectedDestinationLocation = helper.getURLParameter(
      "selectedDestinationLocation"
    );
    if (selectedDestinationLocation !== "") {
      component.set(
        "v.selectedDestinationLocation",
        selectedDestinationLocation
      );
    }
    var originMove = helper.getURLParameter("originMove");
    if (originMove !== "") {
      component.set("v.originMove", originMove);
    }
    var destinationMove = helper.getURLParameter("destinationMove");
    if (destinationMove !== "") {
      component.set("v.destinationMove", destinationMove);
    }
    var searchKeywordPOL = helper.getURLParameter("searchKeywordPOL");
    if (searchKeywordPOL !== "") {
      component.set("v.searchKeywordPOL", searchKeywordPOL);
    }
    var searchKeywordPOD = helper.getURLParameter("searchKeywordPOD");
    if (searchKeywordPOD !== "") {
      component.set("v.searchKeywordPOD", searchKeywordPOD);
    }
    var clickedItemOrigin = helper.getURLParameter("clickedItemOrigin");
    if (clickedItemOrigin !== "") {
      component.set("v.clickedItemOrigin", clickedItemOrigin);
    }
    var clickedItemIdOrigin = helper.getURLParameter("clickedItemIdOrigin");
    if (clickedItemIdOrigin !== "") {
      component.set("v.clickedItemIdOrigin", clickedItemIdOrigin);
    }
    var clickedItemDestination = helper.getURLParameter(
      "clickedItemDestination"
    );
    if (clickedItemDestination !== "") {
      component.set("v.clickedItemDestination", clickedItemDestination);
    }
    var clickedItemIdDestination = helper.getURLParameter(
      "clickedItemIdDestination"
    );
    if (clickedItemIdDestination !== "") {
      component.set("v.clickedItemIdDestination", clickedItemIdDestination);
    }
    var clickedItemPol = helper.getURLParameter("clickedItemPol");
    if (clickedItemPol !== "") {
      component.set("v.clickedItemPol", clickedItemPol);
    }
    var clickedItemIdPol = helper.getURLParameter("clickedItemIdPol");
    if (clickedItemIdPol !== "") {
      component.set("v.clickedItemIdPol", clickedItemIdPol);
    }
    var clickedItemPod = helper.getURLParameter("clickedItemPod");
    if (clickedItemPod !== "") {
      component.set("v.clickedItemPod", clickedItemPod);
    }
    var clickedItemIdPod = helper.getURLParameter("clickedItemIdPod");
    if (clickedItemIdPod !== "") {
      component.set("v.clickedItemIdPod", clickedItemIdPod);
    }
    var comp = component.find("originDestinationId");
    comp.ReinitaliseData();
  },

  newQuote: function (component, event, helper) {
    helper.getBookingWrap(component, event, "newQuote");
    var originLocation = component.find("originDestinationId");
    originLocation.resetOriginDestination();
    component.set("v.currentStep", "1");
  },
  handleApplicationEvent: function (component, event, helper) {
    var actionName = event.getParam("actionName");
    if (actionName === "NewQuote") {
      helper.getBookingWrap(component, event, "newQuote");
      component.set("v.isQuoteSummary", false);
      component.set("v.currentStep", "1");
    }
  },
  moveNext: function (component, event, helper) {
    var getCurrentStep = component.get("v.currentStep");
    //need to update the if condition depending on the validation to be put on different screens
    if (getCurrentStep == "1") {
      if (helper.validateOriginDestination(component, event)) {
        component.set("v.currentStep", "2");
        component.set("v.serverError", "");
      }
    } else if (getCurrentStep == "2") {
      if (helper.validateCargoDetails(component, event)) {
        helper.callRates(component, event);
      }
    }
  },

  moveBack: function (component, event, helper) {
    var bookingWrap = component.get("v.bookingWrapper");
    bookingWrap.booking.Additional_Information__c = "";
    component.set("v.bookingWrapper", bookingWrap);
    var getCurrentStep = component.get("v.currentStep");
    component.set("v.createdQuoteIds", []);
    if (getCurrentStep == "2") {
      component.set("v.currentStep", "1");
      component.set("v.serverError", "");
    } else if (getCurrentStep == 3) {
      component.set("v.currentStep", "2");
    }
  },
  selectFromHeaderStep1: function (component, event, helper) {
    component.set("v.createdQuoteIds", []);
    component.set("v.currentStep", "1");
    component.set("v.serverError", "");
  },
  selectFromHeaderStep2: function (component, event, helper) {
    var bookingWrap = component.get("v.bookingWrapper");
    bookingWrap.booking.Additional_Information__c = "";
    component.set("v.bookingWrapper", bookingWrap);
    component.set("v.createdQuoteIds", []);
    var getCurrentStep = component.get("v.currentStep");
    if (getCurrentStep == "1") {
      if (helper.validateOriginDestination(component, event)) {
        component.set("v.currentStep", "2");
      }
    } else {
      component.set("v.currentStep", "2");
    }
  },
  selectFromHeaderStep3: function (component, event, helper) {
    var getCurrentStep = component.get("v.currentStep");
    if (getCurrentStep == "1") {
      if (helper.validateOriginDestination(component, event)) {
        component.set("v.currentStep", "2");
        if (helper.validateCargoDetails(component, event)) {
          helper.callRates(component, event);
        } else {
          component.set("v.currentStep", "2");
        }
      }
    }
    if (getCurrentStep == "2") {
      if (helper.validateCargoDetails(component, event)) {
        helper.callRates(component, event);
      }
    }
  },
  submit: function (component, event, helper) {
    helper.submit(component, event);
  },

  handleCreateQuote: function (component, event, helper) {
    helper.submit(component, event, false);
  },
  handleSendQuote: function (component, event, helper) {
    helper.submit(component, event, true);
  },
  handleRefreshCmp: function (component, event, helper) {
    var selectedItem = event.getParams()["selectedItem"];
    var selectedId = event.getParams()["selectedItemID"];
    var functionality = event.getParams()["functionality"];
    if (
      selectedId &&
      functionality &&
      functionality == "RefreshTheComponent" &&
      selectedItem.includes("Requote")
    ) {
      component.set("v.currentStep", "1");
      component.set("v.isQuoteSummary", false);
      helper.getBookingWrap(component, event, "init");
      var selectedOriginLocation = helper.getURLParameter(
        "selectedOriginLocation"
      );
      if (selectedOriginLocation !== "") {
        component.set("v.selectedOriginLocation", selectedOriginLocation);
      }
      var selectedDestinationLocation = helper.getURLParameter(
        "selectedDestinationLocation"
      );
      if (selectedOriginLocation !== "") {
        component.set(
          "v.selectedDestinationLocation",
          selectedDestinationLocation
        );
      }
      var originMove = helper.getURLParameter("originMove");
      if (selectedOriginLocation !== "") {
        component.set("v.originMove", originMove);
      }
      var destinationMove = helper.getURLParameter("destinationMove");
      if (selectedOriginLocation !== "") {
        component.set("v.destinationMove", destinationMove);
      }
      var searchKeywordPOL = helper.getURLParameter("searchKeywordPOL");
      if (searchKeywordPOL !== "") {
        component.set("v.searchKeywordPOL", searchKeywordPOL);
      }
      var searchKeywordPOD = helper.getURLParameter("searchKeywordPOD");
      if (searchKeywordPOD !== "") {
        component.set("v.searchKeywordPOD", searchKeywordPOD);
      }
    }
  }
});
