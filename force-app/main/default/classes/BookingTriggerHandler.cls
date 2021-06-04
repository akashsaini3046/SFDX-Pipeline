/*
 * @company     : Nagarro Inc.
 * @date        : 31-08-2020
 * @author      : Nagarro
 * @description : Trigger Handler for Booking trigger
 * @history     : Version 1.0
 * @test class  : BookingTriggerHandlerTest
 */
public with sharing class BookingTriggerHandler extends TriggerHandler {
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
  List<Booking__c> newBookingList;
  List<Booking__c> oldBookingList;
  Map<Id, Booking__c> newBookingMap;
  Map<Id, Booking__c> oldBookingMap;
  String profileName;

  /*Create the constructor*/
  public BookingTriggerHandler() {
    this.newBookingList = (List<Booking__c>) Trigger.new;
    this.oldBookingList = (List<Booking__c>) Trigger.old;
    this.newBookingMap = (Map<Id, Booking__c>) Trigger.newMap;
    this.oldBookingMap = (Map<Id, Booking__c>) Trigger.oldMap;
  }

  /*Override the before insert method*/
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      linkBookingToAccount(newBookingList);
      recursionVarBeforeInsert = false;
    }
  }

  /*Override before delete method*/
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
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
      checkForContractChange(newBookingList, oldBookingMap);
      recursionVarBeforeUpdate = false;
    }
  }

  /*Override after Update method*/
  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      checkForPaymentTermChange(newBookingList, oldBookingMap);
      recursionVarAfterUpdate = false;
    }
  }

  /*Override the after insert method*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      recursionVarAfterInsert = false;
    }
  }

  /*
   * @purpose     : Method to check if Contract Number changed in Booking.
   * @parameter   : newBookingList - list of New Booking records being inserted ,oldBookingMap -Map of Old bookings
   * @return      : void
   */
  private void checkForContractChange(
    List<Booking__c> newBookingList,
    Map<Id, Booking__c> oldBookingMap
  ) {
    try {
      List<Booking__c> bookingListToUpdate = new List<Booking__c>();
      for (Booking__c bookingVar : newBookingList) {
        if (
          bookingVar.Contract_Number__c !=
          oldBookingMap.get(bookingVar.id).Contract_Number__c
        ) {
          bookingListToUpdate.add(bookingVar);
        }
      }
      if (!bookingListToUpdate.isEmpty()) {
        linkBookingToAccount(bookingListToUpdate);
      }
    } catch (Exception ex) {
      LogFactory.error(
        'BookingTriggerHandler',
        'checkForContractChange',
        'Booking Trigger Before Update',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }

  /*
   * @purpose     : Method to check if Contract Number changed in Booking.
   * @parameter   : newBookingList - list of New Booking records being inserted ,oldBookingMap -Map of Old bookings
   * @return      : void
   */
  private void checkForPaymentTermChange(
    List<Booking__c> newBookingList,
    Map<Id, Booking__c> oldBookingMap
  ) {
    try {
      List<Booking__c> bookingListToUpdate = new List<Booking__c>();
      Set<Id> setOfBookingId = new Set<Id>();

      for (Booking__c bookingVar : newBookingList) {
        if (
          bookingVar.Payment_Terms__c !=
          oldBookingMap.get(bookingVar.id).Payment_Terms__c
        ) {
          setOfBookingId.add(bookingVar.id);
        }
      }

      if (!setOfBookingId.isEmpty()) {
        PartyTriggerHandler.linkAccountOnBooking(
          PartyDAO.getPartyDetailsByBooking(setOfBookingId)
        );
      }
    } catch (Exception ex) {
      LogFactory.error(
        'BookingTriggerHandler',
        'checkForContractChange',
        'Booking Trigger Before Update',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }

  /*
   * @purpose     : Method to assign Booking to Account .
   * @parameter   : newBookingList - list of New Booking records being inserted
   * @return      : void
   */
  private void linkBookingToAccount(List<Booking__c> newBookingList) {
    try {
      Map<String, List<Booking__c>> mapOfContractAndBookings = new Map<String, List<Booking__c>>();
      Map<String, Id> mapOfContractAndAccount = new Map<String, Id>();

      for (Booking__c bookingRec : newBookingList) {
        if (bookingRec.Contract_Number__c != null) {
          if (
            mapOfContractAndBookings.containsKey(bookingRec.Contract_Number__c)
          ) {
            List<Booking__c> bookingList = mapOfContractAndBookings.get(
              bookingRec.Contract_Number__c
            );
            bookingList.add(bookingRec);
            mapOfContractAndBookings.put(
              bookingRec.Contract_Number__c,
              bookingList
            );
          } else {
            mapOfContractAndBookings.put(
              bookingRec.Contract_Number__c,
              new List<Booking__c>{ bookingRec }
            );
          }
        }
      }
      if (!mapOfContractAndBookings.isEmpty()) {
        mapOfContractAndAccount = AccountDao.getAccountDataFromContract(
          mapOfContractAndBookings.keySet()
        );
      }
      for (Booking__c bookingVar : newBookingList) {
        if (
          bookingVar.Contract_Number__c != null &&
          mapOfContractAndBookings.containsKey(bookingVar.Contract_Number__c)
        ) {
          if (
            mapOfContractAndAccount.get(bookingVar.Contract_Number__c) != null
          ) {
            bookingVar.Account__c = mapOfContractAndAccount.get(
              bookingVar.Contract_Number__c
            );
          } else {
            bookingVar.Account__c = null;
          }
        } else if (bookingVar.Contract_Number__c == null) {
          bookingVar.Account__c = null;
        }
      }
    } catch (Exception ex) {
      LogFactory.error(
        'BookingTriggerHandler',
        'linkBookingToAccount',
        'Booking Trigger Before Insert',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }
}
