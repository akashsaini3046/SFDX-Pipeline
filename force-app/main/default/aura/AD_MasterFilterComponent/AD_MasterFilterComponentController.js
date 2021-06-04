({
  doInit: function (component, event, helper) {
    var lstFilterByOptions = [
      {
        label: $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME"),
        value: $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME")
      },
      {
        label: $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_OWNER"),
        value: $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_OWNER")
      }
    ];
    component.set("v.lstFilterByOptions", lstFilterByOptions);
    var lstOpportunitySizeOperatorOptions = [
      {
        label: $A.get("$Label.c.AD_PICKLIST_VAL_NONE"),
        value: $A.get("$Label.c.AD_PICKLIST_VAL_NONE")
      },
      { label: ">", value: ">" },
      { label: ">=", value: ">=" },
      { label: "<", value: "<" },
      { label: "<=", value: "<=" },
      { label: "=", value: "=" }
    ];
    component.set(
      "v.lstOppSizeFilterOperator",
      lstOpportunitySizeOperatorOptions
    );
    component.set("v.strYearToShowOnTop", component.get("v.strCurrentYear"));

    helper.getChildAccountsHepler(component, helper);
    helper.getAccountsOwnerHepler(component);
    helper.getPicklistYearHelper(component);

    console.log("INSIDE INIT " + component.get("v.boolInit"));
  },

  handleFilterCloseClick: function (component, event, helper) {
    helper.verifyFilterChangeAndClose(component);
  },

  handleFilterApplyClick: function (component, event, helper) {
    var lstChildAccounts = component.get("v.lstChildAccounts");
    var lstAccountOwners = component.get("v.lstAccountOwners");
    var lstSelectedAccounts = [];
    var lstSelectedAccountOwners = [];
    var lstStrSelectedAccountOwners = [];
    var lstStrSelectedAccouts = [];
    for (var index = 0; index < lstChildAccounts.length; index++) {
      if (lstChildAccounts[index].Selected) {
        lstSelectedAccounts.push(lstChildAccounts[index].Id);
        lstStrSelectedAccouts.push(lstChildAccounts[index].Name);
      }
    }

    for (var index = 0; index < lstAccountOwners.length; index++) {
      if (lstAccountOwners[index].Selected) {
        lstSelectedAccountOwners.push(lstAccountOwners[index].Id);
        lstStrSelectedAccountOwners.push(lstAccountOwners[index].Name);
      }
    }

    //-----------------------Validation section started------------------------
    var inputOppsize = component.find("idInputopportunitysize");
    var valueInputOppsize = inputOppsize.get("v.value");

    if (valueInputOppsize != null && valueInputOppsize != undefined) {
      valueInputOppsize = valueInputOppsize.replace(/,/g, "");
      valueInputOppsize = valueInputOppsize.trim();
    }

    // Is input numeric?
    if (
      valueInputOppsize != null &&
      valueInputOppsize != undefined &&
      valueInputOppsize != "" &&
      isNaN(valueInputOppsize)
    ) {
      // Set error
      component.set(
        "v.strError",
        $A.get("$Label.c.AD_LABEL_OPPORTUNITY_SIZE_IS_NOT_A_NUMBER")
      );
      component.set("v.boolInputError", true);
    } else {
      // Clear error
      component.set("v.strError", null);
      component.set("v.boolInputError", false);
    }

    //-----------------------Validation section ends------------------------

    //alert('Work in progress..');
    if (component.get("v.boolInputError") === false) {
      var strSelectedYear = $A.util.isEmpty(component.get("v.strSelectedYear"))
        ? component.get("v.strCurrentYear")
        : component.get("v.strSelectedYear");
      strSelectedYear =
        strSelectedYear == $A.get("$Label.c.AD_PICKLIST_VAL_NONE")
          ? component.get("v.strCurrentYear")
          : strSelectedYear;
      //----------------------Trigger Master Filter Event----------------------
      var objMasterFilterEvent = $A.get("e.c:AD_EVTMasterFilter");
      var mapMasterEventParams = {};
      mapMasterEventParams.lstSelectedAccounts = lstSelectedAccounts;
      mapMasterEventParams.lstSelectedOwners = lstSelectedAccountOwners;
      mapMasterEventParams.strSelectedTopFilter = component.get(
        "v.strSelectedFilterBy"
      );
      mapMasterEventParams.strSelectedOppSizeFilterOperator = component.get(
        "v.strSelectedOppSizeFilterOperator"
      );
      mapMasterEventParams.strOppSizeVal = valueInputOppsize;
      mapMasterEventParams.strSelectedYear = strSelectedYear;

      objMasterFilterEvent.setParams({
        mapMasterEventParams: mapMasterEventParams
      });
      objMasterFilterEvent.fire();
      helper.filterCloseClickHelper(component);
      component.set("v.strYearToShowOnTop", strSelectedYear);

      if (component.get("v.boolSelectAllAccount") === true) {
        component.set(
          "v.strSelectedFilterString",
          $A.get("$Label.c.AD_LABEL_ALL_ACCOUNTS")
        );
        component.set("v.strSelectedCount", "");
      } else if (
        component.get("v.strSelectedFilterBy") ===
          $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME") &&
        lstStrSelectedAccouts != null &&
        lstStrSelectedAccouts != undefined &&
        lstStrSelectedAccouts.length > 0
      ) {
        var strSelectedAccouts = $A.get("$Label.c.AD_ACCOUNT_S") + " ";
        strSelectedAccouts += lstStrSelectedAccouts.join(", ");
        component.set("v.strSelectedFilterString", strSelectedAccouts);
        component.set(
          "v.strSelectedCount",
          "(" + lstStrSelectedAccouts.length + ")"
        );
      } else if (
        component.get("v.strSelectedFilterBy") ===
          $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_OWNER") &&
        lstStrSelectedAccountOwners != null &&
        lstStrSelectedAccountOwners != undefined &&
        lstStrSelectedAccountOwners.length > 0
      ) {
        var strSelectedOwners = $A.get("$Label.c.AD_ACCOUNT_OWNER_S") + " ";
        strSelectedOwners += lstStrSelectedAccountOwners.join(", ");
        component.set("v.strSelectedFilterString", strSelectedOwners);
        component.set(
          "v.strSelectedCount",
          "(" + lstStrSelectedAccountOwners.length + ")"
        );
      } else {
        component.set(
          "v.strSelectedFilterString",
          $A.get("$Label.c.AD_LABEL_ALL_ACCOUNTS")
        );
        component.set("v.strSelectedCount", "");
      }
      //------------------------Master Filter Event Ends-----------------------
    }
  },

  handleFilterByOptionsChange: function (component, event, helper) {
    if (
      component.get("v.strSelectedFilterBy") ===
      $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME")
    ) {
      helper.clearSelectedOwners(component);
    } else if (
      component.get("v.strSelectedFilterBy") ===
      $A.get("$Label.c.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_OWNER")
    ) {
      helper.clearSelectedAccounts(component);
    } else if (
      component.get("v.strSelectedFilterBy") ===
      $A.get("$Label.c.AD_PICKLIST_VAL_ALL_ACCOUNTS")
    ) {
      helper.clearSelectedAccounts(component);
      helper.clearSelectedOwners(component);
    }
  },

  handleFilterClick: function (component, event, helper) {
    component.set("v.boolShowFilterModal", true);
    component.set(
      "v.strCopyChildAccounts",
      JSON.stringify(component.get("v.lstChildAccounts"))
    );
    component.set(
      "v.strCopyAccountOwners",
      JSON.stringify(component.get("v.lstAccountOwners"))
    );
    component.set(
      "v.strCopySelectedFilterBy",
      component.get("v.strSelectedFilterBy")
    );
    component.set("v.strCopySelectedYear", component.get("v.strSelectedYear"));
    component.set("v.strCopyOppSizeVal", component.get("v.strOppSizeVal"));
    component.set(
      "v.boolCopySelectAllAccount",
      component.get("v.boolSelectAllAccount")
    );
    component.set(
      "v.strCopySelectedOppSizeFilterOperator",
      component.get("v.strSelectedOppSizeFilterOperator")
    );
  },

  handleOpportunitySizeOperatorChange: function (component, event, helper) {
    if (
      component.get("v.strSelectedOppSizeFilterOperator") ===
      $A.get("$Label.c.AD_PICKLIST_VAL_NONE")
    ) {
      component.set("v.strOppSizeVal", "");
    }
  },

  handleSelectAllAccounts: function (component, event, helper) {
    if (component.get("v.boolSelectAllAccount") === true) {
      helper.selecteAllAccounts(component);
    } else {
      helper.clearSelectedAccounts(component);
    }
  },

  handleAccountChange: function (component, event, helper) {
    if (event.getSource().get("v.checked") === false) {
      component.set("v.boolSelectAllAccount", false);
    } else {
      helper.checkAllAcctSelectAndApply(component);
    }
  }
});
