({
  fireHighlightEvent: function (cmp, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = cmp.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  },
  getZonesList: function (cmp, helper) {
    var action = cmp.get("c.getZonesList");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("getZonesList", response.getReturnValue());
        cmp.set("v.zonesOptions", JSON.parse(response.getReturnValue()));
        // Let DOM state catch up.
        window.setTimeout(
          $A.getCallback(function () {
            // Now set our preferred value
            if (cmp.get("v.ideaRecord")) {
              cmp.find("zones").set("v.value", cmp.get("v.zonesOptions")[0].Id);
              cmp.set(
                "v.ideaRecord.CommunityId",
                cmp.get("v.zonesOptions")[0].Id
              );
              helper.getRelevantPickListValues(
                cmp,
                helper,
                cmp.get("v.zonesOptions")[0].Id
              );
            }
          })
        );
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  applyClass: function (cmp) {
    var parentDiv = cmp.find("salesforce-wrap");
    $A.util.addClass(parentDiv, "salesforce-wrapper");
  },
  saveIdea: function (cmp, event, helper) {
    var result = this.doValidate(cmp);
    var richTextValid = cmp.get("v.validity");
    if (result && richTextValid) {
      console.log("ideaRecord -> ", cmp.get("v.ideaRecord"));
      var ideaRecord = cmp.get("v.ideaRecord");
      ideaRecord.Subcategory__c = "Salesforce";
      var action = cmp.get("c.saveIdeaRecord");
      var param = { ideaRecord: ideaRecord };
      console.log(param);
      action.setParams(param);
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          console.log("result -> ", result);
          if (result.Id) {
            cmp.set("v.ideaId", result.Id);
            // calling method of the child component "fileUploadCmp"
            // for saving an uploaded file on Idea
            var childComponent = cmp.find("fileUploadCmp");
            var message = childComponent.saveFile(cmp.get("v.ideaId"));
            console.log("message@@" + message);
          }
          //helper.navigateToIdeaList(cmp);
        } else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              //helper.navigateToIdeaList(cmp);
              console.log("Error message: " + errors[0].message);
              //helper.showToast('error', 'Error!', errors[0].message);
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
  doValidate: function (cmp) {
    var validationArray = [];
    var title = cmp.find("title");
    var IdeaDescription = cmp.find("ideaBody");
    var IdeaDescriptionValue = cmp.find("ideaBody").get("v.value");
    var benifits = cmp.find("benefits");
    validationArray.push(title);
    validationArray.push(benifits);
    if (typeof IdeaDescriptionValue == "undefined") {
      cmp.set("v.validity", false);
    } else {
      cmp.set("v.validity", true);
    }
    var result = validationArray.reduce(function (validFields, inputCmp) {
      inputCmp.showHelpMessageIfInvalid();
      return validFields && inputCmp.get("v.validity").valid;
    }, true);
    return result;
  },
  navigateToIdeaList: function (cmp) {
    var navService = cmp.find("navigationService");
    var communityName = cmp.get("v.communityName");
    var pageReference = null;
    if (communityName == null) {
      window.location.href = "/lightning/n/ideas";
    } else {
      var pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "ideas"
        }
      };
      navService.navigate(pageReference);
    }
  },
  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: type,
      title: title,
      message: message
    });
    toastEvent.fire();
  },

  findSimilarIdeasAction: function (cmp, helper, communityId, title) {
    var action = cmp.get("c.findSimilarIdeas");
    var param = { communityId: communityId, title: title };
    console.log("findSimilarIdeas param -> ", param);
    action.setParams(param);
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("similar ideas -> ", response.getReturnValue());
        cmp.set("v.similarIdeas", response.getReturnValue());
        helper.showToast("Success", "The record has been updated successfully");
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  getIdeaFieldDescribeResultAction: function (cmp, helper) {
    var action = cmp.get("c.getIdeaFieldDescribe");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(
          "getIdeaFieldDescribe -> ",
          JSON.parse(response.getReturnValue())
        );
        cmp.set("v.ideaFieldDescribe", JSON.parse(response.getReturnValue()));
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast(cmp, helper, "error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  getIdeaDescribeResultAction: function (cmp, helper) {
    var action = cmp.get("c.getIdeaDescribe");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(
          "getIdeaDescribeResult -> ",
          JSON.parse(response.getReturnValue())
        );
        cmp.set("v.ideaDescribe", JSON.parse(response.getReturnValue()));
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast(cmp, helper, "error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  getIdeaDetails: function (cmp, helper) {
    console.log("Inside getIdeaDetails ");
    var action = cmp.get("c.getIdeaDetails");
    action.setParams({ ideaId: cmp.get("v.ideaId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("ideaRecord -> ", response.getReturnValue());
        cmp.set("v.ideaRecord", response.getReturnValue());
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  getRelevantPickListValues: function (cmp, helper, communityZoneId) {
    console.log("getRelevantPickListValues  " + communityZoneId);
    var action = cmp.get("c.fetchRecordTypeSpecificPickListvalues");
    action.setParams({
      zoneId: communityZoneId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("PicklistValues -> ", response.getReturnValue());
        var statusData = response.getReturnValue()["Status"];
        var categoriesData = response.getReturnValue()["Categories"];
        var benefitsData = response.getReturnValue()["Benefits"];
        var status = [];
        var categories = [];
        var benefits = [];
        console.log("statusData " + JSON.stringify(statusData));
        console.log("categoriesData " + JSON.stringify(categoriesData));
        console.log("benefitsData " + JSON.stringify(benefitsData));
        for (var key in statusData)
          status.push({ label: key, value: statusData[key] });
        for (var key in categoriesData)
          categories.push({ label: key, value: categoriesData[key] });
        for (var key in benefitsData)
          benefits.push({ label: key, value: benefitsData[key] });
        cmp.set("v.benefits", benefits);
        cmp.set("v.ideaStatuses", status);
        cmp.set("v.categoriesOptions", categories);
        cmp.set("v.ideaRecord.Benefits__c", "Business Requirement");
      } else {
        console.log(" getRelevantPickListValues failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  getCommunityNetworkName: function (cmp) {
    console.log("getCommunityNetworkName");
    var action = cmp.get("c.getCommunityNetworkName");
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state : " + state);
      if (state === "SUCCESS") {
        if (response.getReturnValue() !== null)
          cmp.set(
            "v.urlPrefix",
            "/" + response.getReturnValue() + "/s/idea-detail?id="
          );
        if (response.getReturnValue() === null)
          cmp.set(
            "v.urlPrefix",
            "https://crowley2--uat.lightning.force.com/lightning/n/idea_detail?c__id="
          ); //lightning/n/Test_Cmp?c__accname=ajay
      } else {
        console.log(" getCommunityNetworkName failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  getEnvironment: function (cmp) {
    var action = cmp.get("c.getCommunityNetworkName");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var communityName = response.getReturnValue();
        var imageDiv = cmp.find("idea-image");
        if (communityName != null) {
          cmp.set("v.communityName", communityName);
          $A.util.addClass(imageDiv, "idea-poster");
        } else {
          $A.util.addClass(imageDiv, "idea-poster-salesforce");
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});
