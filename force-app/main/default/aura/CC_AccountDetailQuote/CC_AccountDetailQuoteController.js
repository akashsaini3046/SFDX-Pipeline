({
  doInit: function (component, event, helper) {
    component.set("v.showLoadingSpinner", true);
    helper.getMetaData(component, event, helper);
    helper.getQuoteData(component, event, helper);
    helper.fetchTotalQuotes(component, event, helper, true);
  },
  handlePaginationEvent: function (component, event, helper) {
    var params = event.getParams();
    component.set("v.startRange", params["startRange"]);
    component.set("v.showRecords", params["showRecords"]);
    helper.getQuoteData(
      component,
      event,
      helper,
      params["offset"],
      params["limit"]
    );
  },
  handleAccountClick: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idAccount = event.currentTarget.id;
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "accountDetail"
      },
      state: {
        id: idAccount
      }
    };
    navService.navigate(pageReference);
  },
  handleFilterEvent: function (component, event, helper) {
    var params = event.getParams();
    console.log(params);
    component.set("v.selectedAccountId", params["selectedAccountId"]);
    component.set("v.selectedContractId", params["selectedContractId"]);
    component.set("v.departureFromDate", params["departureFromDate"]);
    component.set("v.departureToDate", params["departureToDate"]);
    component.set("v.showChildAcc", params["showChildAcc"]);
    component.set("v.statusSelected", params["statusSelected"]);
    component.set("v.hazQuote", params["hazQuote"]);
    component.set("v.comoditySelected", params["comoditySelected"]);
    component.set("v.vessalSelected", params["vessalSelected"]);
    component.set("v.selectedContractId", params["selectedContractId"]);
    component.set("v.originLocationId", params["originLocationId"]);
    component.set("v.destinationLocationId", params["destinationLocationId"]);
    component.set("v.originMovementType", params["originMovementType"]);
    component.set("v.destMovementType", params["destMovementType"]);
    component.set("v.containerTypeSelected", params["containerTypeSelected"]);
    component.set("v.contractInput", params["contractInput"]);
    component.set("v.startRange", 1);
    helper.getQuoteData(component, event, helper, 0, null);
    helper.fetchTotalQuotes(component, event, helper);
  },
  handleSearchList: function (component, event, helper) {
    var params = event.getParams();
    var searchKeyWord = params["searchKeyWord"];
    component.set("v.searchKeyWord", searchKeyWord);
    console.log("searchKeyWord", searchKeyWord);
    helper.getQuoteData(component, event, helper);
    helper.fetchTotalQuotes(component, event, helper);
  }
});
