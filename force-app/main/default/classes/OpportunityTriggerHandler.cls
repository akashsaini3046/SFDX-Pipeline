public with sharing class OpportunityTriggerHandler extends TriggerHandler {
  List<Opportunity> newOpportunityList;
  List<Opportunity> oldOpportunityList;
  public static Boolean isRecursion = false;
  Map<Id, Opportunity> oldOpportunityMap = new Map<Id, Opportunity>();
  Map<Id, Opportunity> newOpportunityMap = new Map<Id, Opportunity>();

  //Constructor
  public OpportunityTriggerHandler() {
    this.newOpportunityList = (List<Opportunity>) Trigger.new;
    this.oldOpportunityList = (List<Opportunity>) Trigger.old;
    this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
    this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
  }
  //Override the before insert method
  public override void beforeInsert() {
    ConvertUpperCase.convertToUpperCase('Opportunity', newOpportunityList);
    setOppOwnerAsAccOwner(newOpportunityList);
    associateContactWithOpportunity(newOpportunityList);
    populateContractRep(newOpportunityList, null);
  }

  //Override the before update method
  public override void beforeUpdate() {
    ConvertUpperCase.convertToUpperCase('Opportunity', newOpportunityList);
    associateContactWithOpportunity(newOpportunityList);
    populateContractRep(newOpportunityList, oldOpportunityMap);
  }

  //Override the before delete method
  public override void beforeDelete() {
    preventOppFromDeletion(oldOpportunityList);
    sendEmailToAccountTeamMembers(newOpportunityMap, oldOpportunityMap);
  }

  public override void afterInsert() {
    createTask(newOpportunityList);
    createTaskForHotStage(newOpportunityList, oldOpportunityMap);
    if (isRecursion == false) {
      createOppLineItems(newOpportunityMap, oldOpportunityMap);
      sendEmailToAccountTeamMembers(newOpportunityMap, oldOpportunityMap);
    }
    uniqueServicesOnAccount(newOpportunityList, oldOpportunityMap);
    createOppTeamMember(newOpportunityList);
    deleteNeglectedAccountRecord(newOpportunityList, oldOpportunityMap);
  }

  public override void afterUpdate() {
    if (isRecursion == false) {
      createOppLineItems(newOpportunityMap, oldOpportunityMap);
      sendEmailToAccountTeamMembers(newOpportunityMap, oldOpportunityMap);
      //  sendEmailsToOppTeamMembers(newOpportunityList, oldOpportunityMap);
    }
    //createContractRecord(newOpportunityMap, oldOpportunityMap);
    uniqueServicesOnAccount(newOpportunityList, oldOpportunityMap);
    createTaskForHotStage(newOpportunityList, oldOpportunityMap);
    OpportunitySplitController.restoreLostOpportunityLineItem(
      newOpportunityList,
      oldOpportunityMap
    );
    deleteNeglectedAccountRecord(newOpportunityList, oldOpportunityMap);
  }

  private static void createTask(List<Opportunity> opportunityList) {
    List<Task> tasksToCreateList = new List<Task>();
    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        if (!opp.Rating__c && opp.Create_Follow_Up_Task__c) {
          Task t = new Task();
          t.Subject =
            System.Label.Automated_Follow_Up_Task_Prefix +
            ' Follow up on Opportunity';
          t.Priority = 'Normal';
          t.Status = 'Open';
          t.TaskSubtype = 'Task';
          t.Type = 'Other';
          t.WhatId = opp.Id;
          t.ActivityDate = Date.today() + 2;
          t.OwnerId = opp.OwnerId;
          t.Description = 'Automated task to follow up on new opportunity.';
          tasksToCreateList.add(t);
        }
      }
    }
    if (tasksToCreateList != null && !tasksToCreateList.isEmpty()) {
      insert tasksToCreateList;
    }
  }

  /*
   * Method Name: createOppTeamMember
   * Purpose: This method will add the user who creates the opportunity as an opportunity team member if he is not the owner of that opportunity
   * Created By:  Dhruv Raisinghani(2nd Oct, 2019)
   * Last Modified By: Dhruv Raisinghani(2nd Oct, 2019)
   */
  private void createOppTeamMember(List<Opportunity> newOpportunityList) {
    if (newOpportunityList != null && !newOpportunityList.isEmpty()) {
      List<OpportunityTeamMember> oppTeamMemCreateList = new List<OpportunityTeamMember>();
      //  Set<Id> accountIdSet = new Set<Id>();
      //  List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
      //  Map<Id,List<AccountTeamMember>> accIdTeamMemberMap = new Map<Id,List<AccountTeamMember>>();
      //  Map<Id,List<Id>> accIdToMemberUserId = new Map<Id,List<Id>>();

      for (Opportunity opp : newOpportunityList) {
        OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
        oppTeamMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_OPP_CREATOR;
        oppTeamMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
        oppTeamMem.UserId = opp.CreatedById;
        oppTeamMem.OpportunityId = opp.Id;
        oppTeamMemCreateList.add(oppTeamMem);
      }
      WithoutSharingUtility.insertOpportunityTeamMemberRecords(
        oppTeamMemCreateList
      );
    }
  }
  /*    for(Opportunity opp: newOpportunityList){
                
                accountIdSet.add(opp.AccountId);
                
            }
            
            accTeamList = WithoutSharingUtility.queryAccountTeamMember(accountIdSet);
            if(accTeamList != Null){
                for(AccountTeamMember accMem: accTeamList){
                    
                    if(!accIdTeamMemberMap.containsKey(accMem.AccountId)){
                        accIdTeamMemberMap.put(accMem.AccountId, new List<AccountTeamMember>());
                        accIdToMemberUserId.put(accMem.AccountId, new List<Id>());
                    }
                    accIdToMemberUserId.get(accMem.AccountId).add(accMem.UserId);
                    accIdTeamMemberMap.get(accMem.AccountId).add(accMem);   
                    
                }   
            }
            System.debug('accTeamList'+accTeamList);
            System.debug('accIdTeamMemberMap'+accIdTeamMemberMap);
            System.debug('accIdToMemberUserId' +accIdToMemberUserId);
            
            if(accTeamList != Null && !accTeamList.isEmpty()){
                
                System.debug('Enter in IF');
                for(Opportunity opp: newOpportunityList){
                    
                    
                    if(opp.CreatedById != opp.OwnerId){
                        
                        if(accIdToMemberUserId.containsKey(opp.AccountId)){
                            
                            if(accIdToMemberUserId.get(opp.AccountId).contains(opp.CreatedById)){
                                
                                
                                if(accIdTeamMemberMap.containsKey(opp.AccountId)){
                                    
                                    
                                    if(accIdTeamMemberMap.get(opp.AccountId) != Null){
                                        
                                        
                                        List<AccountTeamMember> accTeam = accIdTeamMemberMap.get(opp.AccountId);
                                        
                                        
                                        for(AccountTeamMember accMem: accTeam){
                                            
                                            if(accMem.UserId == opp.CreatedById){
                                                
                                                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                                                oppTeamMem.TeamMemberRole = accMem.TeamMemberRole;
                                                oppTeamMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
                                                oppTeamMem.UserId = opp.CreatedById;
                                                oppTeamMem.OpportunityId = opp.Id;
                                                oppTeamMemCreateList.add(oppTeamMem);
                                            }
                                            
                                        }
                                    }
             
                                }
                            }
                            else{
                                
                                System.debug('Enter in else 1');
                                OpportunityTeamMember oppTeamMem1 = new OpportunityTeamMember();
                                oppTeamMem1.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_OPP_CREATOR;
                                oppTeamMem1.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
                                oppTeamMem1.UserId = opp.CreatedById;
                                oppTeamMem1.OpportunityId = opp.Id;
                                oppTeamMemCreateList.add(oppTeamMem1);
                            }       
                            
                        }
                    }
                }
            }
            
            else{
                
                System.debug('Enter in else 2');
                for(Opportunity opp: newOpportunityList){
                    
                    if(opp.CreatedById != opp.OwnerId){
                        
                        OpportunityTeamMember oppTeamMem2 = new OpportunityTeamMember();
                        oppTeamMem2.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_OPP_CREATOR;
                        oppTeamMem2.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
                        oppTeamMem2.UserId = opp.CreatedById;
                        oppTeamMem2.OpportunityId = opp.Id;
                        oppTeamMemCreateList.add(oppTeamMem2);
                    }
                }
                
            }
            
            System.debug('oppTeamMemCreateList'+oppTeamMemCreateList);
            WithoutSharingUtility.insertOpportunityTeamMemberRecords(oppTeamMemCreateList); 
        }
} }*/

  private static void createTaskForHotStage(
    List<Opportunity> opportunityList,
    Map<Id, Opportunity> mapOldOpportunity
  ) {
    List<Task> tasksToCreateList = new List<Task>();
    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        if (
          opp.Rating__c &&
          (mapOldOpportunity == null ||
          (mapOldOpportunity != null &&
          mapOldOpportunity.get(opp.Id).Rating__c != opp.Rating__c)) &&
          opp.Create_Follow_Up_Task__c
        ) {
          Task t = new Task();
          t.Subject =
            System.Label.Automated_Follow_Up_Task_Prefix +
            ' Follow up on Opportunity';
          t.Priority = 'Normal';
          t.Status = 'Open';
          t.TaskSubtype = 'Task';
          t.Type = 'Other';
          t.WhatId = opp.Id;
          t.ActivityDate = Date.today();
          t.OwnerId = opp.OwnerId;
          t.Description = 'Automated task to follow up on new analyzing opportunity.';
          tasksToCreateList.add(t);
        }
      }
    }
    if (tasksToCreateList != null && !tasksToCreateList.isEmpty()) {
      insert tasksToCreateList;
    }
  }

  //Prevent opportunity from deletion if
  // -> opportunity stage is Closed Won
  // -> user profile is not Sales Manager or Sales Leader

  private static void preventOppFromDeletion(
    List<Opportunity> opportunityList
  ) {
    Id profileId = UserInfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;

    Map<String, ProfileNames__c> profileNames = ProfileNames__c.getall();

    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        if (!Label.SYSTEM_ADMINISTRATOR.contains(profileName)) {
          if (opp.IsClosed)
            opp.addError('You cannot delete a closed opportunity.');
          else {
            if (!profileNames.containsKey(profileName))
              opp.addError(
                'Deletion of opportunity is not allowed, please contact your manager.'
              );
          }
        }
      }
    }
  }

  //Assign Opportunity owner as Account owner on which opportunity is created.
  private static void setOppOwnerAsAccOwner(List<Opportunity> opportunityList) {
    Set<Id> accountIdSet = new Set<Id>();
    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        if (opp.AccountId != null)
          accountIdSet.add(opp.AccountId);
      }
    }

    List<Account> accList = new List<Account>();
    if (accountIdSet != null && !accountIdSet.isEmpty())
      accList = [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIdSet];

    Map<Id, String> map_AccId_AccOwner = new Map<Id, String>();
    if (accList != null && !accList.isEmpty()) {
      for (Account acc : accList) {
        map_AccId_AccOwner.put(acc.Id, acc.OwnerId);
      }
    }

    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        if (map_AccId_AccOwner.containsKey(opp.AccountId)) {
          String accOwner = map_AccId_AccOwner.get(opp.AccountId);
          opp.OwnerId = accOwner;
        }
      }
    }
  }

  //Create new opportunity line items from values as selected in ‘Service Type’ field on opportunity and
  //Delete existing opportunity line items that are not selected in 'Service Type' field after update
  private static void createOppLineItems(
    Map<Id, Opportunity> newOppMap,
    Map<Id, Opportunity> oldOppMap
  ) {
    isRecursion = true;
    //Create map of old opportunity id and services
    Set<String> allNewOldServices = new Set<String>();
    Map<Id, Set<String>> oldmap_OppId_servicesSet = new Map<Id, Set<String>>();
    if (oldOppMap != null && !oldOppMap.isEmpty()) {
      for (Opportunity oldOpp : oldOppMap.values()) {
        if (
          newOppMap.get(oldOpp.Id).Service_Type__c !=
          oldOppMap.get(oldOpp.Id).Service_Type__c
        ) {
          if (oldOpp.Service_Type__c != null) {
            allNewOldServices.addAll(oldOpp.Service_Type__c.split(';'));
            Set<String> oldServicesSet = new Set<String>();
            oldServicesSet.addAll(oldOpp.Service_Type__c.split(';'));
            oldmap_OppId_servicesSet.put(oldOpp.Id, oldServicesSet);
          }
        }
      }
    }

    //Create map of new opportunity id and services
    Map<Id, Set<String>> newmap_OppId_servicesSet = new Map<Id, Set<String>>();
    if (newOppMap.values() != null && !newOppMap.values().isEmpty()) {
      for (Opportunity newOpp : newOppMap.values()) {
        if (newOpp.Service_Type__c != null) {
          allNewOldServices.addAll(newOpp.Service_Type__c.split(';'));
          Set<String> newServicesSet = new Set<String>();
          newServicesSet.addAll(newOpp.Service_Type__c.split(';'));
          newmap_OppId_servicesSet.put(newOpp.Id, newServicesSet);
        }
      }
    }
    //Fetching only those services that needs to be created
    Map<Id, Set<String>> map_oppId_ServicesToCreate = new Map<Id, Set<String>>();
    if (newOppMap.values() != null && !newOppMap.values().isEmpty()) {
      for (Opportunity opp : newOppMap.values()) {
        Set<String> newServiceSet = newmap_OppId_servicesSet.get(opp.Id);
        Set<String> oldServiceSet = oldmap_OppId_servicesSet.get(opp.Id);

        // In case of UPDATE
        if (oldServiceSet != null && !oldServiceSet.isEmpty()) {
          if (newServiceSet != null && !newServiceSet.isEmpty()) {
            for (String newService : newServiceSet) {
              if (!oldServiceSet.contains(newService)) {
                Set<String> servicesToCreateSet = map_oppId_ServicesToCreate.get(
                  opp.Id
                );
                if (servicesToCreateSet == null)
                  servicesToCreateSet = new Set<String>();
                servicesToCreateSet.add(newService);
                map_oppId_ServicesToCreate.put(opp.Id, servicesToCreateSet);
              }
            }
          }
        }

        // In case of INSERT
        if (oldServiceSet == null || oldServiceSet.isEmpty()) {
          if (newServiceSet != null && !newServiceSet.isEmpty()) {
            for (String newService : newServiceSet) {
              Set<String> servicesToCreateSet = map_oppId_ServicesToCreate.get(
                opp.Id
              );
              if (servicesToCreateSet == null)
                servicesToCreateSet = new Set<String>();
              servicesToCreateSet.add(newService);
              map_oppId_ServicesToCreate.put(opp.Id, servicesToCreateSet);
            }
          }
        }
      }
    }

    //Opportunity Line Item will be fetched in case of Opportunity Update only
    List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
    if (oldOppMap != null) {
      if (oldOppMap.keySet() != null && newOppMap.keySet() != null) {
        oppLineItemList = [
          SELECT Id, Name, Product2.Name, OpportunityId
          FROM OpportunityLineItem
          WHERE
            OpportunityId IN :newOppMap.keySet()
            OR opportunityId IN :oldOppMap.keySet()
        ];
      }
    }

    //Fetch the PriceBookEntry records corresponding to the services selected
    List<PriceBookEntry> priceBookList = new List<PriceBookEntry>();
    if (allNewOldServices != null && !allNewOldServices.isEmpty()) {
      priceBookList = [
        SELECT Id, Product2Id, Product2.Id, Product2.Name
        FROM PriceBookEntry
        WHERE Product2.Name IN :allNewOldServices
      ];
    }

    //Created map of product name and the PriceBookEntry id.
    //Used to fetch the PriceBookEntry Id corresponding to the service while creating Opportunity Line Items.
    //Useful in case where user inserts or updates services with wrong spelling
    Map<String, Id> map_productName_productId = new Map<String, Id>();
    if (priceBookList != null && !priceBookList.isEmpty()) {
      for (PriceBookEntry p : priceBookList) {
        map_productName_productId.put(p.Product2.Name, p.Id);
      }
    }

    //Created map of existing opportunity line items' product and opportunity line item.
    //Used to check whether the service selected already has an opportunity line item record associated with the opportunity.
    Map<String, OpportunityLineItem> map_prodName_oppLineItemId = new Map<String, OpportunityLineItem>();
    if (oppLineItemList != null && !oppLineItemList.isEmpty()) {
      for (OpportunityLineItem oppLineItem : oppLineItemList) {
        map_prodName_oppLineItemId.put(
          oppLineItem.OpportunityId + oppLineItem.Product2.Name,
          oppLineItem
        );
      }
    }

    //Fetch opportunity line items that needs to be deleted
    Map<Id, List<OpportunityLineItem>> map_oppId_ServicesToDelete = new Map<Id, List<OpportunityLineItem>>();
    if (newOppMap.values() != null && !newOppMap.values().isEmpty()) {
      for (Opportunity opp : newOppMap.values()) {
        Set<String> newServiceSet = newmap_OppId_servicesSet.get(opp.Id);
        Set<String> oldServiceSet = oldmap_OppId_servicesSet.get(opp.Id);

        if (oldServiceSet != null && !oldServiceSet.isEmpty()) {
          for (String oldService : oldServiceSet) {
            if (!newServiceSet.contains(oldService)) {
              List<OpportunityLineItem> servicesToDeleteList = map_oppId_ServicesToDelete.get(
                opp.Id
              );
              if (servicesToDeleteList == null)
                servicesToDeleteList = new List<OpportunityLineItem>();

              servicesToDeleteList.add(
                map_prodName_oppLineItemId.get(opp.Id + oldService)
              );
              map_oppId_ServicesToDelete.put(opp.Id, servicesToDeleteList);
            }
          }
        }
      }
    }

    List<OpportunityLineItem> oppLineItemListToDelete = new List<OpportunityLineItem>();
    if (
      map_oppId_ServicesToDelete.values() != null &&
      !map_oppId_ServicesToDelete.values().isEmpty()
    ) {
      for (
        List<OpportunityLineItem> oppLineItem : map_oppId_ServicesToDelete.values()
      ) {
        oppLineItemListToDelete.addAll(oppLineItem);
      }
    }

    //Fetch list of existing opportunity line items related to opportunity
    Map<Id, Set<OpportunityLineItem>> map_oppId_oppLineItemSet1 = new Map<Id, Set<OpportunityLineItem>>();
    Map<Id, Set<String>> map_oppId_oppLineItemSet = new Map<Id, Set<String>>();
    if (oppLineItemList != null && !oppLineItemList.isEmpty()) {
      for (OpportunityLineItem oppLineItem : oppLineItemList) {
        Set<String> oppLineItemSet = map_oppId_oppLineItemSet.get(
          oppLineItem.OpportunityId
        );
        if (oppLineItemSet == null)
          oppLineItemSet = new Set<String>();
        oppLineItemSet.add(oppLineItem.Product2.Name);
        map_oppId_oppLineItemSet.put(oppLineItem.OpportunityId, oppLineItemSet);
      }
    }
    //Create new opportunity line item
    List<OpportunityLineItem> oppLineItemToInsert = new List<OpportunityLineItem>();
    if (
      map_oppId_ServicesToCreate.keySet() != null &&
      !map_oppId_ServicesToCreate.keySet().isEmpty()
    ) {
      for (Id oppId : map_oppId_ServicesToCreate.keySet()) {
        Set<String> servicesSet = new Set<String>();
        servicesSet = map_oppId_ServicesToCreate.get(oppId);
        Set<String> existingOppLineItemSet = map_oppId_oppLineItemSet.get(
          oppId
        );
        if (servicesSet != null && !servicesSet.isEmpty()) {
          for (String service : servicesSet) {
            // In case of UPDATE
            if (
              existingOppLineItemSet != null &&
              !existingOppLineItemSet.isEmpty()
            ) {
              if (!existingOppLineItemSet.contains(service)) {
                if (map_productName_productId.containsKey(service)) {
                  OpportunityLineItem oppLineItem = new OpportunityLineItem();
                  oppLineItem.UnitPrice = 0;
                  oppLineItem.Quantity = 1;
                  oppLineItem.ServiceDate = newoppMap.get(OppId)
                    .Est_Business_Start_Date__c;
                  oppLineItem.OpportunityId = oppId;
                  oppLineItem.PricebookEntryId = map_productName_productId.get(
                    service
                  );
                  oppLineItemToInsert.add(oppLineItem);
                }
              }
            }

            // In case of INSERT
            if (
              existingOppLineItemSet == null || existingOppLineItemSet.isEmpty()
            ) {
              if (map_productName_productId.containsKey(service)) {
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.UnitPrice = 0;
                oppLineItem.Quantity = 1;
                oppLineItem.ServiceDate = newoppMap.get(OppId)
                  .Est_Business_Start_Date__c;
                oppLineItem.OpportunityId = oppId;
                oppLineItem.PricebookEntryId = map_productName_productId.get(
                  service
                );
                oppLineItemToInsert.add(oppLineItem);
              }
            }
          }
        }
      }
    }
    if (oppLineItemToInsert != null && !oppLineItemToInsert.isEmpty()) {
      try {
        // insert oppLineItemToInsert;
        OpportunityLineItemTriggerHandler.validationCheck = false;
        WithoutSharingUtility.insertServiceRecords(oppLineItemToInsert);
      } catch (Exception e) {
        System.debug(
          logginglevel.ERROR,
          'MESSAGE:' +
          e.getMessage() +
          'STACK TRACE:' +
          e.getStackTraceString()
        );
      }
    }

    if (oppLineItemListToDelete != null && !oppLineItemListToDelete.isempty()) {
      try {
        delete oppLineItemListToDelete;
      } catch (Exception e) {
        System.debug(
          logginglevel.ERROR,
          'MESSAGE:' +
          e.getMessage() +
          'STACK TRACE:' +
          e.getStackTraceString()
        );
      }
    }
  }

  //Count number of Unique Services associated with account
  //This field is used in Integrated Sales Report
  private void uniqueServicesOnAccount(
    List<Opportunity> newOpportunityList,
    Map<Id, Opportunity> oldOpportunityMap
  ) {
    List<Account> accListToUpdate = new List<Account>();
    try {
      Set<Id> accountIdSet = new Set<Id>();
      if (newOpportunityList != null && !newOpportunityList.isEmpty()) {
        for (Opportunity opp : newOpportunityList) {
          if (
            Trigger.isInsert ||
            (oldOpportunityMap != null &&
            opp.Service_Type__c !=
            oldOpportunityMap.get(opp.Id).Service_Type__c)
          ) {
            if (opp.AccountId != null) {
              accountIdSet.add(opp.AccountId);
            }
          }
        }
      }

      List<Opportunity> oppList = new List<Opportunity>();
      if (accountIdSet != null && !accountIdSet.isEmpty())
        oppList = [
          SELECT Id, Service_Type__c, AccountId
          FROM Opportunity
          WHERE AccountId IN :accountIdSet
        ];

      Map<Id, Set<String>> mapAccIdServicesSet = new Map<Id, Set<String>>();
      if (oppList != null && !oppList.isEmpty()) {
        for (Opportunity opp : oppList) {
          Set<String> servicesSet = mapAccIdServicesSet.get(opp.AccountId);
          if (servicesSet == null)
            servicesSet = new Set<String>();
          if (opp.Service_Type__c != null)
            servicesSet.addAll(opp.Service_Type__c.split(';'));
          mapAccIdServicesSet.put(opp.AccountId, servicesSet);
        }
      }

      if (accountIdSet != null && !accountIdSet.isEmpty()) {
        for (Id accId : accountIdSet) {
          Account a = new Account();
          a.Id = accId;
          if (
            mapAccIdServicesSet.containsKey(accId) &&
            mapAccIdServicesSet.get(accId) != null
          ) {
            a.UniqueServices__c = mapAccIdServicesSet.get(accId).size();
            accListToUpdate.add(a);
          }
        }
      }

      if (accListToUpdate != null && !accListToUpdate.isEmpty())
        WithoutSharingUtility.updateUniqueServicesOnAccount(accListToUpdate);
    } catch (Exception e) {
      if (
        e.getMessage() ==
        'The Account you have selected is not a valid Beachhead Reporting Account'
      ) {
        e.setMessage(
          'Account on Opportunity has an invalid Reporting Beachhead Account added. Please update the account before proceeding.'
        );
      }
      System.debug('Exception-----------------' + e.getStackTraceString());
    }
  }

  private void associateContactWithOpportunity(
    List<Opportunity> newOpportunityList
  ) {
    String accId = '';
    String conId = '';
    for (Opportunity opp : newOpportunityList) {
      if (opp.Opportunity_Created_From_Lead__c) {
        ConstantClass.OPPLEADCONVERSION = true;
        opp.Opportunity_Created_From_Lead__c = false;
        accId = opp.AccountId;
        break;
      }
    }
    if (accId != '') {
      for (Contact c : [
        SELECT Id
        FROM Contact
        WHERE Contact_Created_From_Lead__c = TRUE AND AccountId = :accId
        LIMIT 1
      ]) {
        conId = c.Id;
      }
    }

    if (null != conId && !String.IsBlank(conId)) {
      for (Opportunity opp : newOpportunityList) {
        opp.Contact__c = conId;
      }
    }
  }

  // Code Commented as part of Contract Data Cleanup for using DocuSign Contracts
  /* private void createContractRecord(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){
        
        List<Contract> contractList = new List<Contract>();
        Set<Id> accIdList = new Set<Id>();
        
        Map<String, List<String>> oppToExistingContractMap = new Map<String, List<String>>();
        
        for(Contract contractObj: [Select Id, Opportunity__c from Contract where Opportunity__c IN :newOppMap.keySet()]){
            if(!oppToExistingContractMap.containsKey(contractObj.Opportunity__c)){
                oppToExistingContractMap.put(contractObj.Opportunity__c, new List<String>());
            }
            oppToExistingContractMap.get(contractObj.Opportunity__c).add(contractObj.Id);
        }
        
        Id priceBookId = [Select Id from Pricebook2 where Name = 'Standard Price Book' LIMIT 1].Id;
        
        if(newOppMap != NULL && !newOppMap.isEmpty())
        {
            for(Opportunity opp: newOppMap.values())
            {
                if(opp.AccountId != NULL)
                    accIdList.add(opp.AccountId);
            }
        }
        
        List<Account> accList = new List<Account>();
        if(accIdList != NULL && !accIdList.isEmpty())
            accList = [Select Id, Business_Location__r.City__c, Business_Location__r.Country__c, Business_Location__r.Postal_Code__c, Business_Location__r.State_Picklist__c, Business_Location__r.Name, Business_Location__r.Address_Line_2__c, Business_Location__r.Address_Line_3__c from Account where id in: accIdList];
        
        Map<Id, Account> mapAccIdAccount = new Map<Id, Account>();
        if(accList != NULL && !accList.isEmpty()){
            for(Account acc: accList)
            {
                mapAccIdAccount.put(acc.Id, acc);
            }
        }
        
        if(newOppMap != NULL && !newOppMap.isEmpty()) // Added on 17th Dec
        {
            for(Opportunity oppObj: newOppMap.values()){
                if(OldOppMap.get(oppObj.Id).StageName!= oppObj.StageName && oppObj.StageName=='Contracting' && oppToExistingContractMap.size()==0){
                    
                    Account acc;
                    if(mapAccIdAccount.containsKey(oppObj.AccountId))
                        acc = mapAccIdAccount.get(oppObj.AccountId);
                    
                    Contract contractObj = new Contract();
                    contractObj.AccountId = OppObj.AccountId;
                    contractObj.Opportunity__c = OppObj.Id;
                    contractObj.StartDate = OppObj.Est_Business_Start_Date__c;
                    contractObj.ContractTerm = 12;
                    
                    if(!String.isBlank(OppObj.Service_Type__c))
                    {
                        contractObj.Services__c = OppObj.Service_Type__c;
                    }
                    
                    if(priceBookId != NULL)
                        contractObj.Pricebook2Id = priceBookId;
                    
                    if(acc !=NULL){
                        contractObj.BillingCity = acc.Business_Location__r.City__c;
                        contractObj.BillingCountry = acc.Business_Location__r.Country__c;
                        contractObj.BillingPostalCode = acc.Business_Location__r.Postal_Code__c;
                        contractObj.BillingState = acc.Business_Location__r.State_Picklist__c;
                        contractObj.BillingStreet = acc.Business_Location__r.Name + ' ' +  acc.Business_Location__r.Address_Line_2__c + ' ' + acc.Business_Location__r.Address_Line_3__c;
                    }
                    
                    contractList.add(contractObj);
                }
            }
        }
        if(!contractList.IsEmpty()){
            insert contractList;
        }
    } */

  //Send email to Account Team Members, when a opportunity is created, updated(stage change) or deleted.
  public void sendEmailToAccountTeamMembers(
    Map<Id, Opportunity> newOppMap,
    Map<Id, Opportunity> oldOppMap
  ) {
    isRecursion = true;
    Set<String> accountIdSet = new Set<String>();
    Map<Id, Set<String>> oldmap_OppId_servicesSet = new Map<Id, Set<String>>();
    List<String> listMembersExcluded = new List<String>();
    String teamRoles = System.Label.TEAM_ROLES_WITHOUT_NOTIFICATION;

    if (teamRoles != null && teamRoles != '') {
      if (teamRoles.contains(','))
        listMembersExcluded = teamRoles.split(',');
      else
        listMembersExcluded.add(teamRoles);
    }

    EmailTemplate emailTemplate;

    //In case of UPDATE
    if (oldOppMap != null && !oldOppMap.isEmpty()) {
      emailTemplate = [
        SELECT id, Name
        FROM EmailTemplate
        WHERE
          DeveloperName = 'Notification_to_all_account_team_member_on_opportunity_stage_change'
        LIMIT 1
      ];
      for (Opportunity oldOpp : oldOppMap.values()) {
        if (newOppMap != null && !newOppMap.isEmpty()) {
          if (
            newOppMap.get(oldOpp.Id).StageName !=
            oldOppMap.get(oldOpp.Id).StageName &&
            (newOppMap.get(oldOpp.Id).StageName == 'Closed Won' ||
            newOppMap.get(oldOpp.Id).StageName == 'Closed Lost' ||
            newOppMap.get(oldOpp.Id).StageName == 'Disqualified')
          ) {
            accountIdSet.add(oldOpp.AccountId);
          }
        } else {
          emailTemplate = [
            SELECT id, Name
            FROM EmailTemplate
            WHERE
              DeveloperName = 'Notification_to_all_account_team_member_on_opportunity_deletion'
            LIMIT 1
          ];
          accountIdSet.add(oldOpp.AccountId);
        }
      }
    }

    //In case of INSERT
    if (
      newOppMap != null &&
      !newOppMap.isEmpty() &&
      (oldOppMap == null || oldOppMap.isEmpty())
    ) {
      emailTemplate = [
        SELECT id, Name
        FROM EmailTemplate
        WHERE
          DeveloperName = 'Notification_to_all_account_team_member_on_opportunity_creation'
        LIMIT 1
      ];

      Set<Id> accIdSetTemp = new Set<Id>();
      for (Opportunity newOpp : newOppMap.values()) {
        accIdSetTemp.add(newOpp.AccountId);
      }
      List<Account> accListTemp = new List<Account>();
      accListTemp = [SELECT Id, OwnerId FROM Account WHERE Id IN :accIdSetTemp];

      Map<Id, Id> mapAccIdOwnerId = new Map<Id, Id>();
      for (Account acc : accListTemp) {
        mapAccIdOwnerId.put(acc.Id, acc.OwnerId);
      }

      for (Opportunity newOpp : newOppMap.values()) {
        Id accOwnerId = mapAccIdOwnerId.get(newOpp.AccountId);
        if (
          ConstantClass.OPPLEADCONVERSION == false // To prevent sending email when opportunity is created from lead conversion
        )
          accountIdSet.add(newOpp.AccountId);
      }
    }

    //Fetching account team members related to opportunities' accounts
    List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
    if (accountIdSet != null && !accountIdSet.isEmpty()) {
      accountTeamMemberList = [
        SELECT Id, UserId, AccountId, TeamMemberRole
        FROM AccountTeamMember
        WHERE
          AccountId IN :accountIdSet
          AND TeamMemberRole NOT IN :listMembersExcluded
      ];
    }

    //Used to create map of user id and user's email id. This map is further used to create map of account id and email id of the account team members
    List<Id> userIdList = new List<Id>();
    if (accountTeamMemberList != null && !accountTeamMemberList.isEmpty()) {
      for (AccountTeamMember accTeamMem : accountTeamMemberList) {
        userIdList.add(accTeamMem.UserId);
      }
    }
    Map<Id, User> mapUser = new Map<Id, User>();
    if (
      newOppMap != null &&
      !newOppMap.isEmpty() &&
      (oldOppMap == null || oldOppMap.isEmpty())
    ) {
      mapUser = new Map<Id, User>(
        [SELECT Id, Email FROM User WHERE Id IN :userIdList]
      );
    }
    List<User> userList = new List<User>();
    userList = mapUser.values();
    if (userIdList != null && !userIdList.isEmpty())
      userList = [SELECT Id, Email FROM User WHERE Id IN :userIdList];

    Map<Id, String> mapUserIdEmail = new Map<Id, String>();
    if (userList != null && !userList.isEmpty()) {
      for (User u : userList) {
        mapUserIdEmail.put(u.Id, u.Email);
      }
    }

    //Map of account id and email id of the account team members
    Map<Id, List<String>> mapAccIdUserEmailList = new Map<Id, List<String>>();
    if (accountTeamMemberList != null && !accountTeamMemberList.isEmpty()) {
      for (AccountTeamMember accTeamMem : accountTeamMemberList) {
        List<String> uEmailList = mapAccIdUserEmailList.get(
          accTeamMem.AccountId
        );
        if (uEmailList == null)
          uEmailList = new List<String>();
        uEmailList.add(mapUserIdEmail.get(accTeamMem.UserId));
        mapAccIdUserEmailList.put(accTeamMem.AccountId, uEmailList);
      }
    }

    List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();
    Set<Messaging.SingleEmailMessage> set_singleEmails = new Set<Messaging.SingleEmailMessage>();

    //Fetching random contact's email for setTargetObjectId.
    List<Contact> contactList = new List<Contact>();
    contactList = [SELECT id, Email FROM Contact WHERE email != NULL LIMIT 1];
    List<String> sendToAddresses = new List<String>();
    set<string> sendToAddressesSet = new Set<String>();
    //For sending email when opportunity is INSERTED or UPDATED
    if (newOppMap != null && !newOppMap.isEmpty()) {
      for (Opportunity opp : newOppMap.values()) {
        if (mapAccIdUserEmailList.containsKey(opp.AccountId)) {
          sendToAddresses = mapAccIdUserEmailList.get(opp.AccountId);
        }

        //if opportunity is inserted, only account owner and opportunity owner will not recieve email
        if (
          newOppMap != null &&
          !newOppMap.isEmpty() &&
          (oldOppMap == null || oldOppMap.isEmpty())
        ) {
          if (mapUserIdEmail != null) {
            sendToAddressesSet.addAll(sendToAddresses);
            sendToAddresses.clear();
            if (mapUser.containsKey(opp.CreatedById)) {
              if (
                mapUser.containsKey(opp.CreatedById) ==
                mapUser.containsKey(opp.OwnerId)
              ) {
                //created by account owner
                sendToAddressesSet.remove(mapUser.get(opp.OwnerId).email);
              } else {
                sendToAddressesSet.remove(mapUser.get(opp.CreatedById).email);
              }
            }
            sendToAddresses.addAll(sendToAddressesSet);
          }
        }
        //if is insert context then remove current login user's email from sendToAddresses
        if (
          sendToAddresses != null &&
          !sendToAddresses.isEmpty() &&
          contactList != null &&
          !contactList.isEmpty()
        ) {
          Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
          singleEmail.setWhatId(opp.Id);
          singleEmail.setTemplateID(emailTemplate.Id);
          singleEmail.setToAddresses(sendToAddresses);
          singleEmail.setTargetObjectId(contactList[0].Id);
          singleEmail.saveAsActivity = false;
          singleEmail.setTreatTargetObjectAsRecipient(false);
          set_singleEmails.add(singleEmail);
        }
      }

      //For sending email when opportunity is DELETED
      if (
        (newOppMap == null || newOppMap.isEmpty()) &&
        oldOppMap != null &&
        !oldOppMap.isEmpty()
      ) {
        for (Opportunity opp : oldOppMap.values()) {
          if (mapAccIdUserEmailList.containsKey(opp.AccountId))
            sendToAddresses = mapAccIdUserEmailList.get(opp.AccountId);

          if (sendToAddresses != null && !sendToAddresses.isEmpty()) {
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setWhatId(opp.Id);
            singleEmail.setTemplateID(emailTemplate.Id);
            singleEmail.setToAddresses(sendToAddresses);
            singleEmail.setTargetObjectId(contactList[0].Id);
            singleEmail.saveAsActivity = false;
            singleEmail.setTreatTargetObjectAsRecipient(false);
            set_singleEmails.add(singleEmail);
          }
        }
      }

      list_singleEmails.addAll(set_singleEmails);

      if (!list_singleEmails.isEmpty()) {
        Messaging.sendEmail(list_singleEmails);
      }
    }
  }

  /*
   * Method Name: deleteNeglectedAccountRecord
   * Input Parameters:
   * List<Task> lstNewTask: holds new opp list
   * Return value:
   * Purpose: Delete account records from Neglected Account Object on which new opp is created or updated.
   */

  private void deleteNeglectedAccountRecord(
    List<Opportunity> oppNewList,
    Map<Id, Opportunity> mapOldOpportunity
  ) {
    Set<Id> accountSetToDelete = new Set<Id>();
    List<Account> accList = new List<Account>();

    for (Opportunity opp : oppNewList) {
      if (Trigger.isUpdate) {
        if (opp.OwnerId == mapOldOpportunity.get(opp.Id).OwnerId) {
          accountSetToDelete.add(opp.AccountId);
        }
      } else {
        accountSetToDelete.add(opp.AccountId);
      }
    }
    accList = [
      SELECT Id, ParentId
      FROM Account
      WHERE Id IN :accountSetToDelete
    ];
    for (Account acc : accList) {
      if (acc.ParentId != null) {
        accountSetToDelete.add(acc.ParentId);
      }
    }
    if (accountSetToDelete != null) {
      NeglectedAccountReport.deleteNeglectedAccountRecord(accountSetToDelete);
    }
  }

  /*    public void sendEmailsToOppTeamMembers(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        
        Set<Opportunity> oppSet = new Set<Opportunity>();
        Map<Id, List<String>> oppIdtoEmailAddMap = new Map<Id, List<String>>();
        Map<Id, List<String>> accIdtoEmailAddMap = new Map<Id, List<String>>();
        List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
        Set<Messaging.SingleEmailMessage> singleEmailSet = new Set<Messaging.SingleEmailMessage>();
        List<Contact> contactList = new List<Contact>();
        List<Id> accountIdList = new List<Id>();
        
        for(Opportunity oppObj: newOppList){
            if(oppObj.StageName != oldOppMap.get(oppObj.Id).StageName){
                oppSet.add(oppObj);
                accountIdList.add(oppObj.AccountId);
            }
        }
        System.debug('accountIdList--------------'+accountIdList);
        EmailTemplate emailTemplate = [Select id,Name from EmailTemplate where DeveloperName = 'Notification_to_all_opp_team_member_on_opportunity_stage_change' limit 1];
        
        contactList = [select id, Email from Contact where email <> null limit 1];
        
        if(oppSet != Null && !oppSet.isEmpty()){
            
        for(OpportunityTeamMember oppteamMemObj: [Select Id, OpportunityId, User.Email from OpportunityTeamMember where OpportunityId IN :oppSet]){
            if(!oppIdtoEmailAddMap.containsKey(oppteamMemObj.OpportunityId)){
                oppIdtoEmailAddMap.put(oppteamMemObj.OpportunityId, new List<String>());
            }
            oppIdtoEmailAddMap.get(oppteamMemObj.OpportunityId).add(oppteamMemObj.User.Email);
        }
        
        for(AccountTeamMember accTeamMemObj: [Select Id, AccountId, User.Email from AccountTeamMember where AccountId IN :accountIdList ]){
            if(!accIdtoEmailAddMap.containskey(accTeamMemObj.AccountId)){
                accIdtoEmailAddMap.put(accTeamMemObj.AccountId, new List<String>());
            }
            accIdtoEmailAddMap.get(accTeamMemObj.AccountId).add(accTeamMemObj.User.Email);
        }
        System.debug('accIdtoEmailAddMap--------------'+accIdtoEmailAddMap);
        for(Opportunity oppObj: oppSet){
            List<String> emailAddresses = new List<String>();
            Boolean accTeamMemExist = false;
            if(oppIdtoEmailAddMap.size()> 0 && (oppObj.StageName == 'Closed Won' || oppObj.StageName == 'Closed Lost' || oppObj.StageName == 'Disqualified')){
                for(String emailAdd :oppIdtoEmailAddMap.get(oppObj.Id)){
                    if(accIdtoEmailAddMap.size()> 0 && accIdtoEmailAddMap.get(oppObj.AccountId).contains(emailAdd)){
                        accTeamMemExist = true;    
                    }else{
                        emailAddresses.add(emailAdd);       
                    }
                }
            }       
            if(accTeamMemExist){
                oppIdtoEmailAddMap.get(oppObj.Id).clear(); 
                if(emailAddresses.size()>0){
                    oppIdtoEmailAddMap.get(oppObj.Id).addAll(emailAddresses);  
                }
            }    
            
        }
        
        for(Opportunity oppObj: oppSet){
            if(oppIdtoEmailAddMap.size()> 0 && oppIdtoEmailAddMap.get(oppObj.Id).size()>0){
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setWhatId(oppObj.Id);
                singleEmail.setTemplateID(emailTemplate.Id);
                singleEmail.setToAddresses(oppIdtoEmailAddMap.get(oppObj.Id));
                singleEmail.setTargetObjectId(contactList[0].Id);
                singleEmail.saveAsActivity = False;
                singleEmail.setTreatTargetObjectAsRecipient(FALSE);
                singleEmailSet.add(singleEmail);    
            }    
        }
        singleEmailList.addAll(singleEmailSet);
        
        if(!singleEmailList.isEmpty()){
            Messaging.sendEmail(singleEmailList);
        }
    }
    } */

  /*
   * Method Name: populateContractRep
   * Input Parameters:
   * List<Opportunity> listOpportunity: holds new opp list
   * Map<Id, Opportunity> mapOldOpportunity : holds old map of opp
   * Return value:
   * Purpose: Populate Contract Rep on opportunity from Account Team when opporunity reaches Contracting Stage
   */
  public void populateContractRep(
    List<Opportunity> listOpportunity,
    Map<Id, Opportunity> mapOldOpportunity
  ) {
    List<Opportunity> listContractOpp = new List<Opportunity>();
    List<AccountTeamMember> listAccountTeam = new List<AccountTeamMember>();
    Map<Id, Id> mapContractRep = new Map<Id, Id>();
    Set<Id> setAccountId = new Set<Id>();

    for (Opportunity opp : listOpportunity) {
      if (mapOldOpportunity != null) {
        if (
          opp.StageName != null &&
          opp.StageName == 'Contracting' &&
          opp.StageName != mapOldOpportunity.get(opp.Id).StageName &&
          opp.AccountId != null
        ) {
          listContractOpp.add(opp);
          setAccountId.add(opp.AccountId);
        }
      } else if (
        opp.StageName != null &&
        opp.StageName == 'Contracting' &&
        opp.AccountId != null
      ) {
        listContractOpp.add(opp);
        setAccountId.add(opp.AccountId);
      }
    }

    if (!setAccountId.isEmpty()) {
      listAccountTeam = [
        SELECT Id, AccountId, UserId, TeamMemberRole
        FROM AccountTeamMember
        WHERE AccountId IN :setAccountId AND TeamMemberRole = 'Contracts Rep'
      ];
      if (!listAccountTeam.isEmpty()) {
        for (AccountTeamMember teamMember : listAccountTeam) {
          mapContractRep.put(teamMember.AccountId, teamMember.UserId);
        }

        for (Opportunity opp : listContractOpp) {
          if (
            opp.AccountId != null &&
            mapContractRep.containsKey(opp.AccountId) &&
            mapContractRep.get(opp.AccountId) != null
          )
            opp.Contract_Rep__c = mapContractRep.get(opp.AccountId);
        }
      }
    }
  }
}
