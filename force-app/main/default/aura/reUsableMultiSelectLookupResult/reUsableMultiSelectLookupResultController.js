({
  selectRecord: function (component, event, helper) {
    console.log(
      "Inside reUsableMultiSelectLookupResultController selectRecord"
    );
    // get the selected record from list
    var getSelectRecord = component.get("v.oRecord");
    console.log("reUsableMultiSelectLookupResultController " + getSelectRecord);
    // call the event
    var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.
    compEvent.setParams({ recordByEvent: getSelectRecord });
    // fire the event
    compEvent.fire();
  }
});
