public with sharing class UserTriggerHandler extends TriggerHandler {
  List<User> userList = new List<User>();
  Map<id, user> oldUserMap = new Map<id, user>();
  public static Boolean isTopHierarchyUpdated = false;

  public UserTriggerHandler() {
    userList = (List<User>) Trigger.New;
    oldUserMap = (Map<id, user>) Trigger.OldMap;
  }

  public override void beforeInsert() {
    //checkSalesAgentHasManager(userList);
  }

  public override void beforeUpdate() {
    //checkSalesAgentHasManager(userList);
  }

  public override void afterInsert() {
    System.debug('after insert');
    createGroupMemberRecords(userList);
    Set<ID> userIdset = new Set<Id>();
    for (User usr : userList) {
      userIdset.add(usr.Id);
    }
    addNewUserToChatterGroup(userIdset);
    try {
      if (isTopHierarchyUpdated == false) {
        isTopHierarchyUpdated = true;
        updateTopHierarchyonUser(userList, oldUserMap);
      }
    } catch (Exception objEx) {
      System.debug('UserTriggerHandler ' + objEx.getMessage());
    }
  }

  public override void afterUpdate() {
    assignMembersToAppropriateGroupOnUpdation(userList, oldUserMap);
    try {
      if (isTopHierarchyUpdated == false) {
        isTopHierarchyUpdated = true;
        updateTopHierarchyonUser(userList, oldUserMap);
      }
    } catch (Exception objEx) {
      System.debug('UserTriggerHandler ' + objEx.getMessage());
    }
  }

  /*
   * Name: createGroupMemberRecords
   * Purpose: Method to assign the user to a group based on their profile
   * Author: Nagarro
   */
  private void createGroupMemberRecords(List<User> userList) {
    Map<String, String> profileIdToNameMap = new Map<String, String>();
    Map<String, String> groupNameToIdMap = new Map<String, String>();
    List<GroupMember> groupMemberList = new List<GroupMember>();
    //Fetch Profile Ids and names
    for (Profile profileObj : [SELECT Id, Name FROM Profile]) {
      profileIdToNameMap.put(profileObj.Id, profileObj.Name);
    }

    for (Group groupObj : [
      SELECT Id, DeveloperName
      FROM Group
      WHERE Type = 'Regular'
    ]) {
      groupNameToIdMap.put(groupObj.DeveloperName, groupObj.Id);
    }

    Map<String, ProfileToGroupMap__c> profileNameToGroupMap = new Map<String, ProfileToGroupMap__c>();
    profileNameToGroupMap = ProfileToGroupMap__c.getAll();

    for (User userObj : userList) {
      GroupMember groupMemberObj = new GroupMember();
      if (
        !profileNameToGroupMap.IsEmpty() &&
        profileNameToGroupMap.containsKey(
          profileIdToNameMap.get(userObj.ProfileId)
        )
      ) {
        groupMemberObj.GroupId = groupNameToIdMap.get(
          profileNameToGroupMap.get(profileIdToNameMap.get(userObj.ProfileId))
            .Group_Name__c
        );
      }
      groupMemberObj.UserOrGroupId = userObj.Id;
      groupMemberList.add(groupMemberObj);
    }

    if (!groupMemberList.isEmpty()) {
      database.insert(groupMemberList, false);
    }
  }

  /*
   * Name: assignMembersToAppropriateGroupOnUpdation
   * Purpose: Method to assign the user to a group based on their profile when profile is updated
   * Author: Nagarro
   */
  private void assignMembersToAppropriateGroupOnUpdation(
    List<User> userList,
    Map<Id, user> oldUserMap
  ) {
    Map<String, String> mapProfileToGroup = new Map<String, String>();
    Map<Id, Map<String, String>> mapUserIdToProfileName = new Map<Id, Map<String, String>>();
    Map<Id, Profile> mapProfileIdToName = new Map<Id, Profile>(
      [SELECT Id, Name FROM Profile]
    );
    List<GroupMember> lstGroupMemberToDelete = new List<GroupMember>();

    for (
      ProfileToGroupMap__c objProfileToGroupMap : ProfileToGroupMap__c.getall()
        .values()
    ) {
      mapProfileToGroup.put(
        objProfileToGroupMap.Name,
        objProfileToGroupMap.Group_Name__c
      );
    }

    //Get users old and new profile it is has changed
    for (User objUser : userList) {
      if (
        oldUserMap != null &&
        oldUserMap.containsKey(objUser.Id) &&
        oldUserMap.get(objUser.Id).ProfileId != objUser.ProfileId
      ) {
        mapUserIdToProfileName.put(
          objUser.Id,
          new Map<String, String>{
            ConstantClass.OLD_PROFILE_STRING => mapProfileIdToName.get(
                oldUserMap.get(objUser.Id).ProfileId
              )
              .Name,
            ConstantClass.NEW_PROFILE_STRING => mapProfileIdToName.get(
                objUser.ProfileId
              )
              .Name
          }
        );
      }
    }

    List<GroupMember> lstGroupMember = [
      SELECT Id, Group.DeveloperName, UserOrGroupId
      FROM GroupMember
      WHERE
        UserOrGroupId IN :mapUserIdToProfileName.keySet()
        AND Group.DeveloperName IN :mapProfileToGroup.values()
    ];

    //Create a map with key as GroupName + User Id
    Map<String, GroupMember> mapGruopPlusUserToGroupMember = new Map<String, GroupMember>();
    for (GroupMember objGroupMember : lstGroupMember) {
      mapGruopPlusUserToGroupMember.put(
        objGroupMember.Group.DeveloperName + objGroupMember.UserOrGroupId,
        objGroupMember
      );
    }

    Map<String, Id> mapGroupDeveloperNameToId = new Map<String, Id>();
    for (Group objGroup : [
      SELECT Id, DeveloperName
      FROM GROUP
      WHERE DeveloperName IN :mapProfileToGroup.values()
    ]) {
      mapGroupDeveloperNameToId.put(objGroup.DeveloperName, objGroup.Id);
    }

    List<GroupMember> lstGroupMemberToAdd = new List<GroupMember>();
    //Remove user from old group
    for (Id objUserId : mapUserIdToProfileName.keySet()) {
      if (
        mapUserIdToProfileName.get(objUserId) != null &&
        mapProfileToGroup.get(
          mapUserIdToProfileName.get(objUserId)
            .get(ConstantClass.OLD_PROFILE_STRING)
        ) != null &&
        mapGruopPlusUserToGroupMember.get(
          mapProfileToGroup.get(
            mapUserIdToProfileName.get(objUserId)
              .get(ConstantClass.OLD_PROFILE_STRING)
          ) + objUserId
        ) != null
      ) {
        lstGroupMemberToDelete.add(
          mapGruopPlusUserToGroupMember.get(
            mapProfileToGroup.get(
              mapUserIdToProfileName.get(objUserId)
                .get(ConstantClass.OLD_PROFILE_STRING)
            ) + objUserId
          )
        );
      }
      if (
        mapUserIdToProfileName.get(objUserId) != null &&
        mapProfileToGroup.get(
          mapUserIdToProfileName.get(objUserId)
            .get(ConstantClass.NEW_PROFILE_STRING)
        ) != null &&
        mapGroupDeveloperNameToId.get(
          mapProfileToGroup.get(
            mapUserIdToProfileName.get(objUserId)
              .get(ConstantClass.NEW_PROFILE_STRING)
          )
        ) != null
      ) {
        lstGroupMemberToAdd.add(
          new GroupMember(
            UserOrGroupId = objUserId,
            GroupId = mapGroupDeveloperNameToId.get(
              mapProfileToGroup.get(
                mapUserIdToProfileName.get(objUserId)
                  .get(ConstantClass.NEW_PROFILE_STRING)
              )
            )
          )
        );
      }
    }

    if (lstGroupMemberToDelete.size() > 0) {
      try {
        delete lstGroupMemberToDelete;
      } catch (Exception objEx) {
        System.debug(
          'Exception occured in UserTriggerHandler >> assignMembersToAppropriateGroupOnUpdation ' +
          objEx.getLineNumber() +
          ' ' +
          objEx.getMessage()
        );
      }
    }

    //Add user to the new group
    if (lstGroupMemberToAdd.size() > 0) {
      try {
        insert lstGroupMemberToAdd;
      } catch (Exception objEx) {
        System.debug(
          'Exception occured in UserTriggerHandler >> assignMembersToAppropriateGroupOnUpdation ' +
          objEx.getLineNumber() +
          ' ' +
          objEx.getMessage()
        );
      }
    }
  }

  /*
   * Method Name: updateTopHierarchyonUser
   * Input Parameters:
   * List<User> lstNewUser: This holds new user list.
   * Map<Id, User> mapOldUser: This holds old user map.
   * Return value:
   * Purpose: get user list who are on top heirarchy user and update it on user.
   */
  private void updateTopHierarchyonUser(
    List<User> lstNewUser,
    Map<Id, User> mapOldUser
  ) {
    List<User> lstUsersTobeConsidered = new List<User>();
    List<User> lstUsersTobeupdated = new List<User>();

    for (User objUser : lstNewUser) {
      if (
        (objUser.UserRoleId != null && mapOldUser == null) ||
        (mapOldUser != null &&
        mapOldUser.containsKey(objUser.Id) &&
        objUser.UserRoleId != mapOldUser.get(objUser.Id).UserRoleId)
      ) {
        lstUsersTobeConsidered.add(objUser);
      }
    }

    if (lstUsersTobeConsidered.size() > 0) {
      Map<String, List<String>> mapRoleUser = UserFinderUtility.getUsersByRole();
      Map<String, String> mapUserById = UserFinderUtility.getUserById();

      UserFinderUtility objUserFinderUtility = new UserFinderUtility(
        mapRoleUser,
        UserFinderUtility.getParentRole(),
        UserFinderUtility.getUserRole()
      );
      Integer intLimitRowRemails =
        Limits.getLimitQueryRows() - Limits.getQueryRows();
      Map<Id, Profile> mapProfileIds = new Map<id, profile>(
        [
          SELECT Id, UserLicenseId
          FROM Profile
          WHERE
            UserLicenseId IN (
              SELECT Id
              FROM UserLicense
              WHERE name = 'Salesforce'
            )
        ]
      );

      for (User objUser : [
        SELECT Id, UserRoleId, UserRole.ParentRoleId, Top_Hierarchy__c
        FROM User
        WHERE profileId IN :mapProfileIds.Keyset()
        LIMIT :intLimitRowRemails
      ]) {
        if (objUser.UserRoleId != null) {
          UserFinderUtility.setUserTopHierarchy.clear();
          List<String> lstUsersonRole = mapRoleUser.get(
            objUser.UserRole.ParentRoleId
          );
          String strMamager;
          if (lstUSersonRole != null && lstUSersonRole.size() > 0) {
            strMamager = mapUserById.get(lstUsersonRole[0]);
          }
          String strTopHierarchy = String.join(
              new List<String>(
                objUserFinderUtility.getTopHierarchy(objUser.UserRoleId)
              ),
              ','
            )
            .left(255);
          String strCurrentTopHierarchy = (String.isNotBlank(
              objUser.Top_Hierarchy__c
            )
            ? objUser.Top_Hierarchy__c
            : '');
          if (
            ((new Set<String>(strCurrentTopHierarchy.split(','))
              .containsAll(new Set<String>(strTopHierarchy.split(',')))) ==
            false) ||
            ((new Set<String>(strTopHierarchy.split(','))
              .containsAll(
                new Set<String>(strCurrentTopHierarchy.split(','))
              )) == false)
          ) {
            lstUsersTobeupdated.add(
              new User(
                Id = objUser.Id,
                Top_Hierarchy__c = strTopHierarchy,
                Manager__c = strMamager
              )
            );
          }
        } else {
          if (String.isNotBlank(objUser.Top_Hierarchy__c)) {
            lstUsersTobeupdated.add(
              new User(Id = objUser.Id, Top_Hierarchy__c = '', Manager__c = '')
            );
          }
        }
      }
    }

    if (lstUsersTobeupdated.size() > 0) {
      Database.update(lstUsersTobeupdated, false);
    }
  }

  /*
   * Method Name: addNewUserToChatterGroup
   * Input Parameters: userIds
   * Return value: None
   * Purpose: To add new user to Everyone In Crowley chatter group except Sales Agent.
   */
  @future
  public static void addNewUserToChatterGroup(Set<Id> userIds) {
    System.debug('userIDs: ' + userIds);
    List<CollaborationGroupMember> chatterGroupMembers = new List<CollaborationGroupMember>();
    Id salesAgentProfileId;
    try {
      salesAgentProfileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :ConstantClass.SALES_AGENT_PROFILE
      ]
      .Id;
    } catch (Exception e) {
      System.debug('Sales agent profile not found');
      System.debug('Error: ' + e.getMessage());
      System.debug('Error line number: ' + e.getLineNumber());
    }

    List<User> users = [
      SELECT Id, ProfileId
      FROM User
      WHERE
        Id IN :userIds
        AND Profile.UserLicense.Name = 'Salesforce'
        AND IsActive = TRUE
    ];

    Id chatterGroupId;
    if (!Test.isRunningTest()) {
      try {
        chatterGroupId = [
          SELECT Id
          FROM CollaborationGroup
          WHERE Name = :ConstantClass.Everyone_In_Crowley
        ]
        .Id;
      } catch (Exception e) {
        System.debug('Chatter group not found');
        System.debug('Error: ' + e.getMessage());
        System.debug('Error line number: ' + e.getLineNumber());
      }

      for (User newuser : users) {
        if (newuser.ProfileId != salesAgentProfileId) {
          CollaborationGroupMember CGM = new CollaborationGroupMember();
          CGM.CollaborationGroupId = chatterGroupId;
          CGM.MemberId = newuser.Id;

          chatterGroupMembers.add(CGM);
        }
      }
    }
    if (chatterGroupMembers.size() > 0) {
      insert chatterGroupMembers;
    }
  }
}
