/*
 * Name: CC_BOLTriggerHandler
 * Purpose: Handler class for BOL Trigger
 * Author: Nagarro
 * Created Date: 11 Feb 2021
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public with sharing class CC_BOLTriggerHandler extends TriggerHandler {
  @TestVisible
  private static Boolean recursionVarBeforeInsert = true;
  @TestVisible
  private static Boolean recursionVarBeforeUpdate = true;
  @TestVisible
  private static Boolean recursionVarBeforeDelete = true;
  @TestVisible
  private static Boolean recursionVarAfterInsert = true;
  @TestVisible
  private static Boolean recursionVarAfterUpdate = true;
  @TestVisible
  private static Boolean recursionVarAfterDelete = true;
  List<Bill_Of_Lading__c> newBOLList;
  List<Bill_Of_Lading__c> oldBOLList;
  Map<Id, Bill_Of_Lading__c> newBOLMap;
  Map<Id, Bill_Of_Lading__c> oldBOLMap;
  String profileName;

  /*Create the constructor*/
  public CC_BOLTriggerHandler() {
    this.newBOLList = (List<Bill_Of_Lading__c>) Trigger.new;
    this.oldBOLList = (List<Bill_Of_Lading__c>) Trigger.old;
    this.newBOLMap = (Map<Id, Bill_Of_Lading__c>) Trigger.newMap;
    this.oldBOLMap = (Map<Id, Bill_Of_Lading__c>) Trigger.oldMap;
  }

  /*Override the before insert method from the parent class*/
  /*  public override void beforeInsert(){
        if(recursionVarBeforeInsert){
            recursionVarBeforeInsert = false;
        }
    }  */

  /*Override before delete method*/
  /* public override void beforeDelete(){
        if(recursionVarBeforeDelete){
            recursionVarBeforeDelete = false;
        }
    }  */

  /*Override after delete method*/
  /*    public override void afterDelete() {
        if(recursionVarAfterDelete){
            recursionVarAfterDelete = false;
        }
    }
    
    public override void beforeUpdate(){
        if(recursionVarBeforeUpdate){
            recursionVarBeforeUpdate = false;
        }
    }  */

  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      updateBOLNumberAsUsed(newBOLList, oldBOLMap);
    }
  }

  /*Override the after insert method from the parent class*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      new CC_BOLTriggerWithoutShareUtil().markAsUsedBOLNumber(newBOLList);
    }
  }

  //This method check which bol has updated bol number and current bol not balnk then send it for reserved number update.
  private void updateBOLNumberAsUsed(
    List<Bill_Of_Lading__c> lstNewBOL,
    Map<Id, Bill_Of_Lading__c> mapOldBOL
  ) {
    List<Bill_Of_Lading__c> updatedBolnumberList = new List<Bill_Of_Lading__c>();
    for (Bill_Of_Lading__c objBOL : lstNewBOL) {
      if (
        objBOL.Bill_Of_Lading_Number__c != null &&
        mapOldBOL != null &&
        mapOldBOL.containsKey(objBOL.Id) &&
        mapOldBOL.get(objBOL.Id).Bill_Of_Lading_Number__c !=
        objBOL.Bill_Of_Lading_Number__c
      ) {
        updatedBolnumberList.add(objBOL);
      }
    }

    if (updatedBolnumberList.size() > 0) {
      new CC_BOLTriggerWithoutShareUtil()
        .markAsUsedBOLNumber(updatedBolnumberList);
    }
  }
}
