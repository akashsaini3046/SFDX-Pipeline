({
  fetchChildMetadata: function (component, event, helper) {
    var action = component.get("c.getChildAccFilterMetaData");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var metadata = response.getReturnValue();
        if (metadata.salesRegionsList) {
          component.set("v.salesRepRegions", metadata.salesRegionsList);
        }
        if (metadata.typesList) {
          component.set("v.accountTypes", metadata.typesList);
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
  fetchTableJson: function (component, event, helper) {
    var action = component.get("c.getTableJson");
    action.setParams({
      jsonName: "Account Detail Child Acc"
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
  fetchTotalChildAccounts: function (component, event, helper) {
    var accountId = component.get("v.accountId");
    var searchKeyWord = component.get("v.searchKeyWord");
    console.log(JSON.stringify(component.get("v.filters")));
    var action = component.get("c.getTotalChildAccounts");
    action.setParams({
      accountId: accountId,
      filtersList: JSON.stringify(component.get("v.filters")),
      searchKeyWord: searchKeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var numberofAccts = response.getReturnValue();
      if (state === "SUCCESS") {
        console.log("numberofAccts", numberofAccts);
        component.set("v.totalRange", numberofAccts);
        var pagination1 = component.find("pagination1");
        if (pagination1) {
          pagination1.callDoInit();
        }
        var pagination2 = component.find("pagination2");
        if (pagination2) {
          pagination2.callDoInit();
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
    var accountId = component.get("v.accountId");
    console.log("accountId", accountId);
    var tableJson = {};
    tableJson.sObjectApiName = "Account";
    tableJson.limitRecords = limit;
    tableJson.offset = offset;
    tableJson.cardClassName = component.get("v.cardClassName");
    tableJson.fieldsToFetch = component.get("v.fieldsToFetch");

    tableJson.filters = [];

    var filter1 = {
      refId: "1",
      fieldName: "ParentId",
      values: [accountId],
      operator: "IN"
    };
    tableJson.filters.push(filter1);

    var refCounter = 2;
    var filters = component.get("v.filters");
    if (filters) {
      for (var propName in filters) {
        if (
          filters[propName] &&
          filters[propName] !== null &&
          filters[propName] !== ""
        ) {
          var filter = {};
          switch (propName) {
            case "cvifId":
              filter = {
                refId: refCounter + "",
                fieldName: "CVIF__c",
                values: [filters[propName] + "%"],
                operator: "LIKE"
              };
              refCounter++;
              break;
            case "accountId":
              filter = {
                refId: refCounter + "",
                fieldName: "Id",
                values: [filters[propName]],
                operator: "IN"
              };
              refCounter++;
              break;
            case "accountOwner":
              var accOwn = filters[propName].trim();
              var accOwnFirstName = accOwn.slice(0, accOwn.indexOf(" "));
              if (accOwn.includes(" ")) {
                var accOwnLastName = accOwn.slice(
                  accOwn.indexOf(" ") + 1,
                  accOwn.length
                );
              }
              filter = {
                refId: refCounter + "",
                fieldName: "Owner.FirstName",
                values: [accOwnFirstName + "%"],
                operator: "LIKE"
              };
              refCounter++;
              if (accOwnLastName && accOwnLastName != "") {
                var filterLastName = {
                  refId: refCounter + "",
                  fieldName: "Owner.LastName",
                  values: [accOwnLastName + "%"],
                  operator: "LIKE"
                };
                refCounter++;
              }
              break;
            case "searchRegion":
              filter = {
                refId: refCounter + "",
                fieldName: "Sales_Rep_Region__c",
                values: [filters[propName]],
                operator: "IN"
              };
              refCounter++;
              break;
            case "accountType":
              filter = {
                refId: refCounter + "",
                fieldName: "Type",
                values: [filters[propName]],
                operator: "IN"
              };
              refCounter++;
              break;
          }
          if (filter) {
            tableJson.filters.push(filter);
            if (filterLastName && filterLastName != "") {
              tableJson.filters.push(filterLastName);
              filterLastName = "";
            }
          }
        }
      }
    }
    var searchIndexFilter = refCounter;
    var searchKeyWord = component.get("v.searchKeyWord");
    if (searchKeyWord) {
      var searchFieldSetChildAcc = component.get("v.searchFieldSetChildAcc");
      if (searchFieldSetChildAcc) {
        searchFieldSetChildAcc.map((fieldName) => {
          var filter1 = {
            refId: refCounter + "",
            fieldName: fieldName,
            values: ["%" + searchKeyWord + "%"],
            operator: "LIKE"
          };
          refCounter++;
          tableJson.filters.push(filter1);
        });
      }
    }
    var lastCounter = refCounter - 1;
    var loginCounter = 1;
    tableJson.filterLogic = "";
    tableJson.filters.map(() => {
      if (loginCounter > searchIndexFilter) {
        if (loginCounter == lastCounter) {
          tableJson.filterLogic += " {" + loginCounter++ + "}) OR ";
        } else {
          tableJson.filterLogic += " {" + loginCounter++ + "} OR ";
        }
      } else if (loginCounter === searchIndexFilter) {
        tableJson.filterLogic += "( {" + loginCounter++ + "} OR ";
      } else {
        tableJson.filterLogic += " {" + loginCounter++ + "} AND ";
      }
    });
    tableJson.filterLogic = tableJson.filterLogic.substring(
      0,
      tableJson.filterLogic.length - 4
    );
    tableJson.sortBy = this.getSortByJson(component, event, helper);
    console.log("json", tableJson);
    component.set("v.tableJson", JSON.stringify(tableJson));
    var childCmp = component.find("accTable");
    childCmp.refreshTableData();
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
      sort.fieldName = "Name";
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
      label: "Account Name",
      value: "Name"
    };
    var cvifId = {
      label: "CVIF ID",
      value: "CVIF__c"
    };
    var accOwner = {
      label: "Account Owner",
      value: "Owner.FirstName"
    };
    var accRegion = {
      label: "Account Region",
      value: "Region__c"
    };
    var accType = {
      label: "Type",
      value: "Type"
    };
    sortByList.push(account);
    sortByList.push(cvifId);
    sortByList.push(accOwner);
    sortByList.push(accRegion);
    sortByList.push(accType);
    component.set("v.sortByList", sortByList);
  }
});
