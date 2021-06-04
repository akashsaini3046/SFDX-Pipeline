/*
 * @company     : Nagarro Inc.
 * @date        : 16-07-2020
 * @author      : Nagarro
 * @description : DAO for Idea. and Related Objects
 * @history     : Version 1.0
 * @test class  : IdeaDAOTest
 */
public without sharing class IdeaDAO implements IIdeaDao {
  /*
   * @company     : Nagarro Inc.
   * @date        : 16-07-2020
   * @author      : Nagarro
   * @description : Interface for the DAO - Contains methods which must be implemented
   * @history     : Version 1.0
   */
  public interface IIdeaDao {
    User getUserDetails(Id userId);
    List<Idea> getIdeaListByIds(Set<Id> ideaIds);
    List<Idea> getIdeasListWithDynamicConditions(
      String communityId,
      String statuses,
      String searchText,
      String categories,
      Integer recordLimit,
      Integer offset
    );
    Idea getIdeaWithAllFields(Id ideaId);
    List<IdeaComment> getIdeaComments(Id ideaId);
    List<Vote> getIdeaVotes(Id ideaId);
    List<Vote> getIdeaCommentVotes(Id ideaCommentId);
    IdeaComment getIdeaCommentRecord(string ideaCommentId);
    List<Community> getActiveCommunity();
    Group getGroupByName(String groupName);
    EmailTemplate getEmailTemplateByName(String templateName);
    List<GroupMember> getGroupMembers(Id groupId);
    Integer getAllIdeas(
      String IdSelectedZone,
      String statuses,
      String searchText,
      String categories
    );
  }

  /*
   * @purpose     : Method to get user detail from the user id provided.
   * @parameter   : uderId - Id of the userto be fetched
   * @return      : User - User record for the given uder Id.
   */
  public static User getUserDetails(Id userId) {
    return [
      SELECT
        Id,
        Name,
        Username,
        FirstName,
        LastName,
        FullPhotoURL,
        SmallPhotoURL
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];
  }

  /*
   * @purpose     : Method to get the List of Idea Records for the given set of Idea Ids.
   * @parameter   : ideaIds - Set of Idea Ids to be fetched
   * @return      : List of Idea - List of Idea record for the given set of Ids.
   */
  public static List<Idea> getIdeaListByIds(Set<Id> ideaIds) {
    return [
      SELECT
        Id,
        Title,
        Status,
        Community.Name,
        Body,
        VoteTotal,
        Assigned_To__c,
        Subcategory__c,
        Free_Text__c
      FROM Idea
      WHERE Id IN :ideaIds
    ];
  }

  /*
   * @purpose     : Method to get the Idea Record and related Vote records corresponding to the Idea Id provided.
   * @parameter   : ideaId - Id of the idea record to be fetched
   * @return      : Idea - Idea Record with Votes excluding 3 attachment related fields
   */
  public static Idea getIdeaWithAllFields(Id ideaId) {
    if (string.isBlank(ideaId)) {
      return new Idea();
    }
    Idea ideaRecord = new Idea();
    List<string> allFields = new List<String>();
    Map<string, Schema.SObjectField> ideafieldsMap = Idea.SobjectType.getDescribe()
      .fields.getMap();
    Set<string> excludedFields = new Set<string>{
      CC_Constants.ATTACHMENTLENGTH,
      CC_Constants.ATTACHMENTCONTENTTYPE,
      CC_Constants.ATTACHMENTBODY
    };
    for (String field : ideafieldsMap.keySet()) {
      if (ideafieldsMap.get(field).getDescribe().isAccessible()) {
        if (!excludedFields.contains(field)) {
          allFields.add(field);
        }
      }
    }
    Id userId = UserInfo.getUserId();
    String query =
      'Select ' +
      String.join(allFields, ',') +
      ', Community.Name, (Select Id, Type, CreatedById From Votes Where CreatedById=:userId) From Idea Where Id=:ideaId Limit 1';
    ideaRecord = (Idea) Database.Query(query);
    return ideaRecord;
  }

  /*
   * @purpose     : Method to get the List of IdeaComment Records corresponding to the provided Idea Id.
   * @parameter   : ideaId - Id of the idea record
   * @return      : List of IdeaComment - List of IdeaComment records corresponding to the Idea Id provided.
   */
  public static List<IdeaComment> getIdeaComments(Id ideaId) {
    Map<string, Schema.SobjectField> commentFieldsMap = IdeaComment.SobjectType.getDescribe()
      .fields.getMap();
    Set<String> commentFieldsSet = commentFieldsMap.keyset();
    List<string> commentFields = new List<String>(commentFieldsSet);
    String query =
      'Select ' +
      String.join(commentFields, ',') +
      ', CreatedBy.Alias, CreatedBy.Name, (Select Id, Type, LastModifiedById, CreatedById From Votes) From IdeaComment Where IdeaId=:ideaId Order By CreatedDate desc';
    List<IdeaComment> ideaComments = (List<IdeaComment>) Database.query(query);
    return ideaComments;
  }

  /*
   * @purpose     : Method to get the List of Vote Records corresponding to the provided Idea Id.
   * @parameter   : ideaId - Id of the idea record
   * @return      : List of Vote - List of Vote records corresponding to the Idea Id provided for a current user.
   */
  public static List<Vote> getIdeaVotes(Id ideaId) {
    Id userId = UserInfo.getUserId();
    return [
      SELECT Id, ParentId, CreatedById, Type
      FROM Vote
      WHERE CreatedById = :userId AND ParentId = :ideaId
    ];
  }

  /*
   * @purpose     : Method to get the IdeaComment Record corresponding to the IdeaComment Id provided.
   * @parameter   : ideaCommentId - Id of the ideaComment record to be fetched
   * @return      : IdeaComment - IdeaComment Record
   */
  public static IdeaComment getIdeaCommentRecord(string ideaCommentId) {
    return [
      SELECT Id, CommentBody, Idea.Title, Idea.CommunityId, IdeaId
      FROM IdeaComment
      WHERE Id = :ideaCommentId
    ];
  }

  /*
   * @purpose     : Method to get the List of Vote Records corresponding to the provided IdeaComment Id.
   * @parameter   : ideaCommentId - Id of the IdeaComment record
   * @return      : List of Vote - List of Vote records corresponding to the Idea Comment Id provided for a current user.
   */
  public static List<Vote> getIdeaCommentVotes(Id ideaCommentId) {
    Id userId = UserInfo.getUserId();
    return [
      SELECT Id, ParentId, Type, LastModifiedById
      FROM Vote
      WHERE ParentId = :ideaCommentId AND LastModifiedById = :userId
    ];
  }

  /*
   * @purpose     : Method to get the List of Idea Records with dynamic filters.
   * @parameter   : communityId - String containing the Id of the Community record
   * @parameter   : statuses - Status value
   * @parameter   : searchText - Text value of the search
   * @parameter   : categories - Category Value
   * @return      : List of Idea - List of Idea records corresponding filters provided in the parameters.
   */
  public static List<Idea> getIdeasListWithDynamicConditions(
    String communityId,
    String statuses,
    String searchText,
    String categories,
    Integer recordLimit,
    Integer offset
  ) {
    Id userId = UserInfo.getUserId();
    String query =
      'SELECT ' +
      String.join(allIdeaFieldsList, ',') +
      ',(SELECT CreatedById, Type FROM Votes WHERE CreatedById=\'' +
      userId +
      '\') FROM Idea';
    List<string> whereConditions = new List<String>();

    if (String.isNotBlank(communityId)) {
      whereConditions.add('CommunityId=\'' + communityId + '\'');
    }
    /*else {
            List<Community> communities = getActiveCommunity();
            if (communities != null && !communities.isEmpty()) {
                communityId = communities.get(0).id;
                whereConditions.add('CommunityId=\''+communityId+'\'');
            }
        }*/
    if (String.isNotBlank(statuses)) {
      whereConditions.add('Status = :statuses');
    }

    if (String.isNotBlank(categories)) {
      whereConditions.add('Categories INCLUDES (:categories)');
    }
    if (String.isNotBlank(searchText)) {
      String tempSearchText = '%' + searchText + '%';
      whereConditions.add('Title like :tempSearchText ');
    }
    if (!whereConditions.isEmpty()) {
      query = query + ' WHERE ' + String.Join(whereConditions, ' AND ');
    }
    query = query + ' ORDER BY LastModifiedDate DESC';
    if (String.isNotBlank(String.valueOf(recordLimit))) {
      query = query + ' LIMIT ' + recordLimit;
    }
    if (String.isNotBlank(String.valueOf(offset))) {
      query = query + ' OFFSET ' + offset;
    }
    System.debug('@@userId' + userId);
    System.debug('@@query' + query);
    System.debug(
      'communityId, String statuses, String searchText, String categories, Integer recordLimit, Integer offset'
    );
    System.debug(
      communityId +
      ' - ' +
      statuses +
      ' - ' +
      searchText +
      ' - ' +
      categories +
      ' - ' +
      recordLimit +
      ' - ' +
      offset
    );
    System.debug('@@@DataBase.query' + DataBase.query(query));
    return (List<Idea>) DataBase.query(query);
  }

  /*
   * @purpose     : Method to get the Community Record of the active Community.
   * @return      : List of Community - Community record of the active community
   */
  public static List<Community> getActiveCommunity() {
    Id communityNetworkId = Network.getNetworkId();
    if (communityNetworkId == null)
      return [
        SELECT Id, Name, IsActive
        FROM Community
        WHERE IsActive = TRUE
        ORDER BY Name ASC
        LIMIT 10000
      ];
    else
      return [
        SELECT Id, Name, IsActive
        FROM Community
        WHERE IsActive = TRUE AND NetworkId = :communityNetworkId
        ORDER BY Name ASC
        LIMIT 10000
      ];
  }

  // Getter and Setter for List of String values containing all fields of Idea object
  public static List<String> allIdeaFieldsList {
    get {
      if (allIdeaFieldsList == null) {
        allIdeaFieldsList = new List<String>();
        Map<string, Schema.SObjectField> fieldMap = Idea.SobjectType.getDescribe()
          .fields.getMap();
        for (string field : fieldMap.keyset()) {
          if (fieldMap.get(field).getDescribe().isAccessible()) {
            if (field != 'attachmentbody') {
              allIdeaFieldsList.add(field);
            }
          }
        }
        allIdeaFieldsList.add(CC_Constants.COMMUNITYNAME);
        allIdeaFieldsList.add(CC_Constants.CREATEBYALIAS);
        allIdeaFieldsList.add(CC_Constants.CREATEDBYNAME);
      }
      return allIdeaFieldsList;
    }
    set;
  }

  /*
   * @purpose     : Method to get the Group Record
   * @parameter   : GroupName against which the record has to be found
   * @return      : Group record
   */
  public static Group getGroupByName(String groupName) {
    Group grp = null;
    List<Group> groups = [
      SELECT Id, Name
      FROM Group
      WHERE Name = :groupName
      LIMIT 50000
    ];
    if (groups.size() > 0)
      grp = groups[0];
    return grp;
  }

  /*
   * @purpose     : Method to get the EmailTemplate Record
   * @parameter   : TemplateName against which the record has to be found
   * @return      : EmailTemplate record
   */
  public static EmailTemplate getEmailTemplateByName(String templateName) {
    EmailTemplate emailTemp = null;
    List<EmailTemplate> emailTemplates = [
      SELECT id
      FROM EmailTemplate
      WHERE name = :templateName
      LIMIT 50000
    ];
    if (emailTemplates.size() > 0)
      emailTemp = emailTemplates[0];
    return emailTemp;
  }

  /*
   * @purpose     : Method to get the GroupMember Records
   * @parameter   : GroupId against which records has to be found
   * @return      : GroupMember records
   */
  public static List<GroupMember> getGroupMembers(Id groupId) {
    List<GroupMember> members = [
      SELECT Id, UserorGroupId
      FROM GroupMember
      WHERE GroupId = :groupId
    ];
    return members;
  }
  /*
   * @purpose     : Method to get count of all Ideas
   * @paramter    : idSelectedZone against which records has to be found
   * @parameter   : statuses against which records has to be found
   * @parameter   : searchText against which records has to be found
   * @parameter   : categories against which records has to be found
   * @return      : Idea records
   */
  public static Integer getAllIdeas(
    String idSelectedZone,
    String statuses,
    String searchText,
    String categories
  ) {
    String query = 'SELECT Id From Idea';
    List<string> whereConditions = new List<String>();
    if (String.isNotBlank(idSelectedZone)) {
      whereConditions.add('CommunityId=\'' + idSelectedZone + '\'');
    }
    /*else {
            List<Community> communities = getActiveCommunity();
            if (communities != null && !communities.isEmpty()) {
                idSelectedZone = communities.get(0).id;
                whereConditions.add('CommunityId=\''+idSelectedZone+'\'');
            }
        }*/
    if (String.isNotBlank(statuses)) {
      whereConditions.add('Status = :statuses');
    }

    if (String.isNotBlank(categories)) {
      whereConditions.add('Categories INCLUDES (:categories)');
    }
    if (String.isNotBlank(searchText)) {
      String tempSearchText = '%' + searchText + '%';
      whereConditions.add('Title like :tempSearchText ');
    }
    if (!whereConditions.isEmpty()) {
      query = query + ' WHERE ' + String.Join(whereConditions, ' AND ');
    }
    System.debug(
      'idSelectedZone, String statuses, String searchText, String categories'
    );
    System.debug(
      idSelectedZone +
      ' - ' +
      statuses +
      ' - ' +
      searchText +
      ' - ' +
      categories
    );
    List<Idea> listRecords = DataBase.query(query);
    if (!listRecords.isEmpty()) {
      return listRecords.size();
    } else {
      return 0;
    }
  }
}
