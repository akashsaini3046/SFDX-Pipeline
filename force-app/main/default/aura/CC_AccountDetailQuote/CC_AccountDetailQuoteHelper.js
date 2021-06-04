({
  getMetaData: function (component, event, helper) {
    component.set("v.showLoadingSpinner", true);
    var getMetaDataAction = component.get("c.getQuoteMetaData");
    getMetaDataAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var wrapper = response.getReturnValue();
        if (wrapper.statuses) {
          component.set("v.statuses", this.sortByLabel(wrapper.statuses));
        }
        if (wrapper.originMovementTypes) {
          component.set(
            "v.originMovementTypes",
            this.sortByLabel(wrapper.originMovementTypes)
          );
        }
        if (wrapper.destMovementTypes) {
          component.set(
            "v.destMovementTypes",
            this.sortByLabel(wrapper.destMovementTypes)
          );
        }
        if (wrapper.containerTypes) {
          component.set(
            "v.containerTypes",
            this.sortByLabel(wrapper.containerTypes)
          );
        }
        if (wrapper.commodities) {
          component.set("v.commodities", wrapper.commodities);
        }
        if (wrapper.vessals) {
          component.set("v.vessals", this.sortByLabel(wrapper.vessals));
        }
        component.set("v.showLoadingSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
            component.set("v.showLoadingSpinner", false);
          }
        } else {
          console.log("Unknown error");
          component.set("v.showLoadingSpinner", false);
        }
      }
      component.set("v.showLoadingSpinner", false);
    });
    $A.enqueueAction(getMetaDataAction);
  },

  getQuoteData: function (component, event, helper, offset, limit) {
    component.set("v.showLoadingSpinner", true);
    var filterObjectString = this.getFilterObjectString(
      component,
      event,
      helper
    );
    var accountIds = [];
    var accountId = component.get("v.accountId");
    accountIds.push(accountId);
    if (
      component.get("v.childAccounts") &&
      component.get("v.showChildAccounts")
    ) {
      var acctIds = component.get("v.childAccounts");
      acctIds.map((acc) => {
        accountIds.push(acc.Id);
      });
    }
    var paginationParamsString = this.getPaginationParamsString(
      component,
      event,
      helper,
      offset,
      limit
    );
    var searchListKeyword = component.get("v.searchKeyWord");
    console.log("filterObjectString", filterObjectString);
    console.log("paginationParamsString", paginationParamsString);
    var getQuoteDataAction = component.get("c.getQuoteListData");
    getQuoteDataAction.setParams({
      accountIds: accountIds,
      filterObjectString: filterObjectString,
      paginationParamsString: paginationParamsString,
      searchListKeyword: searchListKeyword
    });
    getQuoteDataAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        var data = response.getReturnValue();
        if (data && data.length > 0) {
          component.set("v.data", data);
          component.set("v.showNoResult", false);
        } else {
          component.set("v.data", data);
          component.set("v.showNoResult", true);
        }
        component.set("v.showLoadingSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
            component.set("v.showLoadingSpinner", false);
          }
        }
      }
      component.set("v.showLoadingSpinner", false);
    });
    $A.enqueueAction(getQuoteDataAction);
  },

  fetchTotalQuotes: function (component, event, helper, isDoInit) {
    component.set("v.showLoadingSpinner", true);
    component.set("v.showNoResult", false);
    var filterObjectString = this.getFilterObjectString(
      component,
      event,
      helper
    );
    var accountIds = [];
    var accountId = component.get("v.accountId");
    accountIds.push(accountId);
    if (
      component.get("v.childAccounts") &&
      component.get("v.showChildAccounts")
    ) {
      var acctIds = component.get("v.childAccounts");
      acctIds.map((acc) => {
        accountIds.push(acc.Id);
      });
    }
    var searchListKeyword = component.get("v.searchKeyWord");
    var fetchTotalQuotesAction = component.get("c.getTotalQuotes");
    fetchTotalQuotesAction.setParams({
      accountIds: accountIds,
      filterObjectString: filterObjectString,
      searchListKeyword: searchListKeyword
    });
    fetchTotalQuotesAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        var totalQuotes = response.getReturnValue();
        component.set("v.totalRange", totalQuotes);
        if (totalQuotes == 0) {
          if (isDoInit) {
            component.set("v.showFilters", false);
          } else {
            component.set("v.showFilters", true);
          }
        }
        var pagination1 = component.find("pagination1");
        if (pagination1) {
          pagination1.callDoInit();
        }
        var pagination2 = component.find("pagination2");
        if (pagination2) {
          pagination2.callDoInit();
        }
        component.set("v.showLoadingSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
            component.set("v.showLoadingSpinner", false);
          }
        } else {
          console.log("Unknown error");
          component.set("v.showLoadingSpinner", false);
        }
        component.set("v.showNoResult", true);
      }
      component.set("v.showLoadingSpinner", false);
    });
    $A.enqueueAction(fetchTotalQuotesAction);
  },

  getPaginationParamsString: function (
    component,
    event,
    helper,
    offset,
    limit
  ) {
    var paginationParams = {};
    if (offset != null) {
      paginationParams.offset = offset;
    } else {
      paginationParams.offset = component.get("v.startRange") - 1;
    }
    if (limit != null) {
      paginationParams.limit = limit;
    } else {
      paginationParams.limit = component.get("v.showRecords");
    }
    return JSON.stringify(paginationParams);
  },

  getFilterObjectString: function (component, event, helper) {
    var filterObject = {};
    filterObject.selectedAccountId = component.get("v.selectedAccountId");
    filterObject.departureFromDate = component.get("v.departureFromDate");
    filterObject.departureToDate = component.get("v.departureToDate");
    filterObject.showChildAcc = component.get("v.showChildAcc");
    filterObject.statusSelected = component.get("v.statusSelected");
    filterObject.hazQuote = component.get("v.hazQuote");
    filterObject.comoditySelected = component.get("v.comoditySelected");
    filterObject.vessalSelected = component.get("v.vessalSelected");
    filterObject.selectedContractId = component.get("v.selectedContractId");
    filterObject.destinationLocationId = component.get(
      "v.destinationLocationId"
    );
    filterObject.originLocationId = component.get("v.originLocationId");
    filterObject.originMovementType = component.get("v.originMovementType");
    filterObject.destMovementType = component.get("v.destMovementType");
    filterObject.containerTypeSelected = component.get(
      "v.containerTypeSelected"
    );
    filterObject.contractInput = component.get("v.contractInput");

    return JSON.stringify(filterObject);
  },

  sortByLabel: function (data) {
    data.sort(function (a, b) {
      return a.label.localeCompare(b.label);
    });
    return data;
  }
});
