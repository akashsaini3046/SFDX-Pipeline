({
  doInit: function (component, event, helper) {
    var strCurrentRecordId = component.get("v.recordId");
    component.set("v.strCurrentRecordId", strCurrentRecordId);

    var objAction = component.get("c.isInitiativeActive");
    objAction.setParams({
      strInitiative: component.get("v.recordId")
    });

    objAction.setCallback(this, function (searchResult) {
      if (searchResult.getState() === "SUCCESS") {
        component.set(
          "v.boolIsInitiativeActive",
          searchResult.getReturnValue()
        );
      } else {
        alert("Problem in connection, please try later.");
      }
    });
    $A.enqueueAction(objAction);
  }
});
