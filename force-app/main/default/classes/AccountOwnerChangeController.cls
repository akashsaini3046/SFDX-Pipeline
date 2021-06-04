/*
 * Name: AccountOwnerChangeController
 * Purpose: Controller class for AccountOwnerChangePage
 * Author: Nagarro
 */
public class AccountOwnerChangeController {
  private ApexPages.StandardController accountRec;
  public Account accRecord { get; set; }
  public String proposedAccountOwner { get; set; }
  public String proposedAccountOwnerManager { get; set; }
  public User proposedAccountOwnerRecord { get; set; }
  public User existingOwnerRecord { get; set; }
  public Boolean isRecordSubmittedForApproval { get; set; }
  public Boolean showApprovalProcess { get; set; }
  public Boolean isRecordInApprovalProcess { get; set; }
  public String currentApprover { get; set; }
  public String previousApprover { get; set; }
  public String dateTimeOfPreviousStepApproval { get; set; }
  public String statusOfStep1Approval { get; set; }
  public String statusOfStep2Approval { get; set; }
  public String statusOfStep3Approval { get; set; }
  public String dateTimeOfStep1Approval { get; set; }
  public String dateTimeOfStep2Approval { get; set; }
  public String dateTimeOfStep3Approval { get; set; }
  public String userWhoProposedNewOwner { get; set; }
  public String approvalProcessInitiatedOn1 { get; set; }
  public String approvalProcessInitiatedOn2 { get; set; }
  public Boolean checkboxesVisible { get; set; }
  public Boolean displayPopup { get; set; }
  public Boolean notificationPopup { get; set; }
  public Boolean isUserAuthorizedToApprove { get; set; }
  public Boolean isUserSystemAdmin { get; set; }
  public Boolean newPopup { get; set; }
  public static Boolean isTimeUpdate = false;

  /*
   * Method Name: onLoad
   * Input Parameters: -
   * Purpose: This method is used to set value of fields to NULL when visualforce page is loaded
   * Created By:  Himani Tanwar
   */
  public void onLoad() {
    //System.debug('on Load');
    //Account acc1 = (Account)accountRec.getRecord();
    //	System.debug('acc1 = ' + acc1);
    //Account acc2 = new Account();
    //acc2 = [Select Id, Approval_Process_Action__c, ApprovalProcessRejectedBy__c, Proposed_Account_Owner__c from Account where Id =: acc1.Id];

    if (!Approval.isLocked(accRecord.Id)) {
      System.debug(
        'accRecord.Approval_Process_Action__c = ' +
        accRecord.Approval_Process_Action__c
      );
      System.debug(
        'accRecord.ApprovalProcessRejectedBy__c = ' +
        accRecord.ApprovalProcessRejectedBy__c
      );
      accRecord.Approval_Process_Action__c = null;
      accRecord.ApprovalProcessRejectedBy__c = null;

      update accRecord;
    } else {
      if (isTimeUpdate == true) {
        Opportunity_Split_Constant__mdt objOpportunitySplitCustomMetadata = [
          SELECT Trigger_Handlers__c
          FROM Opportunity_Split_Constant__mdt
          WHERE DeveloperName = 'Bypass_Handlers'
          LIMIT 1
        ];
        for (
          String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
            ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
          )
        ) {
          TriggerHandler.bypass(strHandlerToBypass);
        }

        update accRecord;

        for (
          String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
            ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
          )
        ) {
          TriggerHandler.clearBypass(strHandlerToBypass);
        }
      }
    }
  }

  /*
   * Method Name: AccountOwnerChangeController
   * Input Parameters: ApexPages.StandardController
   * Purpose: This is the controller.
   * Created By:  Himani Tanwar
   */
  public AccountOwnerChangeController(ApexPages.StandardController acc) {
    newPopup = false;
    if (!Test.isRunningTest()) {
      acc.addFields(getAllFields());
    }
    accRecord = (Account) acc.getRecord();
    System.debug(
      'accRecord.Proposed_Account_Owner__c = ' +
      accRecord.Proposed_Account_Owner__c
    );
    this.accountRec = acc;
    //Account acc1 = (Account)acc.getRecord();
    //Account acc2 = [Select Id, Proposed_Owners_Manager__r.Name, PreviousOwner__c, Proposed_Account_Owner__c, PreviousOwnersManager__r.Name, UserWhoProposedNewOwner__r.Name, ApprovalProcessInitiatedOn__c, TimeofStep1Approval__c, TimeofStep2Approval__c, TimeofStep3Approval__c from Account where Id =:acc1.Id Limit 1];

    isUserAuthorizedToApprove = false;
    isUserSystemAdmin = false;
    /*if(AccountOwnerChangeController.lastApproval){
            
           notificationPopup = TRUE; 
        }
        else{
            
            notificationPopup = FALSE;
        }*/

    if (Approval.isLocked(accRecord.Id)) {
      checkCurrentUserAuthorizedToApprove(accRecord);
      isRecordInApprovalProcess = true;
      isRecordSubmittedForApproval = false;
      showApprovalProcess = false;

      if (
        accRecord.userWhoProposedNewOwner__c != null &&
        accRecord.userWhoProposedNewOwner__r.Name != null
      ) {
        userWhoProposedNewOwner = accRecord.userWhoProposedNewOwner__r.Name;
      }

      statusOfStep1Approval = Label.APPROVAL_PROCESS_PENDING;
      statusOfStep2Approval = Label.APPROVAL_PROCESS_PENDING;
      statusOfStep3Approval = Label.APPROVAL_PROCESS_PENDING;

      if (accRecord.ApprovalProcessInitiatedOn__c != null) {
        approvalProcessInitiatedOn1 = String.valueOf(
          accRecord.ApprovalProcessInitiatedOn__c.format('MM/dd/yyyy')
        );
        approvalProcessInitiatedOn2 = String.valueOf(
          accRecord.ApprovalProcessInitiatedOn__c.format('MM/dd/yyyy hh:mm')
        );
      }

      if (
        accRecord.PreviousOwnersManager__c != null &&
        accRecord.PreviousOwnersManager__r.Name != null
      ) {
        previousApprover = accRecord.PreviousOwnersManager__r.Name;
      }

      if (accRecord.TimeofStep1Approval__c != null) {
        dateTimeOfPreviousStepApproval = String.valueOf(
          accRecord.TimeofStep1Approval__c.format('MM/dd/yyyy hh:mm')
        );
        dateTimeOfStep1Approval = String.valueOf(
          accRecord.TimeofStep1Approval__c.format('MM/dd/yyyy hh:mm')
        );
        statusOfStep1Approval = Label.APPROVAL_PROCESS_DONE;
      } else {
        dateTimeOfStep1Approval = Label.APPROVAL_PROCESS_HYPHEN;
        dateTimeOfStep2Approval = Label.APPROVAL_PROCESS_HYPHEN;
        dateTimeOfStep3Approval = Label.APPROVAL_PROCESS_HYPHEN;
        statusOfStep1Approval = Label.APPROVAL_PROCESS_PENDING;
        statusOfStep2Approval = Label.APPROVAL_PROCESS_PENDING;
        statusOfStep3Approval = Label.APPROVAL_PROCESS_PENDING;
        dateTimeOfPreviousStepApproval = Label.APPROVAL_PROCESS_HYPHEN;
      }

      if (
        accRecord.Proposed_Owners_Manager__c != null &&
        accRecord.Proposed_Owners_Manager__r.Name != null
      ) {
        previousApprover = accRecord.Proposed_Owners_Manager__r.Name;
      }

      if (accRecord.TimeofStep2Approval__c != null) {
        dateTimeOfPreviousStepApproval = String.valueOf(
          accRecord.TimeofStep2Approval__c.format('MM/dd/yyyy hh:mm')
        );
        dateTimeOfStep2Approval = String.valueOf(
          accRecord.TimeofStep2Approval__c.format('MM/dd/yyyy hh:mm')
        );
        statusOfStep2Approval = Label.APPROVAL_PROCESS_DONE;
        statusOfStep3Approval = Label.APPROVAL_PROCESS_PENDING;
      } else {
        dateTimeOfStep2Approval = Label.APPROVAL_PROCESS_HYPHEN;
        dateTimeOfStep3Approval = Label.APPROVAL_PROCESS_HYPHEN;
        statusOfStep2Approval = Label.APPROVAL_PROCESS_PENDING;
        statusOfStep3Approval = Label.APPROVAL_PROCESS_PENDING;
        dateTimeOfPreviousStepApproval = Label.APPROVAL_PROCESS_HYPHEN;
      }

      if (accRecord.TimeofStep3Approval__c != null) {
        dateTimeOfPreviousStepApproval = String.valueOf(
          accRecord.TimeofStep3Approval__c.format('MM/dd/yyyy hh:mm')
        );
        dateTimeOfStep3Approval = String.valueOf(
          accRecord.TimeofStep3Approval__c.format('MM/dd/yyyy hh:mm')
        );
        //  statusOfStep2Approval = Label.APPROVAL_PROCESS_DONE;
        statusOfStep3Approval = Label.APPROVAL_PROCESS_DONE;
      } else {
        dateTimeOfStep3Approval = Label.APPROVAL_PROCESS_HYPHEN;
        statusOfStep3Approval = Label.APPROVAL_PROCESS_PENDING;
        dateTimeOfPreviousStepApproval = Label.APPROVAL_PROCESS_HYPHEN;
      }

      if (
        accRecord.userWhoProposedNewOwner__c ==
        accRecord.PreviousOwnersManager__c
      ) {
        statusOfStep1Approval = Label.APPROVAL_PROCESS_DONE;
        if (accRecord.ApprovalProcessInitiatedOn__c != null) {
          dateTimeOfStep1Approval = String.valueOf(
            accRecord.ApprovalProcessInitiatedOn__c.format('MM/dd/yyyy hh:mm')
          );
          accRecord.TimeofStep1Approval__c = accRecord.ApprovalProcessInitiatedOn__c;
          isTimeUpdate = true;
        }
      }

      //If user who initiated the process and proposed owner's manager are same
      if (
        accRecord.userWhoProposedNewOwner__c ==
        accRecord.Proposed_Owners_Manager__c
      ) {
        statusOfStep2Approval = Label.APPROVAL_PROCESS_DONE;
        if (accRecord.ApprovalProcessInitiatedOn__c != null) {
          dateTimeOfStep2Approval = String.valueOf(
            accRecord.ApprovalProcessInitiatedOn__c.format('MM/dd/yyyy hh:mm')
          );
          accRecord.TimeofStep2Approval__c = accRecord.ApprovalProcessInitiatedOn__c;
          isTimeUpdate = true;
        }
      }
      System.debug(
        'accRecord.TimeofStep2Approval__c--------------' +
        accRecord.TimeofStep2Approval__c
      );
      System.debug(
        'accRecord.ApprovalProcessInitiatedOn__c--------------' +
        accRecord.ApprovalProcessInitiatedOn__c
      );

      //If current user's manager and proposed owner's manager are same
      if (
        accRecord.PreviousOwnersManager__c ==
        accRecord.Proposed_Owners_Manager__c &&
        accRecord.TimeofStep1Approval__c != null
      ) {
        statusOfStep2Approval = Label.APPROVAL_PROCESS_DONE;
        if (accRecord.TimeofStep1Approval__c != null) {
          dateTimeOfStep2Approval = String.valueOf(
            accRecord.TimeofStep1Approval__c.format('MM/dd/yyyy hh:mm')
          );
          accRecord.TimeofStep2Approval__c = accRecord.TimeofStep1Approval__c;
          isTimeUpdate = true;
        }
      }

      //If current owner's manager is NULL
      if (String.isBlank(accRecord.PreviousOwnersManager__c)) {
        statusOfStep1Approval = Label.APPROVAL_PROCESS_HYPHEN;
        dateTimeOfStep1Approval = Label.APPROVAL_PROCESS_HYPHEN;
      }

      //If proposed owner's manager is NULL
      if (String.isBlank(accRecord.Proposed_Owners_Manager__c)) {
        statusOfStep2Approval = Label.APPROVAL_PROCESS_HYPHEN;
        dateTimeOfStep2Approval = Label.APPROVAL_PROCESS_HYPHEN;
      }

      System.debug('@@@ Status of Step 1 Approval ' + statusOfStep1Approval);
      System.debug('Previous Owner + ' + accRecord.PreviousOwner__c);
      System.debug(
        '@@@ Previous Owner Manager ' + accRecord.PreviousOwnersManager__c
      );
      System.debug('@@@ Proposed Owner ' + accRecord.Proposed_Account_Owner__c);
      System.debug(
        '@@@ Proposed Owner Manager ' + accRecord.Proposed_Owners_Manager__c
      );

      if (
        String.isBlank(accRecord.PreviousOwnersManager__c) &&
        String.isBlank(accRecord.Proposed_Owners_Manager__c)
      ) {
        statusOfStep1Approval = Label.APPROVAL_PROCESS_HYPHEN;
        dateTimeOfStep1Approval = Label.APPROVAL_PROCESS_HYPHEN;
        statusOfStep2Approval = Label.APPROVAL_PROCESS_HYPHEN;
        dateTimeOfStep2Approval = Label.APPROVAL_PROCESS_HYPHEN;
      }
    } else {
      isRecordInApprovalProcess = false;
      isRecordSubmittedForApproval = false;
      showApprovalProcess = true;
    }
    String currentUserProfileName = fetchCurrentLoggedInUserProfile();
    List<ProfilesHavingCheckboxAccess__c> profilesHavingCheckboxAccessList = ProfilesHavingCheckboxAccess__c.getall()
      .values();
    for (ProfilesHavingCheckboxAccess__c p : profilesHavingCheckboxAccessList) {
      if (currentUserProfileName.containsIgnoreCase(p.Name)) {
        checkboxesVisible = true;
      }
    }
  }

  /*
   * Method Name: accountSelected
   * Input Parameters: -
   * Purpose: Used to display the proposed account owner and his manager on the visualforce page dynamically
   * Created By:  Himani Tanwar
   */
  public void accountSelected() {
    isRecordSubmittedForApproval = false;
    //Account acc = (Account)accountRec.getRecord();
    System.debug(
      'accRecord.Proposed_Account_Owner__c = ' +
      accRecord.Proposed_Account_Owner__c
    );
    String proposedAccountOwnerId;

    proposedAccountOwnerId = accRecord.Proposed_Account_Owner__c;
    System.debug('Proposed Account Owner ' + proposedAccountOwnerId);
    proposedAccountOwnerRecord = [
      SELECT Id, Name, ManagerId, Manager.Name
      FROM User
      WHERE Id = :proposedAccountOwnerId
    ];
    proposedAccountOwner = proposedAccountOwnerRecord.Name;
    proposedAccountOwnerManager = proposedAccountOwnerRecord.Manager.Name;

    existingOwnerRecord = [
      SELECT Id, Name, ManagerId, Manager.Name
      FROM User
      WHERE Id = :accRecord.OwnerId
    ];
  }

  /*
   * Method Name: validatePage
   * Input Parameters: -
   * Purpose: This method is called when user clicks on Submit For Approval button. Used to give an error on visualforce page if user selects the current owner as the proposed owner
   * Created By:  Himani Tanwar
   */
  public void validatePage() {
    Account acc1 = accRecord;
    //String proposedAccountOwnerId;
    //if(!String.isBlank(acc1.Proposed_Account_Owner__c)){
    //    proposedAccountOwnerId = acc1.Proposed_Account_Owner__c;
    //}

    //  User proposedOwner = [Select Id, Name, ManagerId, Manager.Name from User where Id =:proposedAccountOwnerId];
    //  String proposedAccountOwner = proposedOwner.Name;
    //  String proposedAccountOwnerManager = proposedOwner.Manager.Name;
    //String proposedAccountOwner = proposedAccountOwnerRecord.Name;  //Added
    //String proposedAccountOwnerManager = proposedAccountOwnerRecord.Manager.Name;   //Added

    //  User existingOwner = [Select Id, Name, ManagerId, Manager.Name from User where Id =:acc1.OwnerId];
    //String existingAccountOwner = existingOwnerRecord.Name;  //changed
    //String existingAccountOwnerManager = existingOwnerRecord.Manager.Name;   //changed

    if (
      acc1.Proposed_Account_Owner__c != null &&
      acc1.Proposed_Account_Owner__c == acc1.OwnerId
    ) {
      displayPopup = false;
      ApexPages.addmessage(
        new ApexPages.message(
          ApexPages.severity.ERROR,
          Label.PROPOSED_OWNER_AND_CURRENT_OWNER_CANNOT_BE_SAME_ERR_MSG
        )
      );
    } else {
      /*   else if(String.isBlank(proposedAccountOwnerManager) && String.isBlank(existingAccountOwnerManager)){
displayPopup = false;
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.PROPOSED_OWNER_AND_CURRENT_OWNER_HAVE_NO_MANAGER_ERR_MSG));
}

else if(String.isBlank(proposedAccountOwnerManager)){
displayPopup = false;
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.PROPOSED_OWNER_HAS_NO_MANAGER_ERR_MSG));
}

else if(String.isBlank(existingAccountOwnerManager)){
displayPopup = false;
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.CURRENT_OWNER_HAS_NO_MANAGER_ERR_MSG));
}  */

      displayPopup = true;
    }
  }

  /*
   * Method Name: initiateProcess
   * Input Parameters: -
   * Purpose: This method is called when the record is finally submitted for approval
   * Created By:  Himani Tanwar
   */
  public PageReference initiateProcess() {
    Account acc1 = accRecord;
    System.debug('acc1 before save = ' + acc1);
    PageReference pr = accountRec.save();
    System.debug('acc1 after save= ' + acc1);

    Account acc2 = [
      SELECT Id, Proposed_Account_Owner__r.Name, Owner_Name__c
      FROM Account
      WHERE Id = :acc1.Id
    ];
    if (
      accRecord.Proposed_Account_Owner__c != null &&
      accRecord.Proposed_Account_Owner__c != accRecord.OwnerId
    ) {
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      req1.setComments(
        'Current Owner: ' +
        acc2.Owner_Name__c +
        '\n' +
        'Proposed Owner: ' +
        acc2.Proposed_Account_Owner__r.Name
      );
      req1.setObjectId(accRecord.id);

      // Submit the approval request for the Account
      Approval.ProcessResult result = Approval.process(req1);
    }

    PageReference tempPage = new PageReference(
      '/apex/AccountOwnerChangePage?id=' + acc1.Id
    );
    tempPage.setRedirect(true);
    return tempPage;

    /*
        showApprovalProcess = FALSE;
        isRecordSubmittedForApproval = TRUE;
        isRecordInApprovalProcess = TRUE;
        
        Account acc2 = [Select Id, Proposed_Owners_Manager__r.Name, PreviousOwnersManager__r.Name, UserWhoProposedNewOwner__r.Name, ApprovalProcessInitiatedOn__c, TimeofStep1Approval__c, TimeofStep2Approval__c from Account where Id =:acc1.Id Limit 1];
        System.debug('acc2 = '  + acc2);
        System.debug('acc2.ApprovalProcessInitiatedOn__c = '  + acc2.ApprovalProcessInitiatedOn__c);
        System.debug('acc2.userWhoProposedNewOwner__c = '  + acc2.userWhoProposedNewOwner__c);
		
		if(acc2.ApprovalProcessInitiatedOn__c != NULL){
            approvalProcessInitiatedOn2 = String.valueOf(acc2.ApprovalProcessInitiatedOn__c.format('MM/dd/yyyy hh:mm'));
        
			if(!String.isBlank(acc2.userWhoProposedNewOwner__c)){
				userWhoProposedNewOwner = acc2.userWhoProposedNewOwner__r.Name;
				statusOfStep1Approval = Label.APPROVAL_PROCESS_PENDING;
				statusOfStep2Approval = Label.APPROVAL_PROCESS_PENDING;
				statusOfStep3Approval = Label.APPROVAL_PROCESS_PENDING;
				dateTimeOfStep1Approval = Label.APPROVAL_PROCESS_HYPHEN;
				dateTimeOfStep2Approval = Label.APPROVAL_PROCESS_HYPHEN;
				dateTimeOfStep3Approval = Label.APPROVAL_PROCESS_HYPHEN;
				PageReference tempPage = new PageReference('/apex/AccountOwnerChangePage?id='+acc1.Id);           
				tempPage.setRedirect(true);
				return tempPage;
			}
		}
		return null;*/
  }

  /*
   * Method Name: checkCurrentUserAuthorizedToApprove
   * Input Parameters: Account
   * Purpose: This method is used to check whether or not the logged in user is authorized to approve/reject/abort the approval process or not. Only the authorized users can view the Approval buttons on the visualforce page
   * Created By:  Himani Tanwar
   */
  @TestVisible
  private void checkCurrentUserAuthorizedToApprove(Account acc1) {
    //Account acc1 = accRecord;
    ProcessInstance pi = new ProcessInstance();
    pi = [
      SELECT
        Id,
        TargetObjectid,
        Status,
        (SELECT id, actor.name FROM Workitems),
        (SELECT Id, StepStatus, Comments, Actor.Name FROM Steps)
      FROM ProcessInstance
      WHERE TargetObjectId = :acc1.Id AND Status = 'Pending'
      LIMIT 1
    ];

    ProcessInstanceWorkitem wi = new ProcessInstanceWorkitem();
    if (pi.Id != null) {
      wi = [
        SELECT id, actor.name
        FROM ProcessInstanceWorkitem
        WHERE ProcessInstanceId = :pi.Id
        LIMIT 1
      ];

      if (wi.Id != null) {
        if (!String.isBlank(wi.ActorId)) {
          currentApprover = wi.ActorId;
        }
      }
    }
    String currentLoggedInUserProfile = fetchCurrentLoggedInUserProfile();
    User currentLoggedInUser = fetchCurrentLoggedInUser();
    if (currentApprover == currentLoggedInUser.Id)
      isUserAuthorizedToApprove = true;
    if (currentLoggedInUserProfile == ConstantClass.SYSTEM_ADMINISTRATOR)
      isUserSystemAdmin = true;
  }

  /*
   * Method Name: approveProcess
   * Input Parameters: -
   * Purpose: This method is used to approve the record when user clicks on Approve button on visualforce page
   * Created By:  Himani Tanwar
   */
  public PageReference approveProcess() {
    Account acc = (Account) accountRec.getRecord();

    Opportunity_Split_Constant__mdt objOpportunitySplitCustomMetadata = [
      SELECT Trigger_Handlers__c
      FROM Opportunity_Split_Constant__mdt
      WHERE DeveloperName = 'Bypass_Handlers'
      LIMIT 1
    ];
    for (
      String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
        ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
      )
    ) {
      TriggerHandler.bypass(strHandlerToBypass);
    }

    accountRec.save();

    for (
      String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
        ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
      )
    ) {
      TriggerHandler.clearBypass(strHandlerToBypass);
    }

    Account acc2 = [
      SELECT
        Id,
        PreviousOwner__r.Name,
        Proposed_Account_Owner__r.Email,
        PreviousOwner__r.Email,
        Proposed_Account_Owner__r.Name,
        ProposedAccountOwnerCopy__c,
        Proposed_Owners_Manager_Copy__c,
        Proposed_Owners_Manager__r.Name,
        PreviousOwnersManager__r.Name,
        UserWhoProposedNewOwner__r.Name,
        ApprovalProcessInitiatedOn__c,
        TimeofStep1Approval__c,
        TimeofStep2Approval__c,
        TimeofStep3Approval__c
      FROM Account
      WHERE Id = :acc.Id
      LIMIT 1
    ];
    User currentUser = fetchCurrentLoggedInUser();
    ProcessInstanceWorkitem pItem = new ProcessInstanceWorkItem();
    if (Approval.isLocked(acc.Id)) {
      Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
      req.setComments('Approved by ' + currentUser.Name);
      req.setAction('Approve');

      if (acc.id != null)
        pItem = [
          SELECT Id, Actor.Email
          FROM ProcessInstanceWorkitem
          WHERE ProcessInstance.TargetObjectId = :acc.id
          LIMIT 1
        ];

      if (pItem.Id != null)
        req.setWorkitemId(pItem.Id);

      Approval.ProcessResult result = Approval.process(req);
    }

    if (
      statusOfStep3Approval == 'PENDING' &&
      statusOfStep2Approval != 'PENDING' &&
      statusOfStep1Approval != 'PENDING'
    ) {
      System.debug('Last Step Approval');
      System.debug('displayPopup = ' + displayPopup);
      displayPopup = false;
      newPopup = true;
      /*  List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();
            List<String> sendTo = new List<String>();
            sendTo.add(acc2.Proposed_Account_Owner__r.email);
            sendTo.add(acc2.PreviousOwner__r.email);
            sendTo.add(pItem.Actor.Email);
            EmailTemplate emailTemplate=[Select id from EmailTemplate where name =: 'Notification of Owner Change To New and Old Account Owner' limit 1];
            Contact conRecord = [SELECT Id FROM Contact LIMIT 1];
            if(conRecord != null){
                if(emailTemplate!=NULL){
                    Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                    singleEmail.setWhatId(acc2.Id);
                    singleEmail.setTemplateID(emailTemplate.Id);
                    singleEmail.setToAddresses(sendTo);
                    singleEmail.setTargetObjectId(conRecord.Id);
                    singleEmail.saveAsActivity = False;
                    if(singleEmail != Null)
                    {
                        list_singleEmails.add(singleEmail);
                    }
                }
            }
            
            if(!list_singleEmails.isEmpty())
            {
                
                Messaging.sendEmail(list_singleEmails);
            } */
      //     tempPage = new PageReference('/'+acc.Id);
      return null;
    }
    //else{
    //  AccountOwnerChangeController.lastApproval = false;
    //  tempPage = new PageReference('/apex/AccountOwnerChangePage?id='+acc.Id);
    //}

    PageReference tempPage = new PageReference(
      '/apex/AccountOwnerChangePage?id=' + acc.Id
    );
    tempPage.setRedirect(true);
    return tempPage;
  }

  /*
   * Method Name: rejectProcess
   * Input Parameters: -
   * Purpose: This method is used to reject the record when user clicks on Reject button on visualforce page
   * Created By:  Himani Tanwar
   */
  public PageReference rejectProcess() {
    Account acc = (Account) accountRec.getRecord();
    User currentUser = fetchCurrentLoggedInUser();
    if (Approval.isLocked(acc.Id)) {
      Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
      req.setComments('Rejected by ' + currentUser.Name);

      //Update user who rejected approval process on Account
      Account updateAcc = new Account();
      updateAcc.Id = acc.Id;
      updateAcc.Approval_Process_Action__c = ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED;
      updateAcc.ApprovalProcessRejectedBy__c = currentUser.Id;

      Database.update(updateAcc);

      req.setAction('Reject');
      ProcessInstanceWorkitem pItem = new ProcessInstanceWorkItem();
      if (acc.id != null)
        pItem = [
          SELECT Id
          FROM ProcessInstanceWorkitem
          WHERE ProcessInstance.TargetObjectId = :acc.id
          LIMIT 1
        ];
      if (pItem.Id != null)
        req.setWorkitemId(pItem.Id);
      Approval.ProcessResult result = Approval.process(req);
    }
    PageReference recordPage = new PageReference('/' + acc.Id);
    recordPage.setRedirect(true);
    return recordPage;
  }

  /*
   * Method Name: abortProcess
   * Input Parameters: -
   * Purpose: This method is used to abort the record when user clicks on Abort button on visualforce page
   * Created By:  Himani Tanwar
   */
  public PageReference abortProcess() {
    Account acc = (Account) accountRec.getRecord();
    User currentUser = fetchCurrentLoggedInUser();
    if (Approval.isLocked(acc.Id)) {
      Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
      req.setComments('Process Aborted by ' + currentUser.Name);

      //Update user who rejected approval process on Account
      Account updateAcc = new Account();
      updateAcc.Id = acc.Id;
      updateAcc.ApprovalProcessRejectedBy__c = currentUser.Id;
      updateAcc.Approval_Process_Action__c = ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED;
      updateAcc.ApprovalProcessRejectedBy__c = currentUser.Id;
      Database.update(updateAcc, false);

      req.setAction('Removed');
      ProcessInstanceWorkitem pItem = new ProcessInstanceWorkItem();
      if (acc.id != null)
        pItem = [
          SELECT Id
          FROM ProcessInstanceWorkitem
          WHERE ProcessInstance.TargetObjectId = :acc.id
          LIMIT 1
        ];
      if (pItem.Id != null)
        req.setWorkitemId(pItem.Id);
      Approval.ProcessResult result = Approval.process(req);
    }
    PageReference recordPage = new PageReference('/' + acc.Id);
    recordPage.setRedirect(true);
    return recordPage;
  }

  /*
   * Method Name: fetchCurrentLoggedInUser
   * Input Parameters: -
   * Purpose: This method is used to fetch the logged in user
   * Created By:  Himani Tanwar
   */
  public User fetchCurrentLoggedInUser() {
    Id currentUserId = UserInfo.getUserId();
    User currentUser = [SELECT Id, Name FROM User WHERE Id = :currentUserId];
    return currentUser;
  }

  /*
   * Method Name: fetchCurrentLoggedInUserProfile
   * Input Parameters: -
   * Purpose: This method is used to fetch the profile of logged in user
   * Created By:  Himani Tanwar
   */
  public String fetchCurrentLoggedInUserProfile() {
    Id profileId = Userinfo.getProfileId();
    String currentUserProfileName = [
      SELECT Id, Name
      FROM Profile
      WHERE Id = :profileId
    ]
    .Name;
    return currentUserProfileName;
  }

  /*
   * Method Name: displayPopup
   * Input Parameters: -
   * Purpose: This method is used to set attribute, used to display popup, to true
   * Created By:  Himani Tanwar
   */
  public void displayPopup() {
    displayPopup = true;
  }

  /*
   * Method Name: displayPopup
   * Input Parameters: -
   * Purpose: This method is used to set attribute, used to display popup, to false
   * Created By:  Himani Tanwar
   */
  public void closePopup() {
    displayPopup = false;
  }

  /*
   * Method Name: displayPopup
   * Input Parameters: -
   * Purpose: This method is used to set attribute, used to display popup, to false
   * Created By: Dhruv Raisinghani
   */
  public void notificationPopup() {
    notificationPopup = false;
  }

  public List<String> getAllFields() {
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
      .get('Account')
      .getDescribe()
      .fields.getMap();
    List<String> fieldNames;
    if (
      fieldMap != null &&
      fieldMap.keySet() != null &&
      !fieldMap.keySet().isEmpty()
    ) {
      fieldNames = new List<String>();
      for (Schema.SObjectField sfield : fieldMap.Values()) {
        fieldNames.add(sfield.getDescribe().getName());
      }
      if (fieldNames != null && !fieldNames.isEmpty()) {
        fieldNames.add('Proposed_Owners_Manager__r.Name');
        fieldNames.add('PreviousOwnersManager__r.Name');
        fieldNames.add('UserWhoProposedNewOwner__r.Name');
        return fieldNames;
      }
    }
    return null;
  }

  /*
   * Method Name: moveToAccountDetail
   * Input Parameters: -
   * Purpose: This method is used to redirect the user to the record detail page after it is fully approved
   * Created By:  Dhruv Raisinghani
   */
  public PageReference moveToAccountDetail() {
    Account acc = (Account) accountRec.getRecord();
    PageReference pr = new PageReference('/' + acc.Id);
    pr.setRedirect(true);
    return pr;
  }
}
