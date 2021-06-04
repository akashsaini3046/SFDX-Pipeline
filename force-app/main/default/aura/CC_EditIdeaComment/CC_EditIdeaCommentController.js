({
  doInit: function (cmp, event, helper) {
    //var ideaCommentId = helper.getURLParameter('id');
    //  cmp.set("v.ideaCommentId", ideaCommentId);
    console.log("comment record id " + cmp.get("v.ideaCommentId"));
    helper.getIdeaCommentRecordAction(cmp, helper);
  },
  saveCommentHandler: function (cmp, event, helper) {
    helper.saveIdeaCommentRecordAction(cmp, helper);
  },
  cancel: function (cmp, event, helper) {
    // var comment = cmp.get("v.ideaCommentRecord");
    // var ideaId = comment.IdeaId;
    // cmp.set("v.ideaCommentId",ideaId);
    cmp.set("v.ideaRecord", cmp.get("v.ideaRecord"));
    cmp.set("v.displayEditIdeaComment", false);
    cmp.set("v.displayIdeasList", false);
    cmp.set("v.displayIdeaDetail", true);
    cmp.set("v.displayEditIdea", false);
    cmp.set("v.displayNewIdea", false);
    console.log("Exit");
    console.log(
      "v.displayEditIdeaComment  " + cmp.get("v.displayEditIdeaComment")
    );
    console.log("v.displayIdeaDetail" + cmp.get("v.displayIdeaDetail"));
  },
  handleAllIdeasOnclick: function (cmp) {
    cmp.set("v.displayIdeasList", true);
    cmp.set("v.displayIdeaDetail", false);
    cmp.set("v.displayEditIdea", false);
    cmp.set("v.displayNewIdea", false);
    cmp.set("v.displayEditIdeaComment", false);
  }
});
