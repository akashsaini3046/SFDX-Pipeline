/*
 * Name: NewAccountTeamBatch
 * Purpose: Batch Class to get all the account team which is
 * Author: Nagarro
 * Created Date: 27-Aug-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class NewAccountTeamBatch implements Database.Batchable<sObject>, Database.Stateful {
  //This holds account team members
  public List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
  //This holds parent account to parent accounts
  public Map<Id, Set<Id>> mapParentAccountIdToChildrenAccounts = new Map<Id, Set<Id>>();
  //This holds account id to account map
  public map<Id, Account> mapAccountIdToAccount = new Map<Id, Account>();
  //This holds accout to extream parent account
  Map<Id, Id> mapAccountToExtremeParent = new Map<Id, Id>();

  /*
   * Method Name: start
   * Input Parameters:
   * Database.BatchableContext objBatchableContext: This holds batchable context.
   * Return value: Database.QueryLocator
   * Purpose: This method returns AccountTeamMembers whoich are created yesterday.
   */
  public Database.QueryLocator start(
    Database.BatchableContext objBatchableContext
  ) {
    List<Id> lstCreatedByIdsExcludeForNotification = new List<Id>();
    Account_Team_Notification__mdt objAccountTeamNotificationCustomMetadata = [
      SELECT Exclude_Created_By_Id__c
      FROM Account_Team_Notification__mdt
      WHERE DeveloperName = 'AccountTeamNotification'
      LIMIT 1
    ];

    if (
      String.isNotBlank(
        objAccountTeamNotificationCustomMetadata.Exclude_Created_By_Id__c
      )
    ) {
      for (
        String strUsers : objAccountTeamNotificationCustomMetadata.Exclude_Created_By_Id__c.split(
          ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
        )
      ) {
        lstCreatedByIdsExcludeForNotification.add(strUsers);
      }
    }

    if (test.isRunningTest()) {
      return Database.getQueryLocator(
        [
          SELECT
            Id,
            AccountId,
            Account.Name,
            Account.CVIF__c,
            Account.ParentId,
            Account.Parent.Name,
            Account.Parent.CVIF__c,
            Account.Owner.Name,
            TeamMemberRole,
            UserId,
            User.Name,
            CreatedBy.Name
          FROM AccountTeamMember
          WHERE CreatedDate = TODAY
        ]
      );
    } else {
      return Database.getQueryLocator(
        [
          SELECT
            Id,
            AccountId,
            Account.Name,
            Account.CVIF__c,
            Account.ParentId,
            Account.Parent.Name,
            Account.Parent.CVIF__c,
            Account.Owner.Name,
            TeamMemberRole,
            UserId,
            User.Name,
            CreatedBy.Name
          FROM AccountTeamMember
          WHERE
            CreatedDate = YESTERDAY
            AND CreatedById NOT IN :lstCreatedByIdsExcludeForNotification
        ]
      );
    }
  }

  /*
   * Method Name: Execute
   * Input Parameters:
   * Database.BatchableContext objBatchableContext: This holds batchable context.
   * List<AccountTeamMember> lstAccountTeamMemberScope: This holds list of accoutTeam member
   * Return value: NA
   * Purpose: This method adds scope data and relate extreme parent to children accounts.
   */
  public void Execute(
    Database.BatchableContext objBatchableContext,
    List<AccountTeamMember> lstAccountTeamMemberScope
  ) {
    Set<Id> setAccountIds = new Set<Id>();
    Id idExtremeParent;

    lstAccountTeamMember.addAll(lstAccountTeamMemberScope);
    for (AccountTeamMember objAccountTeamMember : lstAccountTeamMemberScope) {
      setAccountIds.add(objAccountTeamMember.AccountId);
    }
    //Get the extreme parent
    for (Account objAccount : [
      SELECT
        Id,
        ParentId,
        Parent.ParentId,
        Parent.Parent.ParentId,
        Parent.Parent.Parent.ParentId,
        Parent.Parent.Parent.Parent.ParentId,
        Parent.Parent.Parent.Parent.Parent.ParentId
      FROM Account
      WHERE Id IN :setAccountIds
    ]) {
      if (objAccount.Parent.Parent.Parent.Parent.Parent.ParentId != null)
        mapAccountToExtremeParent.put(
          objAccount.Id,
          objAccount.Parent.Parent.Parent.Parent.Parent.ParentId
        );
      else if (objAccount.Parent.Parent.Parent.Parent.ParentId != null)
        mapAccountToExtremeParent.put(
          objAccount.Id,
          objAccount.Parent.Parent.Parent.Parent.ParentId
        );
      else if (objAccount.Parent.Parent.Parent.ParentId != null)
        mapAccountToExtremeParent.put(
          objAccount.Id,
          objAccount.Parent.Parent.Parent.ParentId
        );
      else if (objAccount.Parent.Parent.ParentId != null)
        mapAccountToExtremeParent.put(
          objAccount.Id,
          objAccount.Parent.Parent.ParentId
        );
      else if (objAccount.Parent.ParentId != null)
        mapAccountToExtremeParent.put(
          objAccount.Id,
          objAccount.Parent.ParentId
        );
      else if (objAccount.ParentId != null)
        mapAccountToExtremeParent.put(objAccount.Id, objAccount.ParentId);
      else
        mapAccountToExtremeParent.put(objAccount.Id, objAccount.Id); //If no parent then consider account itself as extreme parent
    }

    //Iterate over accounts of current scope and fetch parent hierarchies
    for (Account objAccount : [
      SELECT
        Id,
        CVIF__c,
        ParentId,
        Parent.ParentId,
        Parent.Parent.ParentId,
        Parent.Parent.Parent.ParentId,
        Parent.Parent.Parent.Parent.ParentId,
        Parent.Parent.Parent.Parent.Parent.ParentId
      FROM Account
      WHERE
        Id IN :mapAccountToExtremeParent.values()
        OR ParentId IN :mapAccountToExtremeParent.values()
        OR Parent.ParentId IN :mapAccountToExtremeParent.values()
        OR Parent.Parent.ParentId IN :mapAccountToExtremeParent.values()
        OR Parent.Parent.Parent.ParentId IN :mapAccountToExtremeParent.values()
        OR Parent.Parent.Parent.Parent.ParentId IN :mapAccountToExtremeParent.values()
        OR Parent.Parent.Parent.Parent.Parent.ParentId IN :mapAccountToExtremeParent.values()
    ]) {
      idExtremeParent = null;
      if (mapAccountIdToAccount.containsKey(objAccount.Id) == false) {
        mapAccountIdToAccount.put(objAccount.Id, objAccount);

        //Create parent ids set
        if (objAccount.Parent.Parent.Parent.Parent.Parent.ParentId != null)
          idExtremeParent = objAccount.Parent.Parent.Parent.Parent.Parent.ParentId;
        else if (objAccount.Parent.Parent.Parent.Parent.ParentId != null)
          idExtremeParent = objAccount.Parent.Parent.Parent.Parent.ParentId;
        else if (objAccount.Parent.Parent.Parent.ParentId != null)
          idExtremeParent = objAccount.Parent.Parent.Parent.ParentId;
        else if (objAccount.Parent.Parent.ParentId != null)
          idExtremeParent = objAccount.Parent.Parent.ParentId;
        else if (objAccount.Parent.ParentId != null)
          idExtremeParent = objAccount.Parent.ParentId;
        else if (objAccount.ParentId != null)
          idExtremeParent = objAccount.ParentId;

        if (idExtremeParent != null) {
          if (
            mapParentAccountIdToChildrenAccounts.containsKey(idExtremeParent)
          ) {
            mapParentAccountIdToChildrenAccounts.get(idExtremeParent)
              .add(objAccount.Id);
          } else {
            mapParentAccountIdToChildrenAccounts.put(
              idExtremeParent,
              new Set<Id>{ objAccount.Id, idExtremeParent }
            );
          }
        }
      }
    }
  }

  /*
   * Method Name: finish
   * Input Parameters:
   * Database.BatchableContext objBatchableContext: This holds batchable context.
   * Return value: Database.QueryLocator
   * Purpose: This method executes after batch execution to send notification email.
   */
  public void finish(Database.BatchableContext objBatchableContext) {
    Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
    Account_Team_Notification__mdt objAccountTeamNotificationCustomMetadata;
    List<String> lstToEmailAddress = new List<String>();
    List<Id> lstUserorGroupId = new List<Id>();
    Integer intIndex = 1;
    String strTeamDataForTable = Label.ATN_EMAIL_HEADING_HTML;
    String strTDOpen = Label.ATN_TD_OPEN;
    String strTDClose = Label.ATN_TD_CLOSE;
    String strTROpen = Label.ATN_TR_OPEN;
    String strTRClose = Label.ATN_TR_CLOSE;
    String strTROpenWithWidth = Label.ATN_TD_OPEN_WIDTH_STYLE;

    List<String> lstCVIFString = new List<String>();
    String strRelatedCVIFs = '';

    if (lstAccountTeamMember.size() > 0) {
      //Iterate over lstAccountTeamMember to create html data.
      for (AccountTeamMember objAccountTeamMember : lstAccountTeamMember) {
        lstCVIFString.clear();
        strRelatedCVIFs = '';
        if (
          mapAccountToExtremeParent.containsKey(
            objAccountTeamMember.AccountId
          ) &&
          mapParentAccountIdToChildrenAccounts.containsKey(
            mapAccountToExtremeParent.get(objAccountTeamMember.AccountId)
          )
        ) {
          for (
            Id idAccount : mapParentAccountIdToChildrenAccounts.get(
              mapAccountToExtremeParent.get(objAccountTeamMember.AccountId)
            )
          ) {
            if (
              idAccount != objAccountTeamMember.AccountId &&
              idAccount != objAccountTeamMember.Account.ParentId &&
              mapAccountIdToAccount.containsKey(idAccount) &&
              String.isNotBlank(mapAccountIdToAccount.get(idAccount).CVIF__c)
            ) {
              lstCVIFString.add(mapAccountIdToAccount.get(idAccount).CVIF__c);
            }
          }
        }

        if (lstCVIFString.size() > 0) {
          strRelatedCVIFs = String.join(
            lstCVIFString,
            ConstantClass.STRING_SEPERATOR_COMMA
          );
        }
        strTeamDataForTable +=
          strTROpen +
          strTDOpen +
          intIndex++ +
          strTDClose +
          strTDOpen +
          objAccountTeamMember.Account.Name +
          strTDClose +
          strTDOpen +
          (objAccountTeamMember.Account.CVIF__c != null
            ? objAccountTeamMember.Account.CVIF__c
            : '') +
          strTDClose +
          strTDOpen +
          objAccountTeamMember.Account.Owner.Name +
          strTDClose +
          strTDOpen +
          (objAccountTeamMember.Account.Parent.Name != null
            ? objAccountTeamMember.Account.Parent.Name
            : '') +
          strTDClose +
          strTDOpen +
          (objAccountTeamMember.Account.Parent.CVIF__c != null
            ? objAccountTeamMember.Account.Parent.CVIF__c
            : '') +
          strTDClose +
          strTROpenWithWidth +
          strRelatedCVIFs +
          strTDClose +
          strTDOpen +
          objAccountTeamMember.User.Name +
          strTDClose +
          strTDOpen +
          objAccountTeamMember.TeamMemberRole +
          strTDClose +
          strTDOpen +
          objAccountTeamMember.CreatedBy.Name +
          strTDClose +
          strTRClose;
      }
      strTeamDataForTable += Label.ATN_EMAIL_FOOTER_HTML;

      //Get users from the group who will receive notification.
      for (GroupMember objGroupMember : [
        SELECT UserOrGroupId, Group.DeveloperName
        FROM GroupMember
        WHERE Group.DeveloperName = :Label.ATN_MARKETING_GROUP_DEV_NAME
      ]) {
        lstUserorGroupId.add(objGroupMember.UserOrGroupId);
      }

      if (lstUserorGroupId.size() > 0) {
        //Get email ids of users who will be notified.
        for (User objUser : [
          SELECT Id, Email
          FROM User
          WHERE Id IN :lstUserorGroupId
        ]) {
          lstToEmailAddress.add(objUser.Email);
        }
      }

      objAccountTeamNotificationCustomMetadata = [
        SELECT Additional_Emails__c
        FROM Account_Team_Notification__mdt
        WHERE DeveloperName = 'AccountTeamNotification'
        LIMIT 1
      ];
      if (
        String.isNotBlank(
          objAccountTeamNotificationCustomMetadata.Additional_Emails__c
        )
      ) {
        for (
          String strEmail : objAccountTeamNotificationCustomMetadata.Additional_Emails__c.split(
            ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
          )
        ) {
          lstToEmailAddress.add(strEmail);
        }
      }

      //Send notification
      if (lstToEmailAddress.size() > 0) {
        objEmail.setToAddresses(lstToEmailAddress);
        objEmail.setSubject(Label.ATN_NEW_AT_SUBJECT);
        objEmail.setHtmlBody(strTeamDataForTable);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ objEmail });
      }
    }
  }
}
