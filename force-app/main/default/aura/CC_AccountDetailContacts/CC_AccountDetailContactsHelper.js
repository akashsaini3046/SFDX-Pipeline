({
  fetchTableJson: function (component, event, helper) {
    var action = component.get("c.getTableJson");
    action.setParams({
      jsonName: "Account Detail Contacts"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var tableJsonWrapper = response.getReturnValue();
        if (tableJsonWrapper.fieldsToFetch) {
          component.set("v.fieldsToFetch", tableJsonWrapper.fieldsToFetch);
        }
        if (tableJsonWrapper.cardClassName) {
          component.set("v.cardClassName", tableJsonWrapper.cardClassName);
        }
        var limit = component.get("v.showRecords");
        var offset = component.get("v.startRange") - 1;
        this.setTableJson(component, event, helper, limit, offset);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  fetchTotalContacts: function (component, event, helper, isDoInit) {
    var accountIds = [];
    var accountId = component.get("v.accountId");
    var searchKeyWord = component.get("v.searchKeyWord");
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
    var action = component.get("c.fetchTotalConts");
    console.log(accountIds);
    action.setParams({
      accountIds: accountIds,
      searchKeyWord: searchKeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var numberofConts = response.getReturnValue();
      if (state === "SUCCESS") {
        component.set("v.totalRange", numberofConts);
        var pagination1 = component.find("pagination1");
        if (pagination1) {
          pagination1.callDoInit();
        }
        var pagination2 = component.find("pagination2");
        if (pagination2) {
          pagination2.callDoInit();
        }
        if (numberofConts == 0) {
          if (isDoInit) {
            component.set("v.showFilters", false);
          } else {
            component.set("v.showFilters", true);
          }
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  setTableJson: function (component, event, helper, limit, offset) {
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
    var tableJson = {};
    tableJson.sObjectApiName = "Contact";
    tableJson.filters = [];
    var filter1 = {
      refId: "1",
      fieldName: "AccountId",
      values: accountIds,
      operator: "IN"
    };
    tableJson.filters.push(filter1);
    var refCounter = 2;
    var searchKeyWord = component.get("v.searchKeyWord");
    if (searchKeyWord) {
      var searchFieldSetContacts = component.get("v.searchFieldSetContacts");
      if (searchFieldSetContacts) {
        searchFieldSetContacts.map((fieldName) => {
          var filter2 = {
            refId: refCounter + "",
            fieldName: fieldName,
            values: ["%" + searchKeyWord + "%"],
            operator: "LIKE"
          };
          refCounter++;
          tableJson.filters.push(filter2);
        });
      }
    }
    var lastCounter = refCounter - 1;
    var loginCounter = 1;
    tableJson.filterLogic = "";
    tableJson.filters.map(() => {
      if (loginCounter > 2) {
        if (loginCounter == lastCounter) {
          tableJson.filterLogic += " {" + loginCounter++ + "}) OR ";
        } else {
          tableJson.filterLogic += " {" + loginCounter++ + "} OR ";
        }
      } else if (loginCounter === 2) {
        tableJson.filterLogic += "( {" + loginCounter++ + "} OR ";
      } else {
        tableJson.filterLogic += " {" + loginCounter++ + "} AND ";
      }
    });
    tableJson.filterLogic = tableJson.filterLogic.substring(
      0,
      tableJson.filterLogic.length - 4
    );

    tableJson.limitRecords = limit;
    tableJson.offset = offset;
    tableJson.cardClassName = component.get("v.cardClassName");
    tableJson.fieldsToFetch = this.filterFieldsToFetch(
      component,
      event,
      helper
    );

    tableJson.sortBy = this.getSortByJson(component, event, helper);
    console.log("tableJson ======> ", tableJson);
    component.set("v.tableJson", JSON.stringify(tableJson));
    var childCmp = component.find("conTable");
    childCmp.refreshTableData();
  },

  filterFieldsToFetch: function (component, event, helper) {
    var finalList = [];
    var fieldstoFetch = component.get("v.fieldsToFetch");
    var isParentAccount = component.get("v.isParentAccount");
    if (!isParentAccount) {
      fieldstoFetch.map((item) => {
        if (item.fieldName !== "Account.Name") {
          finalList.push(item);
        }
      });
    } else {
      finalList = fieldstoFetch;
    }
    return finalList;
  },

  getSortByJson: function (component, event, helper) {
    var sortByJsonArray = [];
    var sort = {};
    if (
      component.get("v.sortByField") &&
      component.get("v.sortByField") != ""
    ) {
      sort.fieldName = component.get("v.sortByField");
    } else {
      sort.fieldName = "Account.Name";
    }
    if (
      component.get("v.sortByFieldLabel") &&
      component.get("v.sortByFieldLabel") != ""
    ) {
      sort.fieldLabel = component.get("v.sortByFieldLabel");
    }
    if (
      component.get("v.sortByDirection") &&
      component.get("v.sortByDirection") != ""
    ) {
      sort.order = component.get("v.sortByDirection");
    } else {
      sort.order = "asc";
    }
    sortByJsonArray.push(sort);
    return sortByJsonArray;
  },

  setSortByList: function (component, event, helper) {
    var sortByList = [];
    var account = {
      label: "Account",
      value: "Account.Name"
    };
    var contactName = {
      label: "Contact Name",
      value: "Name"
    };
    var contactEmail = {
      label: "Contact Email",
      value: "Email"
    };
    var contactNumber = {
      label: "Contact Number",
      value: "Phone"
    };
    sortByList.push(account);
    sortByList.push(contactName);
    sortByList.push(contactEmail);
    sortByList.push(contactNumber);
    component.set("v.sortByList", sortByList);
  }
});
