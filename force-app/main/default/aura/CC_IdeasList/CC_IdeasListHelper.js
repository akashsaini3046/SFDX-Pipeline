({
  fireHighlightEvent: function (cmp, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = cmp.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  },
  applyClass: function (cmp) {
    var parentDiv = cmp.find("salesforce-wrap");
    $A.util.addClass(parentDiv, "salesforce-wrapper");
  },
  getIdeasListAction: function (cmp, event, helper, limit, offset) {
    var action = cmp.get("c.getIdeasList");
    var communityId = cmp.get("v.selectedCommunityId");
    action.setParams({
      communityId: cmp.get("v.selectedCommunityId"),
      statuses: cmp.get("v.selectedStatuses"),
      searchText: cmp.get("v.searchText"),
      categories: cmp.get("v.selectedCategories"),
      recordLimit: limit,
      offset: offset
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ideas = response.getReturnValue();
        var ideasPage = [];
        for (var i = 0; i < ideas.length; i++) {
          if (ideas[i].Categories) {
            ideas[i].Categories = ideas[i].Categories.replace(/;/g, ", ");
          }
          ideasPage.push(ideas[i]);
        }
        cmp.set("v.ideasPage", ideasPage);
        cmp.set("v.ideasList", ideas);
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
      cmp.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  upvoteIdeaAction: function (cmp, helper, ideaId) {
    var action = cmp.get("c.upvoteIdea");
    var limit = cmp.get("v.showRecords");
    var offset = cmp.get("v.startRange") - 1;
    action.setParams({
      ideaId: ideaId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        helper.getIdeasListAction(cmp, event, helper, limit, offset);
        //helper.fetchIdeaTotalVotes(cmp,ideaId);
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
  downvoteIdeaAction: function (cmp, helper, ideaId) {
    var action = cmp.get("c.downvoteIdea");
    var limit = cmp.get("v.showRecords");
    var offset = cmp.get("v.startRange") - 1;
    action.setParams({
      ideaId: ideaId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        helper.getIdeasListAction(cmp, event, helper, limit, offset);
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

  getCurrentUserAction: function (cmp, helper) {
    var action = cmp.get("c.getUser");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("currUser -> ", response.getReturnValue());
        var currUser = response.getReturnValue();
        cmp.set("v.currUser", currUser);
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

  getZoneOptions: function (cmp, event, helper) {
    var action = cmp.get("c.getZonesList");
    //var selectedZoneId;
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("getZonesList", response.getReturnValue());
        var zones = JSON.parse(response.getReturnValue());
        cmp.set("v.zonesOptions", zones);
        if (zones && zones.length > 0) {
          //selectedZoneId = zones[0].Id;
          //cmp.set("v.selectedCommunityId", selectedZoneId);
          helper.fetchIdeasInitial(cmp);
          //console.log('selectedZoneId', selectedZoneId);
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  getIdeaDescribeResultAction: function (cmp, helper) {
    var action = cmp.get("c.getIdeaDescribe");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        cmp.set("v.ideaDescribe", JSON.parse(response.getReturnValue()));
        console.log("describe set");
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
  showToast: function (cmp, helper, type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      type: type
    });
    toastEvent.fire();
  },

  getRelevantRecTypIdPicklistValues: function (
    cmp,
    event,
    helper,
    selectedZoneId
  ) {
    var zoneId;
    if (selectedZoneId) {
      zoneId = selectedZoneId;
    } else {
      zoneId = null;
    }
    var action = cmp.get("c.fetchRecordTypeSpecificPickListvalues");
    action.setParams({
      zoneId: zoneId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("PicklistValues -> ", response.getReturnValue());
        var statusData = response.getReturnValue()["Status"];
        var categoriesData = response.getReturnValue()["Categories"];
        var status = [];
        var categories = [];
        for (var key in statusData) {
          status.push({ label: key, value: statusData[key] });
        }
        for (var key in categoriesData) {
          categories.push({ label: key, value: categoriesData[key] });
        }
        cmp.set("v.ideaStatuses", status);
        cmp.set("v.categoriesOptions", categories);
      } else {
        console.log(" getRelevantPickListValues failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  fetchIdeaTotalVotes: function (cmp, ideaId) {
    var action = cmp.get("c.getTotalVotes");
    action.setParams({
      ideaId: ideaId
    });
    console.log("fetchIdeaTotalVotes");
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state  " + state);
      if (state === "SUCCESS") {
        // var ideaRecordId=event.target.id;
        console.log("Prom Points " + response.getReturnValue());
        var ideaList = cmp.get("v.ideasPage");
        var ideaUpdatedList = [];
        var ideaRecord;
        ideaList.map((idea) => {
          if (idea.Id === ideaId) {
            idea.VoteTotal = response.getReturnValue();
          }
          ideaUpdatedList.push(idea);
        });
        cmp.set("v.ideasPage", ideaUpdatedList);
      }
    });
    $A.enqueueAction(action);
  },
  fetchIdeasInitial: function (cmp) {
    var action = cmp.get("c.getAllIdeas");
    action.setParams({
      idSelectedZone: cmp.get("v.selectedCommunityId"),
      statuses: cmp.get("v.selectedStatuses"),
      searchText: cmp.get("v.searchText"),
      categories: cmp.get("v.selectedCategories")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ideas = response.getReturnValue();
        if (ideas != 0) {
          cmp.set("v.totalRange", ideas);
        }
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
  fetchAllIdeas: function (cmp, helper, callback) {
    var action = cmp.get("c.getAllIdeas");
    action.setParams({
      idSelectedZone: cmp.get("v.selectedCommunityId"),
      statuses: cmp.get("v.selectedStatuses"),
      searchText: cmp.get("v.searchText"),
      categories: cmp.get("v.selectedCategories")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ideas = response.getReturnValue();
        if (ideas != 0) {
          cmp.set("v.totalRange", ideas);
          cmp.set("v.showRecords", 10);
          cmp.set("v.startRange", 1);
          cmp.set("v.endRange", 10);
        }
        callback();
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
