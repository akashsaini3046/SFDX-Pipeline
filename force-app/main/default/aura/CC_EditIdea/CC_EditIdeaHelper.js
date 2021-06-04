({
  fireHighlightEvent: function (cmp, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = cmp.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  },
  getURLParameter: function (key) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1));
    var sURLVariables = sPageURL.split("&");
    var sParameterName;
    var i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("=");
      if (sParameterName[0] == key) {
        return sParameterName[1];
      }
    }
    return "";
  },
  applyClass: function (cmp) {
    var parentDiv = cmp.find("salesforce-wrap");
    $A.util.addClass(parentDiv, "salesforce-wrapper");
  },
  getIdeaDetails: function (cmp, helper, ideaId) {
    var action = cmp.get("c.getIdeaDetails");
    action.setParams({ ideaId: cmp.get("v.ideaId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("ideaRecord -> ", response.getReturnValue());
        cmp.set("v.ideaRecord", response.getReturnValue());
        var childComp = cmp.find("assignedTo");
        childComp.reInit();
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
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
              cmp
                .find("zones")
                .set("v.value", cmp.get("v.ideaRecord").CommunityId);
              helper.getRelevantPickListValues(
                cmp,
                helper,
                cmp.get("v.ideaRecord").CommunityId
              );
            }
          })
        );
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  saveIdea: function (cmp, event, helper) {
    var result = this.doValidate(cmp);
    var richTextValid = cmp.get("v.validity");
    if (result && richTextValid) {
      console.log("ideaRecord -> ", cmp.get("v.ideaRecord"));
      var ideaRecord = cmp.get("v.ideaRecord");
      var ifRemoveAttachment = cmp.get("v.ifRemoveAttachment");
      if (ifRemoveAttachment) {
        ideaRecord.AttachmentName = null;
        ideaRecord.AttachmentBody = null;
        ideaRecord.AttachmentContentType = null;
        ideaRecord.AttachmentLength = null;
      }
      var ideaId = cmp.get("v.ideaId");
      var action = cmp.get("c.saveIdeaRecord");
      var param = { ideaRecord: ideaRecord };
      console.log(param);
      action.setParams(param);
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          var childComponent = cmp.find("fileUploadCmp");
          //If save is done without uploading or replacing attachment
          if (!childComponent) {
            helper.showToast(
              "success",
              "Success",
              "The record has been updated successfully"
            );
            helper.navigateToDetail(cmp, event);
          } else {
            var message = childComponent.saveFile(result.Id);
          }
        } else {
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
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
    var benefits = cmp.find("benefits");
    var status = cmp.find("status");
    validationArray.push(title);
    validationArray.push(benefits);
    validationArray.push(status);
    if (
      typeof IdeaDescriptionValue == "undefined" ||
      IdeaDescriptionValue.length == 0
    ) {
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
            helper.showToast("error", "Error!", errors[0].message);
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
            helper.showToast("error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  navigateToDetail: function (cmp, event) {
    var navService = cmp.find("navigationService");
    var communityName = cmp.get("v.communityName");
    var pageReference = null;
    if (communityName == null) {
      window.location.href =
        "/lightning/n/idea_detail?c__id=" + cmp.get("v.ideaId");
    } else {
      pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "idea-detail"
        },
        state: {
          id: cmp.get("v.ideaId")
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
  getRelevantRecordTypeId: function (cmp, helper, selectedZoneId) {
    console.log("SELECTED ZONE ID " + selectedZoneId);
    var action = cmp.get("c.getRecordTypeId");
    action.setParams({
      zoneId: selectedZoneId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("getRelevantRecordTypeId state " + state);
      if (state === "SUCCESS") {
        console.log("ínside success");
        console.log("selectedZoneRecordTypeId -> ", response.getReturnValue());
        cmp.set("v.selectedZoneRecordTypeId", response.getReturnValue());
        helper.getRelevantPickListValues(
          cmp,
          helper,
          cmp.get("v.selectedZoneRecordTypeId")
        );
      } else {
        console.log(" getRelevantRecordTypeId failed with state: " + state);
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
        var subcategoriesData = response.getReturnValue()["Subcategory"];
        var status = [];
        var categories = [];
        var benefits = [];
        var subcategories = [];
        console.log("statusData " + JSON.stringify(statusData));
        console.log("categoriesData " + JSON.stringify(categoriesData));
        for (var key in statusData)
          status.push({ label: key, value: statusData[key] });
        for (var key in categoriesData)
          categories.push({ label: key, value: categoriesData[key] });
        for (var key in benefitsData)
          benefits.push({ label: key, value: benefitsData[key] });
        for (var key in subcategoriesData)
          subcategories.push({ label: key, value: subcategoriesData[key] });

        cmp.set("v.benefits", benefits);
        cmp.set("v.ideaStatuses", status);
        cmp.set("v.categoriesOptions", categories);
        cmp.set("v.subcategories", subcategories);

        var categoriesVal = cmp.get("v.ideaRecord.Categories");
        console.log("categoriesVal " + categoriesVal);
        var categoriesValues = [];
        if (categoriesVal) {
          categoriesValues = categoriesVal.split(";");
        }
        // "values" must be a subset of values from "options"
        cmp.set("v.categoriesValues", categoriesValues);

        //  helper.getIdeasListAction(cmp, helper);
      } else {
        console.log(" getRelevantPickListValues failed with state: " + state);
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
