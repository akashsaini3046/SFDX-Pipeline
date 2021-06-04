({
  getURLParameter: function (key) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
    var sURLVariables = sPageURL.split("&"); //Split by & so that you get the key value pairs separately in a list
    var sParameterName;
    var i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("="); //to split the key from the value.
      console.log("sParameterName -> ", sParameterName);
      if (sParameterName[0] == key) {
        return sParameterName[1];
      }
    }
    return "";
  },

  getIdeaCommentRecordAction: function (cmp, helper) {
    var commentId = cmp.get("v.ideaCommentId");
    var action = cmp.get("c.getIdeaCommentRecord");
    action.setParams({ ideaCommentId: commentId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ideaCommentRecord = response.getReturnValue();
        console.log("ideaCommentRecord -> ", ideaCommentRecord);
        cmp.set("v.ideaCommentRecord", ideaCommentRecord);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  saveIdeaCommentRecordAction: function (cmp, helper) {
    var comment = cmp.get("v.ideaCommentRecord");
    console.log("comment " + comment);
    console.log(cmp.get("v.ideaRecord"));
    var ideaRec = cmp.get("v.ideaRecord");

    var ideaId = comment.IdeaId;
    var action = cmp.get("c.saveIdeaCommentRecord");
    action.setParams({ comment: comment });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ideaCommentRecord = response.getReturnValue();
        console.log(" ideaCommentRecord " + ideaCommentRecord);
        var ideaCommentsUpdate = [];
        var ideaCommUpdate;
        var ideaCommentsList = cmp.get("v.ideaComments");
        console.log("ideaCommentsList " + ideaCommentsList);

        var ideaCommentRec;
        ideaCommentsList.map((comment) => {
          ideaCommUpdate = comment;
          var ideaCom = comment.ideaComment;
          if (ideaCom.Id === ideaCommentRecord.Id) {
            console.log("Matched");
            ideaCommUpdate.ideaComment.CommentBody =
              ideaCommentRecord.CommentBody;
          }
          ideaCommentsUpdate.push(ideaCommUpdate);
        });
        helper.showToast(
          cmp,
          helper,
          "Success",
          "success!",
          "The record has been updated successfully"
        );
        cmp.set("v.ideaComments", ideaCommentsUpdate);
        cmp.set("v.displayEditIdeaComment", false);
        cmp.set("v.displayIdeaDetail", true);
      } else {
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
  showToast: function (cmp, helper, type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      type: type
    });
    toastEvent.fire();
  }
});
