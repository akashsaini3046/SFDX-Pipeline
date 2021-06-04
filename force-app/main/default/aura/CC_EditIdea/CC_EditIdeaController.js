({
  doInit: function (cmp, event, helper) {
    helper.fireHighlightEvent(cmp, event, helper);
    helper.getIdeaDescribeResultAction(cmp, helper);
    helper.getIdeaFieldDescribeResultAction(cmp, helper);
    helper.applyClass(cmp);
    helper.getEnvironment(cmp);
    var idRecordIdea = helper.getURLParameter("id");
    if (idRecordIdea == "") {
      idRecordIdea = helper.getURLParameter("c__id");
    }
    if (idRecordIdea) {
      cmp.set("v.ideaId", idRecordIdea);
      helper.getIdeaDetails(cmp, helper, idRecordIdea);
      helper.getZonesList(cmp, helper);
    }
  },

  handleCategoriesChange: function (cmp, event) {
    // This will contain an array of the "value" attribute of the selected options
    var selectedOptionValue = event.getParam("value");
    var categories = selectedOptionValue.toString().split(",").join(";");
    console.log("handleCategoriesChange : categories -> ", categories);
    cmp.set("v.ideaRecord.Categories", categories);
    console.log("Categories values -> ", cmp.get("v.categoriesValues"));
  },
  handleMaxSizeError: function (cmp, event, helper) {
    var fileStatus = event.getParam("fileStatus");
    if (fileStatus == "false") {
      helper.showToast(
        "error",
        "Failed",
        "Please select the file less than 4.5 mb"
      );
      cmp.set("v.btnStatus", true);
    } else {
      cmp.set("v.btnStatus", false);
    }
  },
  saveIdea: function (cmp, event, helper) {
    helper.saveIdea(cmp, event, helper);
  },

  removeAttachment: function (cmp) {
    cmp.set("v.ifRemoveAttachment", true);
    cmp.set("v.btnStatus", false);
  },

  undoRemoveAttachment: function (cmp) {
    cmp.set("v.ifRemoveAttachment", false);
    cmp.set("v.btnStatus", false);
  },

  handleFileUploadEvent: function (cmp, event, helper) {
    var state = event.getParam("state");
    if (state == "SUCCESS") {
      helper.showToast(
        "success",
        "Success",
        "The record has been updated successfully"
      );
      helper.navigateToDetail(cmp, event);
    } else {
      helper.showToast("error", "Failed", event.getParam("message"));
      helper.navigateToDetail(cmp, event);
    }
  },
  handleAllIdeasOnclick: function (cmp) {
    var navService = cmp.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "ideas"
      }
    };
    navService.navigate(pageReference);
  },
  handleCancel: function (cmp) {
    var idRecordIdea = cmp.get("v.ideaId");
    var navService = cmp.find("navigationService");
    var communityName = cmp.get("v.communityName");
    var pageReference = null;
    if (communityName == null) {
      window.location.href = "/lightning/n/idea_detail?c__id=" + idRecordIdea;
    } else {
      pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "idea-detail"
        },
        state: {
          id: idRecordIdea
        }
      };
      navService.navigate(pageReference);
    }
  },
  handlePostIdea: function (cmp) {
    var navService = cmp.find("navigationService");
    var communityName = cmp.get("v.communityName");
    if (communityName == null) {
      window.location.href = "/lightning/n/new_idea";
    } else {
      var pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "new-idea"
        }
      };
      navService.navigate(pageReference);
    }
  },
  navigateToHome: function (cmp) {
    var navService = cmp.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  },
  handleIdeaDetail: function (cmp) {
    var navService = cmp.find("navigationService");
    var idRecordIdea = cmp.get("v.ideaId");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "idea-detail"
      },
      state: {
        id: idRecordIdea
      }
    };
    navService.navigate(pageReference);
  },
  changeItemId: function (component, event) {
    console.log("handle it");
    var idea = component.get("v.ideaRecord");
    var IdSelected = event.getParams()["selectedItemID"];
    console.log("IdSelected " + IdSelected);
    idea.Assigned_To__c = IdSelected;
    component.set("v.ideaRecord", idea);
    console.log(component.get("v.ideaRecord").Assigned_To__c);
    console.log("ending");
  }
});
