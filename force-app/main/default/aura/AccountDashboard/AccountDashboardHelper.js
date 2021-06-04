({
  createMasterFilterComponentsHelper: function (component) {
    //Create filter component
    $A.createComponent(
      "c:AD_MasterFilterComponent",
      {
        idAccountId: component.get("v.idAccountId"),
        strCurrentYear: component.get("v.strCurrentYear")
      },
      function (newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var objFilterComponentDiv = component.find("filterComponentDiv");
          objFilterComponentDiv.set("v.body", [newComponent]);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  },

  createOpportunityPipelineComponentsHelper: function (component) {
    //Create filter component
    $A.createComponent(
      "c:AD_OpportunityPipelineChart",
      {
        idAccountId: component.get("v.idAccountId"),
        strCurrentYear: component.get("v.strCurrentYear")
      },
      function (newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var objOpportunityChartComponentDiv = component.find(
            "opportunityChartComponentDiv"
          );
          objOpportunityChartComponentDiv.set("v.body", [newComponent]);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  },

  createOpportunityConversionRateComponentsHelper: function (component) {
    //Create filter component
    $A.createComponent(
      "c:AD_OpportunityConversionRateComponent",
      {
        idAccountId: component.get("v.idAccountId"),
        strCurrentYear: component.get("v.strCurrentYear")
      },
      function (newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var objOpportunityConversionRateComponentDiv = component.find(
            "opportunityConversionRateComponentDiv"
          );
          objOpportunityConversionRateComponentDiv.set("v.body", [
            newComponent
          ]);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  },

  createActualVsNormalisedRevenue: function (component) {
    //Create filter component
    $A.createComponent(
      "c:ActualVsNormalisedRevenue",
      {
        recordId: component.get("v.idAccountId"),
        strCurrentYear: component.get("v.strCurrentYear")
      },
      function (newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var objactualVsNormalisedRevenueComponentDiv = component.find(
            "actualVsNormalisedRevenue"
          );
          objactualVsNormalisedRevenueComponentDiv.set("v.body", [
            newComponent
          ]);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  },

  createTaskComponentsHelper: function (component) {
    //Create filter component
    $A.createComponent(
      "c:Tasks",
      {
        recordId: component.get("v.idAccountId"),
        strCurrentYear: component.get("v.strCurrentYear")
      },
      function (newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var objtaskComponentDivComponentDiv = component.find(
            "taskComponentDiv"
          );
          objtaskComponentDivComponentDiv.set("v.body", [newComponent]);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  },

  createNotesComponentsHelper: function (component) {
    //Create filter component
    $A.createComponent(
      "c:Notes",
      {
        recordId: component.get("v.idAccountId"),
        strCurrentYear: component.get("v.strCurrentYear")
      },
      function (newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var objnotesComponentDivComponentDiv = component.find(
            "notesComponentDiv"
          );
          objnotesComponentDivComponentDiv.set("v.body", [newComponent]);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  },

  createActualValueComponentsHelper: function (component) {
    //Create filter component
    $A.createComponent(
      "c:AD_ActualValueComponent",
      {},
      function (newComponent, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          var objActualValueComponentDiv = component.find("actualValue");
          objActualValueComponentDiv.set("v.body", [newComponent]);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  }
});
