/*
 * Name: OpportunityLineItemTriggerHandler
 * Purpose: Handler class for OpportunityLineItem
 * Author: Nagarro
 */
public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
  List<OpportunityLineItem> newOpportunityLineItemList;
  List<OpportunityLineItem> oldOpportunityLineItemList;

  public static Boolean isRecursion = false;
  public static Boolean validationCheck = true;

  //Constructor
  public OpportunityLineItemTriggerHandler() {
    this.newOpportunityLineItemList = (List<OpportunityLineItem>) Trigger.new;
    this.oldOpportunityLineItemList = (List<OpportunityLineItem>) Trigger.old;
  }

  public override void afterInsert() {
    if (
      isRecursion == false &&
      OpportunityTriggerHandler.isRecursion == false
    ) {
      updateServiceOnOpportunity(newOpportunityLineItemList);
    }
  }

  public override void afterDelete() {
    if (
      isRecursion == false &&
      OpportunityTriggerHandler.isRecursion == false
    ) {
      updateServiceOnOpportunity(oldOpportunityLineItemList);
    }
  }
  public override void beforeInsert() {
    System.debug('enter BI');
    if (validationCheck == true) {
      populateSubService(newOpportunityLineItemList);
    }
  }

  public override void beforeUpdate() {
    System.debug('enter BU');
    if (validationCheck == true) {
      populateSubService(newOpportunityLineItemList);
    }
  }

  /*
   * Method Name: updateServiceOnOpportunity
   * Input Parameters: List<OpportunityLineItem>
   * Purpose: This method is used to update the value of 'services' field when opportunity line items are added
   */
  public static void updateServiceOnOpportunity(List<OpportunityLineItem> olt) {
    List<Id> listIds = new List<Id>();
    Map<Id, opportunity> mapOpportunityToUpdate = new Map<Id, opportunity>();
    Map<Id, OpportunityLineItem> mapToShowError = new Map<Id, OpportunityLineItem>();

    for (OpportunityLineItem childItem : olt) {
      listIds.add(childItem.OpportunityId);
      mapToShowError.put(childItem.OpportunityId, childItem);
    }

    list<Opportunity> parentOpp = new List<Opportunity>(
      [
        SELECT
          id,
          Service_Type__c,
          Name,
          (SELECT ID, product2.name FROM OpportunityLineItems)
        FROM Opportunity
        WHERE ID IN :listIds
      ]
    );

    for (Opportunity opp : parentOpp) {
      if (!opp.OpportunityLineItems.isEmpty()) {
        opp.Service_Type__c = '';
        for (OpportunityLineItem item : opp.OpportunityLineItems) {
          String service = String.valueOf(
            (item.product2.name != null) ? item.product2.name : ''
          );

          if (!opp.Service_Type__c.contains(service)) {
            opp.Service_Type__c = opp.Service_Type__c + ';' + service;
            mapOpportunityToUpdate.put(opp.id, opp);
          }
        }
      } else {
        if (opp.opportunityLineItems.isEmpty()) {
          if (mapToShowError.containsKey(opp.id)) {
            mapToShowError.get(opp.id)
              .addError(Label.THERE_SHOULD_BE_ATLEAST_ONE_SERVICE);
          }
        }
      }
    }

    if (mapOpportunityToUpdate.values().size() > 0) {
      try {
        Database.update(mapOpportunityToUpdate.values(), true);
      } catch (Exception ex) {
        if (ex.getMessage().contains(ConstantClass.DESTINATION_PORT)) {
          for (opportunitylineitem oltt : olt) {
            oltt.addError(Label.DESTINATION_PORT_IS_MANDATORY);
          }
        }
      }
    }
  }

  /*
   * Method Name: populateSubService
   * Input Parameters: List<OpportunityLineItem>
   * Purpose: This method is used to validate the services where sub-service is necessary when they get added without a sub-service.
   */
  public static void populateSubService(
    List<OpportunityLineItem> newOppLineItemList
  ) {
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    Map<String, Services_Subservices__c> subservicePresentMap = new Map<String, Services_Subservices__c>();
    Set<Id> productIdSet = new Set<Id>();
    List<Product2> productList = new List<Product2>();
    Map<Id, String> productIdToNameMap = new Map<Id, String>();

    subservicePresentMap = Services_Subservices__c.getAll();
    System.debug('services *&& ' + subservicePresentMap);
    for (OpportunityLineItem oppLi : newOppLineItemList) {
      productIdSet.add(oppLi.Product2Id);
    }

    System.debug('Product ID ' + productIdSet);
    productList = [SELECT Id, Name FROM Product2 WHERE Id IN :productIdSet];

    for (Product2 prod : productList) {
      productIdToNameMap.put(prod.Id, prod.Name);
    }
    System.debug('Product Map ' + productIdToNameMap);
    for (OpportunityLineItem oli : newOppLineItemList) {
      System.debug('subservicePresentMap-------------' + subservicePresentMap);
      System.debug('productIdToNameMap-------------' + productIdToNameMap);
      // System.debug('subservicePresentMap-------------'+subservicePresentMap.get(productIdToNameMap.get(oli.Product2Id)).Sub_service_present__c);
      if (
        productIdToNameMap.size() > 0 &&
        productIdToNameMap.containsKey(oli.Product2Id) &&
        productIdToNameMap.get(oli.Product2Id) != null &&
        !String.IsBlank(productIdToNameMap.get(oli.Product2Id)) &&
        subservicePresentMap.containsKey(
          productIdToNameMap.get(oli.Product2Id)
        ) &&
        subservicePresentMap.get(productIdToNameMap.get(oli.Product2Id))
          .Sub_service_present__c != null
      ) {
        if (
          oli.Sub_Services__c == null &&
          subservicePresentMap.get(productIdToNameMap.get(oli.Product2Id))
            .Sub_service_present__c == true
        ) {
          oli.addError(
            'Please select sub service corresponding to the service'
          );
        } else if (
          oli.Sub_Services__c != null &&
          oli.Sub_Services__c == 'CL - In Footprint' &&
          oli.Discharge_Port__c == null &&
          oli.Load_Port__c == null &&
          subservicePresentMap.get(productIdToNameMap.get(oli.Product2Id))
            .Port_Required__c == true
        ) {
          oli.addError(
            'Please select either Load Port or Discharge Port for LCL and FCL services'
          );
        }
      }
    }
  }
}
