({
  doInit: function (cmp, event, helper) {
    helper.fireHighlightEvent(cmp, event, helper);
    console.log("Inside detail init");
    var idRecordIdea = helper.getURLParameter("id");
    if (idRecordIdea == "") {
      idRecordIdea = helper.getURLParameter("c__id");
    }
    cmp.set("v.ideaId", idRecordIdea);
    helper.fetchIdeaDetails(cmp, helper);
    helper.applyClass(cmp);
    helper.getEnvironment(cmp);
    helper.getCurrentUserAction(cmp, helper, function () {
      helper.getIdeaDescribeResultAction(cmp, helper);
      helper.getIdeaFieldDescribeResultAction(cmp, helper);
      helper.getCommunityNetworkName(cmp, helper);
      helper.getIdeaCommentsAction(cmp, helper, idRecordIdea);
      console.log("Idea Id  repeated " + cmp.get("v.ideaId"));
    });
  },
  editHandler: function (cmp, event, helper) {
    var idRecordIdea = cmp.get("v.ideaId");
    var navService = cmp.find("navigationService");
    var communityName = cmp.get("v.communityName");
    if (communityName == null) {
      window.location.href = "/lightning/n/edit_idea?c__id=" + idRecordIdea;
    } else {
      var pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "edit-idea"
        },
        state: {
          id: idRecordIdea
        }
      };
      navService.navigate(pageReference);
    }
  },
  deleteIdeaHandler: function (cmp, event, helper) {
    helper.deleteIdeaAction(cmp, helper);
  },
  upvoteIdeaHandler: function (cmp, event, helper) {
    var ideaId = cmp.get("v.ideaId");
    helper.upvoteIdeaAction(cmp, helper, ideaId);
  },

  downvoteIdeaHandler: function (cmp, event, helper) {
    var ideaId = cmp.get("v.ideaId");
    helper.downvoteIdeaAction(cmp, helper, ideaId);
  },

  likeCommentHandler: function (cmp, event, helper) {
    console.log("likeCommnet -> ", event.getSource().get("v.value"));
    helper.likeCommentAction(cmp, helper, event.getSource().get("v.value"));
  },

  unlikeCommentHandler: function (cmp, event, helper) {
    console.log("unlikeCommnet -> ", event.getSource().get("v.value"));
    helper.unlikeCommentAction(cmp, helper, event.getSource().get("v.value"));
  },

  editCommentHandler: function (cmp, event, helper) {
    //console.log('editCommnet -> ', event.getSource().get("v.value"));

    var ideaCommentRecordId = event.getSource().get("v.value");
    /*  var ideaCommentList = cmp.get('v.ideaComments');
        var ideaCommentRecord;
        ideaCommentList.map((ideaComment) => {
            if(ideaComment.Id === ideaCommentRecordId){
            	ideaCommentRecord = ideaComment;
        	}
        }); */
    cmp.set("v.ideaCommentId", ideaCommentRecordId);
    console.log("move to " + ideaCommentRecordId);
    //console.log(ideaCommentRecord);
    //cmp.set("v.ideaComment",ideaCommentRecord);
    cmp.set("v.displayEditIdeaComment", true);
  },

  deleteCommentHandler: function (cmp, event, helper) {
    helper.deleteCommentAction(cmp, helper, event.getSource().get("v.value"));
  },

  addCommentHandler: function (cmp, event, helper) {
    helper.addCommentAction(cmp, helper);
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
  }
});
