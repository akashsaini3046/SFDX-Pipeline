/*
 * @company     : Nagarro Inc.
 * @date        : 16-07-2020
 * @author      : Nagarro
 * @description : To get information about Idea and Related Objects
 * @history     : Version 1.0
 * @test class  : IdeaDAOTest
 */
public without sharing class CC_IdeaDetailController {
  public class SObjectDescribe {
    @AuraEnabled
    public boolean updateable { get; set; }
    @AuraEnabled
    public boolean accessible { get; set; }
    @AuraEnabled
    public boolean deletable { get; set; }
    @AuraEnabled
    public boolean createable { get; set; }
  }
  public class SObjectFieldDescribe {
    @AuraEnabled
    public boolean updateable { get; set; }
    @AuraEnabled
    public boolean accessible { get; set; }
  }

  /*
   * @purpose     : Method to get Idea details .
   * @parameter   : ideaId - Id of the Idea be fetched
   * @return      : Idea - Idea record for the given idea Id.
   */
  @AuraEnabled
  public static Idea getIdeaDetails(Id ideaId) {
    try {
      return IdeaDAO.getIdeaWithAllFields(ideaId);
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'getIdeaDetails',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to get user detail of the current logged in user.
   * @return      : User - User record for the given current logged in user.
   */
  @AuraEnabled
  public static User getUser() {
    Id userId = UserInfo.getUserId();
    return IdeaDAO.getUserDetails(userId);
  }
  /*
   * @purpose     : Method to get the count of all the Idea Records.
   * @return      : totalRecords - count of all the records for Ideas.
   */
  @AuraEnabled
  public static Integer getAllIdeas(
    String idSelectedZone,
    String statuses,
    String searchText,
    String categories
  ) {
    Integer totalRecords = IdeaDAO.getAllIdeas(
      idSelectedZone,
      statuses,
      searchText,
      categories
    );
    return totalRecords;
  }
  /*
   * @purpose     : Method to get community zones detail .
   * @return      : String - Community Zones Information.
   */
  @AuraEnabled
  public static String getZonesList() {
    List<Community> communityList = IdeaDAO.getActiveCommunity();
    return JSON.serialize(communityList);
  }

  /*
   * @purpose     : Method to save the idea Record.
   * @parameter   : ideaRecord - ideaRecord to be saved
   * @return      : Idea - Idea record that was saved
   */
  @AuraEnabled
  public static Idea saveIdeaRecord(Idea ideaRecord) {
    try {
      if (String.isBlank(ideaRecord.Id) && String.isBlank(ideaRecord.Status)) {
        for (
          Schema.PicklistEntry entry : Idea.getSobjectType()
            .getDescribe()
            .fields.getMap()
            .get(CC_Constants.STATUS)
            .getDescribe()
            .getPicklistValues()
        ) {
          if (entry.isDefaultValue()) {
            ideaRecord.Status = entry.getValue();
          }
        }
      }
      upsert ideaRecord;
      System.debug('ideaRecord@@@' + ideaRecord);
      return ideaRecord;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'saveIdeaRecord',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      if (ex.getMessage().contains('REQUIRED_FIELD_MISSING')) {
        throw new CC_IdeaCustomException('Please fill all required fields');
      } else {
        throw new CC_IdeaCustomException(
          'Something went wrong!! ' + ex.getMessage()
        );
      }
    }
  }

  /*
   * @purpose     : Method to delete the idea Record
   * @parameter   : ideaId - Id of the idea to be deleted
   * @return      : Idea - Idea record that was deleted.
   */
  @AuraEnabled
  public static Idea deleteIdeaRecord(Id ideaId) {
    try {
      List<Idea> ideaList = new List<Idea>();
      Idea ideaRecord = new Idea();
      ideaRecord.Id = ideaId;
      ideaList.add(ideaRecord);
      DMLUtility.deleteRecords(ideaList, true);
      return ideaRecord;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'saveIdeaRecord',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to get similar Ideas already in the database.
   * @parameter   : communityId - Id of the communityZone
   * @parameter   : tile - Title of idea , using is trying to create
   * @return      : List<Id> - List of similar ideas
   */
  @AuraEnabled
  public static List<Idea> findSimilarIdeas(string communityId, string title) {
    Idea ideaRecord = new Idea();
    ideaRecord.Title = title;
    ideaRecord.CommunityId = communityId;
    List<Id> similarIdeasIds = Ideas.findSimilar(ideaRecord);
    Set<Id> similarIdeaIdsSet = new Set<Id>(similarIdeasIds);
    List<Idea> similarIdeas = new List<Idea>();
    if (similarIdeaIdsSet != null && !similarIdeaIdsSet.isEmpty()) {
      similarIdeas = IdeaDAO.getIdeaListByIds(similarIdeaIdsSet);
    }

    return similarIdeas;
  }

  /*
   * @purpose     : Method to get the Idea object's fields accessibility for the current user
   * @return      : String - Idea object's fields accessibility for the current user
   */
  @AuraEnabled
  public static string getIdeaFieldDescribe() {
    Map<string, SobjectFieldDescribe> result = new Map<string, SobjectFieldDescribe>();
    Map<string, Schema.SObjectField> fieldsMap = Idea.SobjectType.getDescribe()
      .fields.getMap();
    for (string field : fieldsMap.keyset()) {
      SObjectFieldDescribe fieldDesc = new SObjectFieldDescribe();
      fieldDesc.updateable = fieldsMap.get(field).getDescribe().isUpdateable();
      fieldDesc.accessible = fieldsMap.get(field).getDescribe().isAccessible();
      result.put(field, fieldDesc);
    }
    return JSON.serialize(result);
  }

  /*
   * @purpose     : Method to get the Idea object's  accessibility for the current user
   * @return      : String - Idea object's  accessibility for the current user
   */
  @AuraEnabled
  public static string getIdeaDescribe() {
    Map<string, SobjectDescribe> result = new Map<string, SobjectDescribe>();
    SObjectDescribe ideaDesc = new SObjectDescribe();
    /*ideaDesc.updateable = Idea.SobjectType.getDescribe().isUpdateable();
        ideaDesc.accessible = Idea.SobjectType.getDescribe().isAccessible();
        ideaDesc.deletable = Idea.SobjectType.getDescribe().isDeletable();
        ideaDesc.createable = Idea.SobjectType.getDescribe().isCreateable();*/
    Id userId = UserInfo.getUserId();
    CC_UserPermissionUtility.permissionReport userpermissions = CC_UserPermissionUtility.checkUserPermission(
      userId,
      'sObject',
      'Idea'
    );
    ideaDesc.updateable = userpermissions.editPermission;
    ideaDesc.accessible = userpermissions.readPermission;
    ideaDesc.deletable = userpermissions.deletePermission;
    ideaDesc.createable = userpermissions.createPermission;
    result.put(CC_Constants.IDEA, ideaDesc);
    return JSON.serialize(result);
  }

  /*
   * @purpose     : Method to get the Idea comments for an ideaId
   * @parameter   : ideaId - Id of the idea for which ideaComments has to be fetched
   * @return      : String - IdeaComments for the given ideaId
   */
  @AuraEnabled
  public static string getIdeaComments(string ideaId) {
    List<Comment> resComments = new List<Comment>();
    List<IdeaComment> ideaComments = IdeaDAO.getIdeaComments(ideaId);
    for (IdeaComment ideaComment : ideaComments) {
      Comment comment = new Comment();
      comment.ideaComment = ideaComment;
      comment.isUpvoted = false;
      comment.votes = ideaComment.votes;
      if (ideaComment.votes != null && !ideaComment.votes.isEmpty()) {
        for (Vote vote : ideaComment.votes) {
          if (
            vote.CreatedById == UserInfo.getUserId() &&
            vote.Type == CC_Constants.UP
          ) {
            comment.isUpvoted = true;
          }
        }
      }
      resComments.add(comment);
    }
    return JSON.serialize(resComments);
  }

  /*
   * @purpose     : Method to upvote an idea
   * @parameter   : ideaId - Id of the idea which has to be upvoted
   */
  @AuraEnabled
  public static void upvoteIdea(string ideaId) {
    try {
      List<Vote> upvotes = IdeaDAO.getIdeaVotes(ideaId);

      if (upvotes.isEmpty()) {
        List<Vote> votesList = new List<Vote>();
        Vote vote = new Vote();
        vote.ParentId = ideaId;
        vote.type = CC_Constants.UP;
        votesList.add(vote);
        DMLUtility.insertRecords(votesList, true);
      }
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'upvoteIdea',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to downvote an idea
   * @parameter   : ideaId - Id of the idea which has to be downvoted
   */
  @AuraEnabled
  public static void downvoteIdea(string ideaId) {
    try {
      List<Vote> downvotes = IdeaDAO.getIdeaVotes(ideaId);

      if (downvotes.isEmpty()) {
        List<Vote> votesList = new List<Vote>();
        Vote vote = new Vote();
        vote.ParentId = ideaId;
        vote.type = CC_Constants.DOWN;
        votesList.add(vote);
        DMLUtility.insertRecords(votesList, true);
      }
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'downvoteIdea',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  @AuraEnabled
  public static String getTotalVotes(Id ideaId) {
    try {
      Idea idea = [SELECT VoteTotal FROM Idea WHERE id = :ideaId];
      System.debug(String.valueOf(idea.VoteTotal));
      return String.valueOf(idea.VoteTotal);
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'getTotalVotes',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to like an ideaComment
   * @parameter   : ideaCommentId - Id of the ideaComment which has to be liked
   */
  @AuraEnabled
  public static void likeComment(string ideaCommentId) {
    try {
      List<Vote> votes = IdeaDAO.getIdeaCommentVotes(ideaCommentId);
      if (votes.isEmpty()) {
        Vote vote = new Vote();
        vote.ParentId = ideaCommentId;
        vote.Type = CC_Constants.UP;
        List<Vote> votesList = new List<Vote>();
        votesList.add(vote);
        DMLUtility.insertRecords(votesList, true);
      }
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'likeComment',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to unlike an ideaComment
   * @parameter   : ideaCommentId - Id of the ideaComment which has to be unliked
   */
  @AuraEnabled
  public static void unlikeComment(string ideaCommentId) {
    try {
      List<Vote> votes = IdeaDAO.getIdeaCommentVotes(ideaCommentId);
      DMLUtility.deleteRecords(votes, true);
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'unlikeComment',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to delete an ideaComment
   * @parameter   : ideaCommentId - Id of the ideaComment which has to be deleted
   */
  @AuraEnabled
  public static void deleteComment(string ideaCommentId) {
    try {
      IdeaComment comment = new IdeaComment();
      comment.Id = ideaCommentId;
      delete comment;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'deleteComment',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to insert an ideaComment
   * @parameter   : param - Stringified form the ideaComment which has to be added
   */
  @AuraEnabled
  public static IdeaComment addComment(string param) {
    try {
      IdeaComment comment = (IdeaComment) JSON.deserialize(
        param,
        IdeaComment.class
      );
      IdeaComment newComment = new IdeaComment();
      newComment.IdeaId = comment.IdeaId;
      newComment.CommentBody = comment.CommentBody;
      insert newComment;
      return newComment;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'addComment',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to get an ideaComment details
   * @parameter   : ideaCommentId - Id of the ideaComment which has to be fetched
   */
  @AuraEnabled
  public static IdeaComment getIdeaCommentRecord(string ideaCommentId) {
    try {
      return IdeaDAO.getIdeaCommentRecord(ideaCommentId);
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'getIdeaCommentRecord',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to save an ideaComment
   * @parameter   : comment - ideaComment which has to be saved
   * @return      : IdeaComment - IdeaComment record which was saved
   */
  @AuraEnabled
  public static IdeaComment saveIdeaCommentRecord(IdeaComment comment) {
    try {
      upsert comment;
      return comment;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'saveIdeaCommentRecord',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to get the Idea List based on the dynamic conditions
   * @parameter   : communityId - Id of the community Zone
   * @parameter   : statuses - Status value of the records to be fetched
   * @parameter   : searchText - text in the title of the records to be fetched
   * @parameter   : categories - Categories value of the records to be fetched
   * @return      : List<Idea> - List of ideas with the conditions met.
   */
  @AuraEnabled
  public static List<Idea> getIdeasList(
    string communityId,
    string statuses,
    string searchText,
    string categories,
    Integer recordLimit,
    Integer offset
  ) {
    try {
      return IdeaDAO.getIdeasListWithDynamicConditions(
        communityId,
        statuses,
        searchText,
        categories,
        recordLimit,
        offset
      );
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'getIdeasList',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to get the Map of field label and picklist values specific to the zoneId
   * @parameter   : zoneId - Id of the community Zone
   * @return      : Map < String, Map < String, String >> - Map of field label and picklist values specific to the zoneId .
   */
  @AuraEnabled
  public static Map<String, Map<String, String>> fetchRecordTypeSpecificPickListvalues(
    String zoneId
  ) {
    String recordTypeId;
    Map<String, Map<String, String>> picklistVsKeyValueMap = null;
    if (zoneId != null) {
      recordTypeId = getRecordTypeId(zoneId);
    } else {
      List<Community> communities = IdeaDAO.getActiveCommunity();
      if (communities != null && !communities.isEmpty()) {
        recordTypeId = getRecordTypeId(communities.get(0).Id);
      }
    }
    if (recordTypeId != null) {
      picklistVsKeyValueMap = calloutUIAPIForPicklistValues(recordTypeId);
    }
    return picklistVsKeyValueMap;
  }

  /*
   * @purpose     : Method to get the Map of field label and picklist values specific to the recordTypeId using DescribeLayout Http Callout
   * @parameter   : recordTypeId - Id of the recordType
   * @return      : Map < String, Map < String, String >> - Map of field label and picklist values specific to the recordType .
   */
  public static Map<String, Map<String, String>> calloutUIAPIForPicklistValues(
    String recordTypeId
  ) {
    try {
      String responseString = APICalloutUtility.callAPIResponseService(
        CC_Constants.DESCRIBELAYOUTGET,
        null,
        null,
        recordTypeId
      );
      Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
        responseString
      );
      List<Object> detailLayoutSections = (List<Object>) result.get(
        CC_Constants.DETAILLAYOUTSECTIONS
      );
      Map<String, Object> detailFirstSection = (Map<String, Object>) detailLayoutSections[0];
      List<Object> layoutRows = (List<Object>) detailFirstSection.get(
        CC_Constants.LAYOUTROWS
      );
      Map<String, Map<String, String>> picklistVsKeyValueMap = new Map<String, Map<String, String>>();
      Map<String, List<Object>> fieldVsPicklistObjectList = new Map<String, List<Object>>();
      List<Object> allLayoutItems = new List<Object>();
      for (Object layoutRow : layoutRows) {
        Map<String, Object> layRow = (Map<String, Object>) layoutRow;
        List<Object> layoutItems = (List<Object>) layRow.get(
          CC_Constants.LAYOUTITEMS
        );
        allLayoutItems.addAll(layoutItems);
      }
      for (Object layoutItem : allLayoutItems) {
        Map<String, Object> layItem = (Map<String, Object>) layoutItem;
        String fieldLabel = (String) layItem.get(CC_Constants.LABEL);
        List<Object> layoutComponents = (List<Object>) layItem.get(
          CC_Constants.LAYOUTCOMPONENTS
        );
        if (layoutComponents.size() > 0) {
          Map<String, Object> layComponent = (Map<String, Object>) layoutComponents[0];
          Map<String, Object> details = (Map<String, Object>) layComponent.get(
            CC_Constants.DETAILS
          );
          List<Object> picklistValues = (List<Object>) details.get(
            CC_Constants.PICKLISTVALUES
          );
          fieldVsPicklistObjectList.put(fieldLabel, picklistValues);
        }
      }
      for (String fieldLabel : fieldVsPicklistObjectList.keySet()) {
        Map<String, String> valueLabelMap = new Map<String, String>();
        List<Object> pickListValues = fieldVsPicklistObjectList.get(fieldLabel);
        for (Object pickListValue : pickListValues) {
          Map<String, Object> pickListObjectMap = (Map<String, Object>) pickListValue;
          if ((Boolean) pickListObjectMap.get(CC_Constants.ACTIVE) == true) {
            valueLabelMap.put(
              (String) pickListObjectMap.get(CC_Constants.VALUE),
              (String) pickListObjectMap.get(CC_Constants.LABEL)
            );
          }
        }
        picklistVsKeyValueMap.put(fieldLabel, valueLabelMap);
      }
      System.debug('picklistVsKeyValueMap ' + picklistVsKeyValueMap);
      return picklistVsKeyValueMap;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'calloutUIAPIForPicklistValues',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to get recordType Id against a communityZone Id
   * @parameter   : zoneId - Id of the communityZone
   * @return      : String - RecordType Id against a communityZone Id.
   */
  private static String getRecordTypeId(Id zoneId) {
    String recordTypeId = null;
    try {
      Community communityZone = [
        SELECT name
        FROM Community
        WHERE id = :zoneId
      ][0];
      Schema.DescribeSObjectResult objRes = Idea.SObjectType.getDescribe();
      List<Schema.RecordTypeInfo> recTypeInfo = objRes.getRecordTypeInfos();
      for (Schema.RecordTypeInfo r : recTypeInfo) {
        if (communityZone.name + ': Idea Record Type' == r.getName()) {
          recordTypeId = r.getRecordTypeId();
          break;
        }
      }
      return recordTypeId;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaDetailController',
        'getRecordTypeId',
        'Idea Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to get community Network name of the logged in user in community
   * @return      : String - Name of the communityNetwork of the logged in user in community
   */
  @AuraEnabled
  public static String getCommunityNetworkName() {
    String networkId = Network.getNetworkId();
    System.debug('networkId@@' + networkId);
    return networkIdVsName.get(networkId);
  }

  public static Map<Id, String> networkIdVsName {
    get {
      if (networkIdVsName == null) {
        networkIdVsName = new Map<Id, String>();
        List<Network> networks = new List<Network>();
        networks = [SELECT Id, Name, UrlPathPrefix FROM Network];
        if (networks != null && !networks.isEmpty()) {
          for (Network network : networks) {
            networkIdVsName.put(network.Id, network.UrlPathPrefix);
          }
        }
      }
      return networkIdVsName;
    }
    set;
  }

  public class Comment {
    @AuraEnabled
    public IdeaComment ideaComment;
    @AuraEnabled
    public List<Vote> votes;
    @AuraEnabled
    public boolean isUpvoted;
  }

  public class CC_IdeaCustomException extends Exception {
  }
}
