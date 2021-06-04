/*
 * @company		: Nagarro Inc.
 * @date		: 20-07-2020
 * @author		: Nagarro
 * @description	: To send email when a new idea is posted or an idea is 'Implemented and closed'
 * @history		: Version 1.0
 * @test class	: CC_IdeasEmailServiceTest
 */
public without sharing class CC_IdeasEmailService {
  /*
   * @purpose		: Method to send notification to the moderator group when an idea is posted
   * @parameter   : List of the newly created ideas
   */

  public static void sendNotificationIdeaPost(List<Idea> ideasList) {
    List<Messaging.SingleEmailMessage> emailMsgs = new List<Messaging.SingleEmailMessage>();
    Group grp = IdeaDAO.getGroupByName(CC_Constants.IDEA_MODERATOR_GROUP);
    Id templateId = IdeaDAO.getEmailTemplateByName(
        CC_Constants.CC_NEWIDEAPOSTED
      )
      .id;
    List<GroupMember> members = IdeaDAO.getGroupMembers(grp.Id);
    for (Idea idea : ideasList) {
      for (GroupMember member : members) {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(templateId);
        msg.setWhatId(idea.Id);
        msg.setTargetObjectId(member.UserorGroupId);
        msg.setSaveAsActivity(false);
        emailMsgs.add(msg);
      }
    }
    sendEmail(emailMsgs);
  }

  /*
   * @purpose		: Method to send notification to the users who created the idea and upvoted an idea when it is implemented and closed
   * @parameter   : List of the newly created ideas
   */
  public static void sendNotificationIdeaImplemented(List<Idea> ideasList) {
    List<Idea> implementedIdeas = new List<Idea>();
    List<Id> ideaIds = new List<Id>();
    for (Idea idea : ideasList) {
      if (idea.Status == CC_Constants.IMPLEMENTED_AND_CLOSED) {
        ideaIds.add(idea.Id);
        implementedIdeas.add(idea);
      }
    }

    if (!implementedIdeas.isEmpty()) {
      Id ideaId = ideaIds[0];
      Set<Id> userids = new Set<Id>();
      for (Vote voteObj : [
        SELECT Id, ParentId, LastModifiedById, CreatedById
        FROM Vote
        WHERE ParentId = :ideaId
      ]) {
        userids.add(voteObj.CreatedById);
      }
      Id templateId = IdeaDAO.getEmailTemplateByName(
          CC_Constants.CC_IDEADELIVERED
        )
        .id;
      List<Messaging.SingleEmailMessage> emailMsgs = new List<Messaging.SingleEmailMessage>();
      for (Idea idea : implementedIdeas) {
        for (Id userId : userids) {
          Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
          msg.setTemplateId(templateId);
          msg.setWhatId(idea.Id);
          System.debug('@@beforewhatId' + msg);
          msg.setTargetObjectId(userId);
          msg.setSaveAsActivity(false);
          emailMsgs.add(msg);
        }
      }
      sendEmail(emailMsgs);
    }
  }

  /*
   * @purpose		: Method to send emails which are passed as a parameter
   * @parameter   : List of Messaging.SingleEmailMessage
   */
  public static void sendEmail(List<Messaging.SingleEmailMessage> emailMsgs) {
    List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailMsgs);
    for (Messaging.SendEmailResult res : results) {
      if (!res.isSuccess()) {
        for (Messaging.SendEmailError err : res.getErrors()) {
          LogFactory.error(
            'CC_IdeasEmailService',
            'sendEmail',
            'Error',
            err.getStatusCode() +
            '  ' +
            err.getMessage()
          );
        }
      }
    }
    LogFactory.saveLog();
  }
}
