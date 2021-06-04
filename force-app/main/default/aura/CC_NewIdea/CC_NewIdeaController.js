({
  doInit: function (cmp, event, helper) {
    helper.fireHighlightEvent(cmp, event, helper);
    helper.getIdeaFieldDescribeResultAction(cmp, helper);
    helper.getIdeaDescribeResultAction(cmp, helper);
    cmp.set("v.ideaRecord", {});
    helper.applyClass(cmp);
    helper.getEnvironment(cmp);
    helper.getZonesList(cmp, helper);
    helper.getCommunityNetworkName(cmp);
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

  cancel: function (cmp) {
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
  onZoneChange: function (cmp, event, helper) {
    console.log(cmp.get("v.ideaRecord"));
    console.log("onZoneChange", cmp.find("zones").get("v.value"));
    cmp.set("v.ideaRecord.CommunityId", cmp.find("zones").get("v.value"));
    console.log(
      'cmp.get("v.ideaRecord.CommunityId")' +
        cmp.get("v.ideaRecord.CommunityId")
    );
    helper.getRelevantPickListValues(
      cmp,
      helper,
      cmp.get("v.ideaRecord.CommunityId")
    );
  },

  findSimilarIdeasKeyupHandler: function (cmp, event, helper) {
    console.log(
      "find similar idea for title -> ",
      cmp.find("title").get("v.value")
    );
    helper.findSimilarIdeasAction(
      cmp,
      helper,
      cmp.get("v.ideaRecord.CommunityId"),
      cmp.find("title").get("v.value")
    );
  },

  handleFilesChange: function (cmp, event) {
    var fileName = "No File Selected..";
    if (event.getSource().get("v.files").length > 0) {
      fileName = event.getSource().get("v.files")[0]["name"];
    }
    cmp.set("v.fileName", fileName);
  },

  handleFileUploadEvent: function (cmp, event, helper) {
    var state = event.getParam("state");
    if (state == "SUCCESS") {
      helper.getIdeaDetails(cmp, helper);
      helper.showToast(
        "success",
        "Success",
        "The record has been uploaded successfully"
      );
      helper.navigateToIdeaList(cmp);
    } else {
      helper.showToast("error", "Failed", event.getParam("message"));
      helper.navigateToIdeaList(cmp);
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
  navigateToHome: function (cmp) {
    var navService = cmp.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  }
});
