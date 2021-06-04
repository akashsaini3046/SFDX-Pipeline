({
  recordUpdated: function (cmp, event, helper) {
    var eventParams = event.getParams();
    if (eventParams.changeType === "CHANGED") {
      var caseRecord = JSON.parse(JSON.stringify(cmp.get("v.caseRecord")));
      if (caseRecord.fields.Show_Popup__c.value) {
        helper.showPopupAction(cmp, event, helper);
      }

      /*// get the fields that are changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed so refresh the component (or other component logic)
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Saved",
                "message": "The record was updated."
            });
            resultsToast.fire();*/
    } else if (eventParams.changeType === "LOADED") {
      console.log("Record is loaded successfully.");
    } else if (eventParams.changeType === "REMOVED") {
      var resultsToast = $A.get("e.force:showToast");
      resultsToast.setParams({
        title: "Deleted",
        message: "The record was deleted."
      });
      resultsToast.fire();
    } else if (eventParams.changeType === "ERROR") {
      console.log("Error: " + component.get("v.error"));
    }
  }
});
