({
  getSearchFiledHelper: function (component) {
    component.set("v.boolSpinner", true);
    var objAction = component.get("c.getSearchFiled");
    objAction.setParams({
      strObjectType: component.get("v.strCalledFor")
    });

    objAction.setCallback(this, function (searchResult) {
      if (searchResult.getState() === "SUCCESS") {
        component.set("v.lstSearchFiled", searchResult.getReturnValue());
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objAction);
  },

  handleSearchAccountClickHelper: function (component) {
    component.set("v.boolSpinner", true);
    var objAction = component.get("c.getAccounts");
    objAction.setParams({
      strSearchString: component.get("v.strSearchedString"),
      strInitiative: component.get("v.strRecordId"),
      strSelectedAccountValue: JSON.stringify(
        component.get("v.lstSelectedAccountValue")
      ),
      strSelectedAccFieldToSearch: component.get("v.strSelectedFieldAccount"),
      boolSearchParentWithChild: component.get("v.boolparentWithChild")
    });

    objAction.setCallback(this, function (searchResult) {
      if (searchResult.getState() === "SUCCESS") {
        component.set("v.lstAccountsWrapper", searchResult.getReturnValue());
        if (
          searchResult.getReturnValue().length >
          parseInt($A.get("$Label.c.AINI_LIMIT_RECORDS"))
        ) {
          component.set(
            "v.strAlertMessage",
            $A.get("$Label.c.AINI_LIMIT_CROSS_MESSAGE")
          );
        } else {
          component.set("v.strAlertMessage", "");
        }
      } else {
        alert("Problem in connection, please try later.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objAction);
  },

  handleSearchLeadClickHelper: function (component) {
    component.set("v.boolSpinner", true);
    var objAction = component.get("c.getLeads");
    objAction.setParams({
      strSearchString: component.get("v.strSearchedString"),
      strInitiative: component.get("v.strRecordId"),
      strSelectedLeadValue: JSON.stringify(
        component.get("v.lstSelectedLeadValue")
      ),
      strSelectedLeadFieldToSearch: component.get("v.strSelectedFieldLead")
    });

    objAction.setCallback(this, function (searchResult) {
      if (searchResult.getState() === "SUCCESS") {
        component.set("v.lstLeadsWrapper", searchResult.getReturnValue());
        if (
          searchResult.getReturnValue().length >
          parseInt($A.get("$Label.c.AINI_LIMIT_RECORDS"))
        ) {
          component.set(
            "v.strAlertMessage",
            $A.get("$Label.c.AINI_LIMIT_CROSS_MESSAGE")
          );
        } else {
          component.set("v.strAlertMessage", "");
        }
      } else {
        alert("Problem in connection, please try later.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objAction);
  },

  handleAccountSelectChangeHelper: function (component, event) {
    var lstSelectedOptions = event.getParam("value");
    component.set("v.lstSelectedAccountValue", lstSelectedOptions);
    if (lstSelectedOptions != null && lstSelectedOptions.length > 0) {
      component.set("v.boolDisabledSaveButton", false);
    } else {
      component.set("v.boolDisabledSaveButton", true);
    }
  },

  handleLeadSelectChangeHelper: function (component, event) {
    var lstSelectedOptions = event.getParam("value");
    component.set("v.lstSelectedLeadValue", lstSelectedOptions);
    if (lstSelectedOptions != null && lstSelectedOptions.length > 0) {
      component.set("v.boolDisabledSaveButton", false);
    } else {
      component.set("v.boolDisabledSaveButton", true);
    }
  },

  handleSaveAccountClickHelper: function (component, helper) {
    component.set("v.boolSpinner", true);
    var objAction = component.get("c.saveInitiativeAccount");
    objAction.setParams({
      strSelectedAccounts: JSON.stringify(
        component.get("v.lstSelectedAccountValue")
      ),
      strInitiative: component.get("v.strRecordId")
    });

    objAction.setCallback(this, function (insertResult) {
      if (insertResult.getState() === "SUCCESS") {
        if (insertResult.getReturnValue().SAVE_RESULT === "TRUE") {
          helper.showSuccess();
          $A.get("e.force:closeQuickAction").fire();
          component.set("v.boolShowFilterModal", false);
          window.location.reload();
        } else if (insertResult.getReturnValue().SAVE_RESULT === "FALSE") {
          alert(insertResult.getReturnValue().ERROR_MESSAGE);
        }
      } else {
        alert("Problem in connection, please try later.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objAction);
  },

  handleSaveLeadClickHelper: function (component, helper) {
    component.set("v.boolSpinner", true);
    var objAction = component.get("c.saveInitiativeLead");
    objAction.setParams({
      strSelectedLeads: JSON.stringify(component.get("v.lstSelectedLeadValue")),
      strInitiative: component.get("v.strRecordId")
    });

    objAction.setCallback(this, function (insertResult) {
      if (insertResult.getState() === "SUCCESS") {
        if (insertResult.getReturnValue().SAVE_RESULT === "TRUE") {
          helper.showSuccess();
          $A.get("e.force:closeQuickAction").fire();
          component.set("v.boolShowFilterModal", false);
          window.location.reload();
        } else if (insertResult.getReturnValue().SAVE_RESULT === "FALSE") {
          alert(insertResult.getReturnValue().ERROR_MESSAGE);
        }
      } else {
        alert("Problem in connection, please try later.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objAction);
  },

  showSuccess: function () {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Success",
      message: $A.get("$Label.c.AINI_RECORD_SAVE_SUCCESS_MESSAGE"),
      duration: " 5000",
      key: "info_alt",
      type: "success",
      mode: "pester"
    });
    toastEvent.fire();
  }
});
