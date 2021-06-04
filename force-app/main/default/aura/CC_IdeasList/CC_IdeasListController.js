({
  /**
   * @description Get permission values for Idea object and its fields.
   * Initialize picklist of communities, categories, idea statuses
   */
  doInit: function (cmp, event, helper) {
    console.log("Inside list init");
    var limit = cmp.get("v.showRecords");
    var offset = cmp.get("v.startRange") - 1;
    helper.fireHighlightEvent(cmp, event, helper);
    helper.applyClass(cmp);
    helper.getEnvironment(cmp);
    helper.getIdeasListAction(cmp, event, helper, limit, offset);
    helper.getZoneOptions(cmp, event, helper);
    helper.getRelevantRecTypIdPicklistValues(cmp, event, helper);
    helper.getIdeaDescribeResultAction(cmp, helper);
    console.log("after init");
  },
  upvoteIdeaHandler: function (cmp, event, helper) {
    helper.upvoteIdeaAction(cmp, helper, event.getSource().get("v.value"));
  },
  downvoteIdeaHandler: function (cmp, event, helper) {
    helper.downvoteIdeaAction(cmp, helper, event.getSource().get("v.value"));
  },
  searchByText: function (cmp, event, helper) {
    var limit = 10;
    var offset = 0;
    helper.fetchAllIdeas(cmp, helper, function () {
      helper.getIdeasListAction(cmp, event, helper, limit, offset);
    });
  },
  handlePagination: function (cmp, event, helper) {
    var params = event.getParams();
    helper.getIdeasListAction(
      cmp,
      event,
      helper,
      params["limit"],
      params["offset"]
    );
  },
  applyChanges: function (cmp, event, helper) {
    var limit = 10;
    var offset = 0;
    cmp.set("v.loading", true);
    helper.fetchAllIdeas(cmp, helper, function () {
      helper.getIdeasListAction(cmp, event, helper, limit, offset);
    });
  },
  handleOpenIdea: function (cmp, event, helper) {
    var selectedIdeaId = event.target.id;
    var navService = cmp.find("navigationService");
    var communityName = cmp.get("v.communityName");
    var pageReference = null;
    if (communityName == null) {
      window.location.href = "/lightning/n/idea_detail?c__id=" + selectedIdeaId;
    } else {
      pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "idea-detail"
        },
        state: {
          id: selectedIdeaId
        }
      };
      navService.navigate(pageReference);
    }
  },
  navigateToHome: function (cmp, event, helper) {
    var navService = cmp.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  },
  handleIdeaPost: function (cmp) {
    var navService = cmp.find("navigationService");
    var communityName = cmp.get("v.communityName");
    var pageReference = null;
    if (communityName == null) {
      window.location.href = "/lightning/n/new_idea";
    } else {
      pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "new-idea"
        }
      };
      navService.navigate(pageReference);
    }
  }
});
