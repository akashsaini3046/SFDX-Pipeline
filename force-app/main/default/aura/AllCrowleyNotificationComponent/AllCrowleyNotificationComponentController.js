({
  doInit: function (component) {
    var action = component.get("c.getNotifications");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.notificationList", response.getReturnValue());
        /*if(component.get("v.notificationList").length <= Number($A.get('$Label.c.Number_of_records_to_retrieve'))) {
                    component.set('v.crowleyNotificationCountLabel', ''+ (component.get("v.notificationList").length) + ' ' + $A.get("$Label.c.Number_of_Reports"));
                } else {
                    component.set('v.crowleyNotificationCountLabel', $A.get('$Label.c.Number_of_records_to_retrieve') + '+ ' + $A.get("$Label.c.Number_of_Reports"));
                }*/
        var display = [];
        for (
          var i = 0;
          i < component.get("v.notificationList").length &&
          i < Number($A.get("$Label.c.Number_of_records_to_retrieve"));
          i++
        ) {
          display.push(component.get("v.notificationList")[i]);
        }
        component.set("v.topFive", display);
        console.log("topfive tripathi-" + component.get("v.topFive"));
      }
    });
    $A.enqueueAction(action);
  },

  gotoList: function (component, event, helper) {
    var action = component.get("c.getCNAllListView");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var listviews = response.getReturnValue();
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
          listViewId: listviews.Id,
          scope: "Crowley_Notification__c"
        });
        navEvent.fire();
      }
    });
    $A.enqueueAction(action);
  }
});
