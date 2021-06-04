({
  isAllOpportunityLineItemsLostHelper: function (lstOpportunityLineItems) {
    var isAllLost = true;
    for (var index = 0; index < lstOpportunityLineItems.length; index++) {
      if (lstOpportunityLineItems[index].boolServiceStatus === true) {
        isAllLost = false;
        break;
      }
    }
    return isAllLost;
  },

  handleSplitCloseHelper: function (component) {
    component.set("v.boolShowFilterModal", false);
  },

  doInitHelper: function (component, helper) {
    var lstServiceStatusOptions = [
      {
        label: $A.get("$Label.c.OPS_SERVICE_STATUS_WON"),
        value: $A.get("$Label.c.OPS_SERVICE_STATUS_WON")
      },
      {
        label: $A.get("$Label.c.OPS_SERVICE_STATUS_LOST"),
        value: $A.get("$Label.c.OPS_SERVICE_STATUS_LOST")
      }
    ];
    component.set("v.lstServiceStatus", lstServiceStatusOptions);

    var objGetOpportunityAction = component.get("c.getOpportunity");
    var objGetOpportunityLineItemsAction = component.get(
      "c.getOpportunityLineItems"
    );
    var objGetWonAndLostOppSizeAction = component.get("c.getWonAndLostOppSize");

    objGetOpportunityAction.setParams({
      idOpportunity: component.get("v.recordId")
    });
    objGetOpportunityLineItemsAction.setParams({
      idOpportunity: component.get("v.recordId"),
      strSource: component.get("v.strSource")
    });
    objGetWonAndLostOppSizeAction.setParams({
      idOpportunity: component.get("v.recordId")
    });

    objGetOpportunityAction.setCallback(this, function (splitResult) {
      if (splitResult.getState() === "SUCCESS") {
        component.set("v.objCurrentOpportunity", splitResult.getReturnValue());
        //Check if user has permission to select service
        if (
          splitResult.getReturnValue() != null &&
          splitResult.getReturnValue().Current_User_Profile__c != null
        ) {
          var lstProfile = $A
            .get("$Label.c.OPS_ALLOWED_PROFILES_AFTER_CLOSE")
            .split($A.get("$Label.c.OPS_SPLIT_TOKEN"));
          if (
            splitResult.getReturnValue().Is_Split_Taken_Care__c === true &&
            lstProfile.indexOf(
              splitResult.getReturnValue().Current_User_Profile__c
            ) == -1
          ) {
            component.set("v.boolHasAccessToSelectService", false);
          } else {
            component.set("v.boolHasAccessToSelectService", true);
          }
        }

        //Check if there are line items associated with opportunity then show modal dialog
        if (
          splitResult.getReturnValue() != null &&
          splitResult.getReturnValue().OpportunityLineItems != null &&
          splitResult.getReturnValue().OpportunityLineItems.length > 0
        ) {
          component.set("v.boolShowFilterModal", true);
          if (
            splitResult.getReturnValue().Is_Split_Taken_Care__c === false ||
            component.get("v.strSource") == "QUICK_ACTION_DESKTOP"
          ) {
            component.set("v.boolSpinner", true);
          }
        }

        objGetOpportunityLineItemsAction.setCallback(this, function (result) {
          if (result.getState() === "SUCCESS") {
            component.set("v.lstOpportunityLineItem", result.getReturnValue());
            component.set("v.boolDataLoaded", true);
            component.set("v.boolSpinner", false);
            objGetWonAndLostOppSizeAction.setCallback(
              this,
              function (sizeResult) {
                if (sizeResult.getState() === "SUCCESS") {
                  component.set(
                    "v.decWonOppSize",
                    sizeResult.getReturnValue().WON_OPP_SIZE
                  );
                  component.set(
                    "v.decLostOppSize",
                    sizeResult.getReturnValue().LOST_OPP_SIZE
                  );
                } else {
                  component.set("v.boolSpinner", false);
                  alert("Problem in connection, please try later.");
                }
              }
            );
            $A.enqueueAction(objGetWonAndLostOppSizeAction);
          } else {
            component.set("v.boolSpinner", false);
            alert("Problem in connection, please try later.");
          }
        });
        $A.enqueueAction(objGetOpportunityLineItemsAction);
      } else {
        component.set("v.boolSpinner", false);
        alert("Problem in connection, please try later.");
      }
    });
    $A.enqueueAction(objGetOpportunityAction);
  },

  handleSaveSplitClickHelper: function (component, helper) {
    if (
      helper.isAllOpportunityLineItemsLostHelper(
        component.get("v.lstOpportunityLineItem")
      )
    ) {
      if (confirm($A.get("$Label.c.OPS_MESSAGE_ALL_LOST_SERVICCES"))) {
        helper.handleCloselClickHelper(component, helper);
      }
    } else {
      var objAction = component.get("c.saveSplitOpportunity");
      objAction.setParams({
        idOpportunity: component.get("v.recordId"),
        lstOpportunitySplitServiceWrapper: component.get(
          "v.lstOpportunityLineItem"
        )
      });

      component.set("v.boolSpinner", true);

      objAction.setCallback(this, function (result) {
        component.set("v.boolSpinner", false);
        if (
          result.getState() === "SUCCESS" &&
          result.getReturnValue() === true
        ) {
          alert($A.get("$Label.c.OPS_MESSAGE_RECORD_SAVED_SUCESSFULLY"));
          window.location.reload();
          helper.handleCloselClickHelper(component, helper);
        } else if (
          result.getState() === "SUCCESS" &&
          result.getReturnValue() === false
        ) {
          alert("Server error occured, please connect with system admin.");
        } else {
          alert("Problem in connection, please try later.");
        }
      });

      $A.enqueueAction(objAction);
    }
  },

  handleWonAllClickHelper: function (component) {
    var lstOppLineItem = component.get("v.lstOpportunityLineItem");
    for (var index = 0; index < lstOppLineItem.length; index++) {
      lstOppLineItem[index].boolServiceStatus = true;
    }
    component.set("v.lstOpportunityLineItem", lstOppLineItem);

    //Set won and lost opportunity size
    var decWonOppSize = 0.0,
      decLostOppSize = 0.0;
    var lstOpportunityLineItem = component.get("v.lstOpportunityLineItem");
    for (var index = 0; index < lstOpportunityLineItem.length; index++) {
      if (
        lstOpportunityLineItem[index].decTotalPrice == 0.0 &&
        lstOpportunityLineItem[index].decLostTotalPrice != 0.0
      ) {
        decWonOppSize += lstOpportunityLineItem[index].decLostTotalPrice;
        lstOpportunityLineItem[index].decTotalPrice =
          lstOpportunityLineItem[index].decLostTotalPrice;
      } else {
        decWonOppSize += lstOpportunityLineItem[index].decTotalPrice;
      }
      lstOpportunityLineItem[index].decLostTotalPrice = 0.0;
    }

    component.set("v.lstOpportunityLineItem", lstOpportunityLineItem);
    component.set("v.decWonOppSize", decWonOppSize);
    component.set("v.decLostOppSize", decLostOppSize);
  },

  handleLostAllClickHelper: function (component) {
    var lstOppLineItem = component.get("v.lstOpportunityLineItem");
    for (var index = 0; index < lstOppLineItem.length; index++) {
      lstOppLineItem[index].boolServiceStatus = false;
    }
    component.set("v.lstOpportunityLineItem", lstOppLineItem);

    //Set won and lost opportunity size
    var decWonOppSize = 0.0,
      decLostOppSize = 0.0;
    var lstOpportunityLineItem = component.get("v.lstOpportunityLineItem");
    for (var index = 0; index < lstOpportunityLineItem.length; index++) {
      if (
        lstOpportunityLineItem[index].decTotalPrice == 0.0 &&
        lstOpportunityLineItem[index].decLostTotalPrice != 0.0
      ) {
        decLostOppSize += lstOpportunityLineItem[index].decLostTotalPrice;
      } else {
        decLostOppSize += lstOpportunityLineItem[index].decTotalPrice;
        lstOpportunityLineItem[index].decLostTotalPrice =
          lstOpportunityLineItem[index].decTotalPrice;
      }
      lstOpportunityLineItem[index].decTotalPrice = 0.0;
    }

    component.set("v.lstOpportunityLineItem", lstOpportunityLineItem);
    component.set("v.decWonOppSize", decWonOppSize);
    component.set("v.decLostOppSize", decLostOppSize);
  },

  handleCloselClickHelper: function (component, helper) {
    if (component.get("v.strSource") == "DESKTOP_CLOSED_WON") {
      helper.handleSplitCloseHelper(component);
    } else {
      $A.get("e.force:closeQuickAction").fire();
      helper.handleSplitCloseHelper(component);
    }
  },

  serviceStatusChangeHandler: function (component, event) {
    var decWonOppSize = 0.0,
      decLostOppSize = 0.0;
    decWonOppSize = component.get("v.decWonOppSize");
    decLostOppSize = component.get("v.decLostOppSize");
    var lstOpportunityLineItem = component.get("v.lstOpportunityLineItem");
    if (event.getSource().get("v.checked") === true) {
      for (var index = 0; index < lstOpportunityLineItem.length; index++) {
        if (
          lstOpportunityLineItem[index].idLineItem ==
          event.getSource().get("v.name")
        ) {
          if (
            lstOpportunityLineItem[index].decTotalPrice == 0.0 &&
            lstOpportunityLineItem[index].decLostTotalPrice != 0.0
          ) {
            decWonOppSize += lstOpportunityLineItem[index].decLostTotalPrice;
            decLostOppSize -= lstOpportunityLineItem[index].decLostTotalPrice;
            lstOpportunityLineItem[index].decTotalPrice =
              lstOpportunityLineItem[index].decLostTotalPrice;
          } else {
            decWonOppSize += lstOpportunityLineItem[index].decTotalPrice;
            decLostOppSize -= lstOpportunityLineItem[index].decTotalPrice;
          }
          lstOpportunityLineItem[index].decLostTotalPrice = 0.0;
        }
      }
    } else if (event.getSource().get("v.checked") === false) {
      for (var index = 0; index < lstOpportunityLineItem.length; index++) {
        if (
          lstOpportunityLineItem[index].idLineItem ==
          event.getSource().get("v.name")
        ) {
          if (
            lstOpportunityLineItem[index].decTotalPrice == 0.0 &&
            lstOpportunityLineItem[index].decLostTotalPrice != 0.0
          ) {
            decWonOppSize -= lstOpportunityLineItem[index].decLostTotalPrice;
            decLostOppSize += lstOpportunityLineItem[index].decLostTotalPrice;
          } else {
            decWonOppSize -= lstOpportunityLineItem[index].decTotalPrice;
            decLostOppSize += lstOpportunityLineItem[index].decTotalPrice;
            lstOpportunityLineItem[index].decLostTotalPrice =
              lstOpportunityLineItem[index].decTotalPrice;
          }
          lstOpportunityLineItem[index].decTotalPrice = 0.0;
        }
      }
    }

    component.set("v.lstOpportunityLineItem", lstOpportunityLineItem);
    component.set("v.decWonOppSize", decWonOppSize);
    component.set("v.decLostOppSize", decLostOppSize);
  }
});
