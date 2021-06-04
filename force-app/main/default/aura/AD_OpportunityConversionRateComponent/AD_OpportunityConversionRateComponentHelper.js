({
  getOpportunityConversionRateHelper: function (component, objMasterFilter) {
    var objGetOpportunityConversionRateAction = component.get(
      "c.getOpportunityConversionRate"
    );
    //component.set('v.boolSpinner', true);

    objGetOpportunityConversionRateAction.setParams({
      idAccountId: component.get("v.idAccountId"),
      objMasterFilter: objMasterFilter
    });

    objGetOpportunityConversionRateAction.setCallback(
      this,
      function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set(
            "v.strOpportunityConvertionRateVal",
            response.getReturnValue().ConversionRate
          );
          var yearToShow;
          if (
            objMasterFilter.strSelectedYear ===
            component.get("v.strCurrentYear")
          ) {
            yearToShow = $A.get("$Label.c.AD_LABEL_CURRENT_YEAR");
          } else if (
            objMasterFilter.strSelectedYear ===
            $A.get("$Label.c.AD_PICKLIST_VAL_NONE")
          ) {
            yearToShow = "";
            objMasterFilter.strSelectedYear;
          } else {
            yearToShow = objMasterFilter.strSelectedYear;
          }
          component.set("v.strYearToShow", yearToShow);
        } else if (state === "ERROR") {
          alert("Problem with connection. Please try again.");
        }
        component.set("v.boolSpinner", false);
      }
    );
    $A.enqueueAction(objGetOpportunityConversionRateAction);
  }
});
