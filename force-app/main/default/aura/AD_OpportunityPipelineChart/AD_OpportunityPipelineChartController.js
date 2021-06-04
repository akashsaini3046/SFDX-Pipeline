({
  doInit: function (component, event, helper) {},

  generateOpportunityPipelineChart: function (component, event, helper) {
    var objGetOpportunityChartDataAction = component.get(
      "c.getOpportunityChartData"
    );
    component.set("v.boolSpinner", true);

    objGetOpportunityChartDataAction.setParams({
      idAccountId: component.get("v.idAccountId"),
      objMasterFilter: {
        strSelectedYear: component.get("v.strCurrentYear")
      }
    });

    objGetOpportunityChartDataAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set(
          "v.lstSelectedAccountIdsForReport",
          response.getReturnValue().lstFilteredAccounts
        );
        component.set(
          "v.lstSelectedReportYear",
          response.getReturnValue().lstEstDecisionYear
        );
        helper.generateOpportunityPipelineChartHelper(
          component,
          response.getReturnValue()
        );
      } else if (state === "ERROR") {
        alert("Problem with connection. Please try again.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objGetOpportunityChartDataAction);
  },

  handleMasterFilterEvent: function (component, event, helper) {
    var mapMasterEventParams = event.getParam("mapMasterEventParams");
    var objGetOpportunityChartDataAction = component.get(
      "c.getOpportunityChartData"
    );
    component.set("v.boolSpinner", true);

    objGetOpportunityChartDataAction.setParams({
      idAccountId: component.get("v.idAccountId"),
      objMasterFilter: {
        lstSelectedAccounts: mapMasterEventParams.lstSelectedAccounts,
        lstSelectedOwners: mapMasterEventParams.lstSelectedOwners,
        strSelectedTopFilter: mapMasterEventParams.strSelectedTopFilter,
        strSelectedOppSizeFilterOperator:
          mapMasterEventParams.strSelectedOppSizeFilterOperator,
        strOppSizeVal: mapMasterEventParams.strOppSizeVal,
        strSelectedYear: mapMasterEventParams.strSelectedYear
      }
    });

    objGetOpportunityChartDataAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set(
          "v.lstSelectedAccountIdsForReport",
          response.getReturnValue().lstFilteredAccounts
        );
        component.set(
          "v.lstSelectedReportYear",
          response.getReturnValue().lstEstDecisionYear
        );
        helper.generateOpportunityPipelineChartHelper(
          component,
          response.getReturnValue()
        );
      } else if (state === "ERROR") {
        alert("Problem with connection. Please try again.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(objGetOpportunityChartDataAction);
  },

  openReport: function (component, event, helper) {
    var lstStrSelectedAccouts = component.get(
      "v.lstSelectedAccountIdsForReport"
    );
    var lstSelectedReportYear = component.get("v.lstSelectedReportYear");
    var strAccountsCommaSeperateString = "";
    var strSelectedYearCommaSeperateString = "";
    if ($A.util.isEmpty(lstStrSelectedAccouts) == false) {
      strAccountsCommaSeperateString = lstStrSelectedAccouts.join(",");
    }

    if ($A.util.isEmpty(lstSelectedReportYear) == false) {
      strSelectedYearCommaSeperateString = lstSelectedReportYear.join(",");
    }

    var strUrl =
      "/lightning/r/Report/" +
      $A.get("$Label.c.AD_OPP_REPORT_ID") +
      "/view?t=1479844235107&fv0=" +
      strAccountsCommaSeperateString +
      "&fv1=" +
      strSelectedYearCommaSeperateString;
    window.open(strUrl, "_blank");
  }
});
