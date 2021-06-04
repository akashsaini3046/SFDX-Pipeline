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
      } else {
        decWonOppSize += lstOpportunityLineItem[index].decTotalPrice;
      }
    }

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
      }
    }

    component.set("v.decWonOppSize", decWonOppSize);
    component.set("v.decLostOppSize", decLostOppSize);
  },

  doInitHelper: function (component, helper) {
    var objGetOpportunityAction = component.get("c.getOpportunity");
    var objGetOpportunityLineItemsAction = component.get(
      "c.getOpportunityLineItems"
    );
    var objGetUIThemeAction = component.get("c.getUIThemeDescription");
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
    component.set("v.boolSpinner", true);

    objGetUIThemeAction.setCallback(this, function (themeResult) {
      if (themeResult.getState() === "SUCCESS") {
        if (
          themeResult.getReturnValue() ===
          $A.get("$Label.c.OPS_CONSTANT_MOBILE_UI_THEME")
        ) {
          objGetOpportunityAction.setCallback(this, function (splitResult) {
            if (splitResult.getState() === "SUCCESS") {
              var objOpportunityResponse = splitResult.getReturnValue();
              component.set("v.objCurrentOpportunity", objOpportunityResponse);

              //Validate opportunity record for component message
              var strComponentMessage;
              var boolHasAccessToSelectService;
              var lstProfile = $A
                .get("$Label.c.OPS_ALLOWED_PROFILES_AFTER_CLOSE")
                .split($A.get("$Label.c.OPS_SPLIT_TOKEN"));
              if (
                splitResult.getReturnValue() != null &&
                splitResult.getReturnValue().Current_User_Profile__c != null
              ) {
                if (
                  splitResult.getReturnValue().Is_Split_Taken_Care__c ===
                    true &&
                  lstProfile.indexOf(
                    splitResult.getReturnValue().Current_User_Profile__c
                  ) == -1
                ) {
                  boolHasAccessToSelectService = false;
                } else {
                  boolHasAccessToSelectService = true;
                }
              }
              /*if(objOpportunityResponse.Is_Split_Taken_Care__c) {
                                strComponentMessage = $A.get("$Label.c.OPS_MESSAGE_ALREADY_SPLIT");
                            } else */
              if (
                objOpportunityResponse.StageName !=
                $A.get("$Label.c.OPS_LABEL_CLOSED_WON_OPP")
              ) {
                strComponentMessage = $A.get(
                  "$Label.c.OPS_MESSAGE_NOT_CLOSED_WON_OPP"
                );
              } else if (
                objOpportunityResponse.StageName ==
                  $A.get("$Label.c.OPS_LABEL_CLOSED_WON_OPP") &&
                boolHasAccessToSelectService === false
              ) {
                strComponentMessage = $A.get(
                  "$Label.c.OPS_MESSAGE_DONT_HAVE_ACCESS"
                );
              } else if (
                objOpportunityResponse.Is_Split_Taken_Care__c === false &&
                (objOpportunityResponse.OpportunityLineItems == null ||
                  (objOpportunityResponse.OpportunityLineItems != null &&
                    objOpportunityResponse.OpportunityLineItems.length == 0))
              ) {
                strComponentMessage = $A.get(
                  "$Label.c.OPS_MESSAGE_NO_LINE_ITEM_ASSOCIATED"
                );
              } else {
                component.set("v.boolShowFilterModal", true);
              }
              component.set("v.strComponentMessage", strComponentMessage);
              component.set("v.boolShowComponentMessage", true);

              objGetOpportunityLineItemsAction.setCallback(
                this,
                function (result) {
                  if (result.getState() === "SUCCESS") {
                    component.set(
                      "v.lstOpportunityLineItem",
                      result.getReturnValue()
                    );
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
                }
              );
              $A.enqueueAction(objGetOpportunityLineItemsAction);
            } else {
              component.set("v.boolSpinner", false);
              alert("Problem in connection, please try later.");
            }
          });
          $A.enqueueAction(objGetOpportunityAction);
        } else {
          component.set("v.boolSpinner", false);
          alert($A.get("$Label.c.OPS_MESSAGE_ONLY_MOBILE_SUPPORT"));
          helper.handleSplitCloseHelper(component);
          $A.get("e.force:closeQuickAction").fire();
        }
      } else {
        component.set("v.boolSpinner", false);
        alert("Problem in connection, please try later.");
      }
    });
    $A.enqueueAction(objGetUIThemeAction);
  },

  handleSaveSplitClickHelper: function (component, helper) {
    if (
      helper.isAllOpportunityLineItemsLostHelper(
        component.get("v.lstOpportunityLineItem")
      )
    ) {
      if (confirm($A.get("$Label.c.OPS_MESSAGE_ALL_LOST_SERVICCES"))) {
        helper.handleSplitCloseHelper(component);
        $A.get("e.force:closeQuickAction").fire();
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
          } else {
            decWonOppSize += lstOpportunityLineItem[index].decTotalPrice;
            decLostOppSize -= lstOpportunityLineItem[index].decTotalPrice;
          }
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
          }
        }
      }
    }

    component.set("v.decWonOppSize", decWonOppSize);
    component.set("v.decLostOppSize", decLostOppSize);
  },

  handleCloselClickHelper: function (component, helper) {
    helper.handleSplitCloseHelper(component);
    $A.get("e.force:closeQuickAction").fire();
  }
});
