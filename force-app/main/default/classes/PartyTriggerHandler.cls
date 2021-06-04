/*
 * @company : Nagarro Inc.
 * @date : 02-09-2020
 * @author : Nagarro
 * @description : Trigger Handler for Party trigger
 * @history : Version 1.0
 * @test class : PartyTriggerHandlerTest
 */
public with sharing class PartyTriggerHandler extends TriggerHandler {
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
  List<Party__c> newPartyList;
  List<Party__c> oldPartyList;
  Map<Id, Party__c> newPartyMap;
  Map<Id, Party__c> oldPartyMap;

  /*Create the constructor*/
  public PartyTriggerHandler() {
    this.newPartyList = (List<Party__c>) Trigger.new;
    this.oldPartyList = (List<Party__c>) Trigger.old;
    this.newPartyMap = (Map<Id, Party__c>) Trigger.newMap;
    this.oldPartyMap = (Map<Id, Party__c>) Trigger.oldMap;
  }

  /*Override the before insert method from the parent class*/
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      if (recursionVarBeforeInsert) {
        linkPartyToAccount(newPartyList);
        recursionVarBeforeInsert = false;
      }
    }
  }

  /*Override before delete method*/
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      linkAccountOnBooking(oldPartyList);
      recursionVarBeforeDelete = false;
    }
  }

  /*Override after delete method*/
  public override void afterDelete() {
    if (recursionVarAfterDelete) {
      recursionVarAfterDelete = false;
    }
  }

  /*Override before Update method*/
  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      checkForCVIFUpdate(newPartyList, oldPartyMap);
      recursionVarBeforeUpdate = false;
    }
  }

  /*Override after Update method*/
  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      checkForAccountUpdate(newPartyList, oldPartyMap);
      recursionVarAfterUpdate = false;
    }
  }

  /*Override the after insert method*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      linkAccountOnBooking(newPartyList);
      recursionVarAfterInsert = false;
    }
  }

  /*
   * @purpose : Method to link Party to Account .
   * @parameter : listOfParty - list of New Party records being inserted
   * @return : void
   */
  public static void linkPartyToAccount(List<Party__c> listOfParty) {
    try {
      Set<String> setOfCVIF = new Set<String>();
      Map<String, ID> mapOfCVIFAccountId = new Map<String, ID>();

      for (Party__c objParty : listOfParty) {
        if (objParty.CVIF__c != null) {
          setOfCVIF.add(objParty.CVIF__c);
        }
      }
      if (!setOfCVIF.isEmpty()) {
        for (Account accRec : AccountDAO.getAccountByCVIF(setOfCVIF)) {
          mapOfCVIFAccountId.put(accRec.CVIF__c, accRec.id);
        }
      }

      for (Party__c objParty : listOfParty) {
        if (
          objParty.CVIF__c != null &&
          mapOfCVIFAccountId.containsKey(objParty.CVIF__c) &&
          mapOfCVIFAccountId.get(objParty.CVIF__c) != null
        ) {
          objParty.Account__c = mapOfCVIFAccountId.get(objParty.CVIF__c);
        } else {
          objParty.Account__c = null;
        }
      }
    } catch (Exception ex) {
      LogFactory.error(
        'PartyTriggerHandler',
        'linkPartyToAccount',
        'Party Trigger Before Insert',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }

  /*
   * @purpose : Method to check if CVIF Number changed in Party.
   * @parameter : newBookingList - list of New Party records being inserted ,oldPartyMap -Map of Old Parties
   * @return : void
   */
  private void checkForCVIFUpdate(
    List<Party__c> newPartyList,
    Map<Id, Party__c> oldPartyMap
  ) {
    try {
      List<Party__c> partyListToUpdate = new List<Party__c>();
      for (Party__c partyVar : newPartyList) {
        if (partyVar.CVIF__c != oldPartyMap.get(partyVar.id).CVIF__c) {
          partyListToUpdate.add(partyVar);
        }
      }
      if (!partyListToUpdate.isEmpty()) {
        linkPartyToAccount(partyListToUpdate);
      }
    } catch (Exception ex) {
      LogFactory.error(
        'PartyTriggerHandler',
        'checkForCVIFUpdate',
        'Party Trigger Before Update',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }

  /*
   * @purpose : Method to check if CVIF Number changed in Party.
   * @parameter : newBookingList - list of New Party records being inserted ,oldPartyMap -Map of Old Parties
   * @return : void
   */
  private void checkForAccountUpdate(
    List<Party__c> newPartyList,
    Map<Id, Party__c> oldPartyMap
  ) {
    try {
      List<Party__c> partyListToUpdate = new List<Party__c>();
      for (Party__c partyVar : newPartyList) {
        if (
          partyVar.Account__c != oldPartyMap.get(partyVar.id).Account__c &&
          (partyVar.Type__c == CC_Constants.SHIPPER ||
          partyVar.Type__c == CC_Constants.CONSIGNEE) ||
          (partyVar.Type__c != oldPartyMap.get(partyVar.id).Type__c &&
          (CC_Constants.SHIPPER_CONSIGNEE.contains(partyVar.Type__c) ||
          CC_Constants.SHIPPER_CONSIGNEE.contains(
            oldPartyMap.get(partyVar.id).Type__c
          )))
        ) {
          partyListToUpdate.add(partyVar);
        }
      }
      if (!partyListToUpdate.isEmpty()) {
        linkAccountOnBooking(partyListToUpdate);
      }
    } catch (Exception ex) {
      LogFactory.error(
        'PartyTriggerHandler',
        'checkForAccountUpdate',
        'Party Trigger After Update',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }

  /*
   * @purpose : Method to link Booking to Account .
   * @parameter : newPartyList - list of New Party records being inserted
   * @return : void
   */
  public static void linkAccountOnBooking(List<Party__c> listOfParty) {
    try {
      List<Booking__c> listBookingtoUpdate = new List<Booking__c>();
      Map<Id, Id> mapOfPartyAndAccount = new Map<Id, Id>();
      Map<Id, Id> mapOfBookingAndAccountId = new Map<Id, Id>();
      for (Party__c objParty : listOfParty) {
        mapOfPartyAndAccount.put(objParty.id, objParty.Account__c);
      }

      if (!mapOfPartyAndAccount.isEmpty()) {
        for (
          Party__c partyVar : PartyDAO.getPartyDetails(
            mapOfPartyAndAccount.keyset()
          )
        ) {
          if (
            (partyVar.Booking__r.Contract_Number__c == null) &&
            ((CC_Constants.COLLECT_SET.contains(
              partyVar.Booking__r.Payment_Terms__c
            ) && partyVar.Type__c == CC_Constants.CONSIGNEE) ||
            (CC_Constants.PREPAID_SET.contains(
              partyVar.Booking__r.Payment_Terms__c
            ) && partyVar.Type__c == CC_Constants.SHIPPER))
          ) {
            mapOfBookingAndAccountId.put(
              partyVar.Booking__c,
              partyVar.Account__c
            );
          } else if (
            !mapOfBookingAndAccountId.containsKey(partyVar.Booking__c) &&
            partyVar.Booking__r.Contract_Number__c == null &&
            Trigger.isUpdate
          ) {
            mapOfBookingAndAccountId.put(partyVar.Booking__c, null);
          }
        }
      }

      if (!mapOfBookingAndAccountId.isEmpty()) {
        for (
          Booking__c bookingVar : BookingDAO.getBookingDetails(
            mapOfBookingAndAccountId.keyset()
          )
        ) {
          if (
            mapOfBookingAndAccountId.get(bookingVar.id) != null &&
            (Trigger.isInsert || Trigger.isUpdate)
          ) {
            bookingVar.Account__c = mapOfBookingAndAccountId.get(bookingVar.id);
          } else {
            bookingVar.Account__c = null;
          }
          listBookingtoUpdate.add(bookingVar);
        }
      }

      if (!listBookingtoUpdate.isEmpty()) {
        DMLUtility.updateRecords(listBookingtoUpdate, false);
      }
    } catch (Exception ex) {
      LogFactory.error(
        'PartyTriggerHandler',
        'linkAccountOnBooking',
        'Party Trigger After Insert/Update',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }
}
