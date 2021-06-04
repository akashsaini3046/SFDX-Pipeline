({
  doInit: function (component, event, helper) {
    component.set("v.idAccountId", component.get("v.recordId"));

    var objGetCurrentYearAction = component.get("c.getCurrentYear");
    //component.set('v.boolSpinner', true);

    objGetCurrentYearAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.strCurrentYear", response.getReturnValue());
        helper.createMasterFilterComponentsHelper(component);
        helper.createOpportunityPipelineComponentsHelper(component);
        helper.createOpportunityConversionRateComponentsHelper(component);
        helper.createActualVsNormalisedRevenue(component);
        helper.createTaskComponentsHelper(component);
        //helper.createNotesComponentsHelper(component);
        helper.createActualValueComponentsHelper(component);
      } else if (state === "ERROR") {
        alert("Problem with connection. Please try again.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objGetCurrentYearAction);
  }
});
