({
  getChildAccountsHepler: function (component, helper) {
    var objgetAllChildAccountAction = component.get("c.getAllChildAndParent");
    //component.set('v.boolSpinner', true);

    objgetAllChildAccountAction.setParams({
      idAccountId: component.get("v.idAccountId")
    });

    objgetAllChildAccountAction.setCallback(this, function (response) {
      var state = response.getState();
      var lstResponse = response.getReturnValue();
      var lstAccounts = [];
      if (state === "SUCCESS") {
        for (var index = 0; index < lstResponse.length; index++) {
          lstAccounts.push({
            Id: lstResponse[index].Id,
            Name: lstResponse[index].Name,
            Selected: false
          });
        }
        component.set("v.lstChildAccounts", lstAccounts);

        //Select current year by default on load of filter component
        component.set("v.strSelectedYear", component.get("v.strCurrentYear"));

        //Select all accounts by default on load of filter component
        component.set(
          "v.strSelectedFilterBy",
          $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME")
        );
        component.set("v.boolSelectAllAccount", true);
        helper.selecteAllAccounts(component);

        //Variable used to disable the filter unapplied alert on the first time
        component.set("v.boolInit", true);
      } else if (state === "ERROR") {
        alert("Problem with connection. Please try again.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objgetAllChildAccountAction);
  },

  getAccountsOwnerHepler: function (component) {
    //var objgetAllActiveUsersAction = component.get('c.getAllActiveUsers');
    var objgetAllActiveUsersAction = component.get(
      "c.getAllActiveUsersRelatedToAccount"
    );
    objgetAllActiveUsersAction.setParams({
      strAccountId: component.get("v.idAccountId")
    });

    //component.set('v.boolSpinner', true);

    objgetAllActiveUsersAction.setCallback(this, function (response) {
      var state = response.getState();
      var lstResponse = response.getReturnValue();
      var lstAccountOwners = [];
      if (state === "SUCCESS") {
        for (var index = 0; index < lstResponse.length; index++) {
          lstAccountOwners.push({
            Id: lstResponse[index].Id,
            Name: lstResponse[index].Name,
            Selected: false
          });
        }
        component.set("v.lstAccountOwners", lstAccountOwners);
      } else if (state === "ERROR") {
        alert("Problem with connection. Please try again.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objgetAllActiveUsersAction);
  },

  getPicklistYearHelper: function (component) {
    var objgetPicklistYearAction = component.get("c.getPicklistYear");
    //component.set('v.boolSpinner', true);

    objgetPicklistYearAction.setCallback(this, function (response) {
      var state = response.getState();
      var lstResponse = response.getReturnValue();
      var lstYearPicklist = [];

      if (state === "SUCCESS") {
        for (var index = 0; index < lstResponse.length; index++) {
          lstYearPicklist.push({
            label: lstResponse[index],
            value: lstResponse[index]
          });
        }
        component.set("v.lstFilterYear", lstYearPicklist);
      } else if (state === "ERROR") {
        alert("Problem with connection. Please try again.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objgetPicklistYearAction);
  },

  filterCloseClickHelper: function (component) {
    component.set("v.boolShowFilterModal", false);
  },

  verifyFilterChangeAndClose: function (component) {
    var boolUnsavedChanges = false;
    var lstChildAccounts = component.get("v.lstChildAccounts");
    var lstAccountOwners = component.get("v.lstAccountOwners");
    var lstCopyChildAccounts = component.get("v.lstCopyChildAccounts");
    var lstCopyAccountOwners = component.get("v.lstCopyAccountOwners");
    var strOppSizeVal = $A.util.isEmpty(component.get("v.strOppSizeVal"))
      ? ""
      : component.get("v.strOppSizeVal").trim();
    var strCopyOppSizeVal = $A.util.isEmpty(
      component.get("v.strCopyOppSizeVal")
    )
      ? ""
      : component.get("v.strCopyOppSizeVal").trim();

    if (
      component.get("v.strSelectedYear") !=
        component.get("v.strCopySelectedYear") ||
      strOppSizeVal != strCopyOppSizeVal
    ) {
      boolUnsavedChanges = true;
    }

    if (boolUnsavedChanges === false) {
      if (
        component.get("v.strCopyChildAccounts") !=
        JSON.stringify(component.get("v.lstChildAccounts"))
      ) {
        boolUnsavedChanges = true;
      }
    }

    if (boolUnsavedChanges === false) {
      if (
        component.get("v.strCopyAccountOwners") !=
        JSON.stringify(component.get("v.lstAccountOwners"))
      ) {
        boolUnsavedChanges = true;
      }
    }

    console.log(
      "INSIDE verifyFilterChangeAndClose " + component.get("v.boolInit")
    );

    if (boolUnsavedChanges && component.get("v.boolInit") === false) {
      if (confirm($A.get("$Label.c.AD_MESSAGE_UNAPPLIED_FILTER"))) {
        component.set(
          "v.strSelectedFilterBy",
          component.get("v.strCopySelectedFilterBy")
        );
        component.set(
          "v.strSelectedYear",
          component.get("v.strCopySelectedYear")
        );
        component.set(
          "v.lstChildAccounts",
          JSON.parse(component.get("v.strCopyChildAccounts"))
        );
        component.set(
          "v.lstAccountOwners",
          JSON.parse(component.get("v.strCopyAccountOwners"))
        );
        component.set("v.strOppSizeVal", component.get("v.strCopyOppSizeVal"));
        component.set(
          "v.boolSelectAllAccount",
          component.get("v.boolCopySelectAllAccount")
        );
        component.set(
          "v.strSelectedOppSizeFilterOperator",
          component.get("v.strCopySelectedOppSizeFilterOperator")
        );
        component.set("v.boolShowFilterModal", false);
      }
    } else {
      component.set("v.boolShowFilterModal", false);
    }
    component.set("v.boolInit", false);
  },

  clearSelectedAccounts: function (component) {
    var lstChildAccounts = component.get("v.lstChildAccounts");
    for (var index = 0; index < lstChildAccounts.length; index++) {
      lstChildAccounts[index].Selected = false;
    }
    component.set("v.lstChildAccounts", lstChildAccounts);
    component.set("v.boolSelectAllAccount", false);
  },

  selecteAllAccounts: function (component) {
    var lstChildAccounts = component.get("v.lstChildAccounts");
    for (var index = 0; index < lstChildAccounts.length; index++) {
      lstChildAccounts[index].Selected = true;
    }
    component.set("v.lstChildAccounts", lstChildAccounts);
  },

  clearSelectedOwners: function (component) {
    var lstOwners = component.get("v.lstAccountOwners");
    for (var index = 0; index < lstOwners.length; index++) {
      lstOwners[index].Selected = false;
    }
    component.set("v.lstAccountOwners", lstOwners);
  },

  checkAllAcctSelectAndApply: function (component) {
    var boolAllAcctSelected = true;
    var lstChildAccounts = component.get("v.lstChildAccounts");
    for (var index = 0; index < lstChildAccounts.length; index++) {
      if (lstChildAccounts[index].Selected === false) {
        boolAllAcctSelected = false;
        break;
      }
    }
    if (boolAllAcctSelected === true) {
      component.set("v.boolSelectAllAccount", true);
    }
  }
});
