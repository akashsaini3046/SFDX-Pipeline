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
  getCurrentUserAction: function (cmp, helper, callback) {
    var action = cmp.get("c.getUser");
    console.log("getCurrentUserAction");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("currUser -> ", response.getReturnValue());
        var currUser = response.getReturnValue();
        cmp.set("v.currUser", currUser);
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

  setOtherIdeaInformation: function (cmp, helper, ideaId) {
    var ideaRecord = cmp.get("v.ideaRecord");
    var path =
      "/" +
      cmp.get("v.communityNetworkName") +
      "/servlet/fileField?entityId=" +
      ideaId +
      "&field=AttachmentBody";
    console.log(path);
    cmp.set("v.attachmentURI", path);
    var ideaDescribe = cmp.get("v.ideaDescribe");
    if (!ideaDescribe.idea.updateable) {
      cmp.set(
        "v.disableForm",
        ideaRecord.Status == "Implemented" ? true : false
      );
    }
    helper.checkIsUpvotedorDownvoted(cmp, helper);
  },

  getIdeaCommentsAction: function (cmp, helper, ideaId) {
    var modifiedIdeas = [];
    var action = cmp.get("c.getIdeaComments");
    action.setParams({ ideaId: ideaId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ideaComments = JSON.parse(response.getReturnValue());
        ideaComments.map((idea) => {
          var modIdea = idea;
          if (modIdea.ideaComment.CreatedDate) {
            modIdea.ideaComment.CreatedDate = this.handleDates(
              modIdea.ideaComment.CreatedDate
            );
          }
          modifiedIdeas.push(modIdea);
        });
        console.log("ideaComments -> ", ideaComments);
        console.log("modifiedIdeas ->" + modifiedIdeas);
        cmp.set("v.ideaComments", modifiedIdeas);
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
      } else {
        console.log(state);
      }
    });
    $A.enqueueAction(action);
  },
  handleDates: function (dates) {
    return $A.localizationService.formatDate(dates, "MMM dd, yy,hh:mm a");
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

  upvoteIdeaAction: function (cmp, helper, ideaId) {
    var action = cmp.get("c.upvoteIdea");
    action.setParams({ ideaId: ideaId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("upvoteIdea successful -> ", response.getReturnValue());
        helper.getIdeaDetails(cmp, helper, ideaId);
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

  checkIsUpvotedorDownvoted: function (cmp, helper) {
    var ideaRecord = cmp.get("v.ideaRecord");
    var userRecord = cmp.get("v.currUser");
    cmp.set("v.isUpvoted", false);
    cmp.set("v.isDownvoted", false);
    if (ideaRecord && ideaRecord.Votes && ideaRecord.Votes.length > 0) {
      for (var i = 0; i < ideaRecord.Votes.length; i++) {
        if (ideaRecord.Votes[i].CreatedById == userRecord.Id) {
          if (ideaRecord.Votes[i].Type == "Up") cmp.set("v.isUpvoted", true);
          else cmp.set("v.isDownvoted", true);
        }
      }
    }
  },

  downvoteIdeaAction: function (cmp, helper, ideaId) {
    var action = cmp.get("c.downvoteIdea");
    action.setParams({ ideaId: ideaId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("downvoteIdea successful -> ", response.getReturnValue());
        helper.getIdeaDetails(cmp, helper, ideaId);
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

  likeCommentAction: function (cmp, helper, commentId) {
    var ideaId = cmp.get("v.ideaId");
    var action = cmp.get("c.likeComment");
    action.setParams({ ideaCommentId: commentId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        helper.refreshIdeaDetails(cmp, helper);
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

  unlikeCommentAction: function (cmp, helper, commentId) {
    var ideaId = cmp.get("v.ideaId");
    var action = cmp.get("c.unlikeComment");
    action.setParams({ ideaCommentId: commentId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        helper.refreshIdeaDetails(cmp, helper);
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

  editCommentAction: function (cmp, helper, commentId) {
    // redirect to edit comment component
  },

  deleteCommentAction: function (cmp, helper, commentId) {
    var ideaId = cmp.get("v.ideaId");
    var action = cmp.get("c.deleteComment");
    action.setParams({ ideaCommentId: commentId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        helper.refreshIdeaDetails(cmp, helper);
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

  addCommentAction: function (cmp, helper) {
    var ideaId = cmp.get("v.ideaId");
    var newComment = cmp.get("v.newComment");
    newComment.IdeaId = ideaId;
    var action = cmp.get("c.addComment");
    action.setParams({ param: JSON.stringify(newComment) });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("result -> ", response.getReturnValue());
        helper.refreshIdeaDetails(cmp, helper);
        cmp.set("v.newComment", {});
        helper.showToast(
          cmp,
          helper,
          "success",
          "Success!",
          "Comment added successfully"
        );
      } else if (state === "INCOMPLETE") {
        // do something
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast(
              cmp,
              helper,
              "error",
              "Error!",
              "Please shorten your comment. Max length is 4000 characters."
            );
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  deleteIdeaAction: function (cmp, helper) {
    var ideaId = cmp.get("v.ideaId");
    var action = cmp.get("c.deleteIdeaRecord");
    action.setParams({ ideaId: ideaId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        helper.navigateToAllIdeas(cmp);
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
  navigateToAllIdeas: function (cmp) {
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
  refreshIdeaDetails: function (cmp, helper) {
    var ideaId = cmp.get("v.ideaId");
    helper.getIdeaDetails(cmp, helper, ideaId);
    helper.getIdeaCommentsAction(cmp, helper, ideaId);
  },
  getIdeaDetails: function (cmp, helper, ideaId) {
    var action = cmp.get("c.getIdeaDetails");
    action.setParams({ ideaId: cmp.get("v.ideaId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("ideaRecord -> ", response.getReturnValue());
        var ideaRecord = response.getReturnValue();
        var path =
          "/" +
          cmp.get("v.communityNetworkName") +
          "/servlet/fileField?entityId=" +
          ideaId +
          "&field=AttachmentBody";
        console.log(path);
        cmp.set("v.attachmentURI", path);
        //cmp.set("v.attachmentURI", encodeURI($A.get(cmp.get("v.communityNetworkName") + '/servlet/fileField?entityId='+cmp.get("v.ideaId")+'&field=AttachmentBody'));
        if (ideaRecord.Categories)
          ideaRecord.Categories = ideaRecord.Categories.replace(/;/g, ", ");
        cmp.set("v.ideaRecord", ideaRecord);
        var ideaDescribe = cmp.get("v.ideaDescribe");
        if (!ideaDescribe.idea.updateable) {
          cmp.set(
            "v.disableForm",
            ideaRecord.Status == "Implemented" ? true : false
          );
        }
        helper.checkIsUpvotedorDownvoted(cmp, helper);
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
      } else {
        console.log("Unknown state");
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
  getCommunityNetworkName: function (cmp, helper) {
    console.log("inside getCommunityNetworkName");
    var action = cmp.get("c.getCommunityNetworkName");
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("STATE " + state);
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        cmp.set("v.communityNetworkName", response.getReturnValue());
      } else {
        console.log("Error in getCommunityNetworkName(CC_IdeaDetail) ");
      }
      helper.setOtherIdeaInformation(cmp, helper, cmp.get("v.ideaRecord").Id);
    });
    $A.enqueueAction(action);
  },
  fetchIdeaDetails: function (cmp, helper) {
    var action = cmp.get("c.getIdeaDetails");
    var idRecordIdea = cmp.get("v.ideaId");
    action.setParams({ ideaId: idRecordIdea });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ideaRecord = response.getReturnValue();
        cmp.set("v.ideaRecord", ideaRecord);
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
  },
  getEnvironment: function (cmp, helper) {
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
