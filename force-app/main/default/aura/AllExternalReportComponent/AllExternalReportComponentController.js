({
  doInit: function (component) {
    var action = component.get("c.getReports");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.externalReport", response.getReturnValue());
        if (
          component.get("v.externalReport").length <=
          Number($A.get("$Label.c.Number_of_records_to_retrieve"))
        ) {
          component.set(
            "v.externalReportCountLabel",
            "" +
              component.get("v.externalReport").length +
              " " +
              $A.get("$Label.c.Number_of_Reports")
          );
        } else {
          component.set(
            "v.externalReportCountLabel",
            $A.get("$Label.c.Number_of_records_to_retrieve") +
              "+ " +
              $A.get("$Label.c.Number_of_Reports")
          );
        }
        var display = [];
        for (
          var i = 0;
          i < component.get("v.externalReport").length &&
          i < Number($A.get("$Label.c.Number_of_records_to_retrieve"));
          i++
        ) {
          display.push(component.get("v.externalReport")[i]);
        }
        component.set("v.topFive", display);
      }
    });
    $A.enqueueAction(action);
  },

  gotoList: function (component, event, helper) {
    var action = component.get("c.getListViews");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var listviews = response.getReturnValue();
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
          listViewId: listviews.Id,
          scope: "External_Report_References__c"
        });
        navEvent.fire();
      }
    });
    $A.enqueueAction(action);
  }
});
