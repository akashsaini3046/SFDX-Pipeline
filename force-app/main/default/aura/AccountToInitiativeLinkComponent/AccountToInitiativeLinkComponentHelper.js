({
  doInitHelper: function (component) {
    component.set("v.boolSpinner", true);
    var objAction = component.get("c.getAccountById");
    objAction.setParams({
      strAccountId: component.get("v.recordId")
    });

    objAction.setCallback(this, function (searchResult) {
      if (searchResult.getState() === "SUCCESS") {
        component.set("v.objAccount", searchResult.getReturnValue());
      } else {
        alert("Problem in connection, please try later.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objAction);

    var objGetInitiativeAction = component.get("c.getAllInitiative");
    objGetInitiativeAction.setParams({
      strAccountId: component.get("v.recordId")
    });

    objGetInitiativeAction.setCallback(this, function (searchResult) {
      if (searchResult.getState() === "SUCCESS") {
        component.set("v.lstInitiative", searchResult.getReturnValue());
      } else {
        alert("Problem in connection, please try later.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objGetInitiativeAction);
  },

  handleSaveClickHelper: function (component, helper) {
    component.set("v.boolSpinner", true);
    var objAction = component.get("c.saveAccountInitiative");
    objAction.setParams({
      strAccountId: component.get("v.recordId"),
      strInitiativeId: component.get("v.strSelectedInitiativeId")
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
