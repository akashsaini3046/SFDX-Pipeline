/*
 * Name: CC_BOLTriggerWithoutShareUtil
 * Purpose: BOL Trigger without share util class
 * Author: Nagarro
 * Created Date: 11 Feb 2021
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
public without sharing class CC_BOLTriggerWithoutShareUtil {
  //This method update reserved bol numbres and marks them as used.
  public void markAsUsedBOLNumber(List<Bill_Of_Lading__c> lstBOL) {
    Set<String> setBOLNumbers = new Set<String>();
    List<BOL_Number__c> lstBOLNumber = new List<BOL_Number__c>();

    for (Bill_Of_Lading__c objBOL : lstBOL) {
      setBOLNumbers.add(objBOL.Bill_Of_Lading_Number__c);
    }
    for (BOL_Number__c objBolNumber : [
      SELECT Id, Name, Is_Used__c
      FROM BOL_Number__c
      WHERE Name IN :setBOLNumbers
    ]) {
      lstBOLNumber.add(
        new BOL_Number__c(Id = objBolNumber.Id, Is_Used__c = true)
      );
    }

    if (lstBOLNumber.size() > 0) {
      try {
        update lstBOLNumber;
      } catch (Exception objEx) {
        System.debug(
          'Error occured in update CC_BOLTriggerWithoutShareUtil > markAsUsedBOLNumber ' +
          objEx.getMessage()
        );
      }
    }
  }

  public static String generateBOLNumber(String strBookingId) {
    //Logic to get BOL numner from reserve list
    BOL_Number__c bolNumberFromReserve;
    Bill_Of_Lading__c billOfLadding = new Bill_Of_Lading__c();
    for (BOL_Number__c bolNumber : CC_BOLDAO.getBOLNumberFromBucket()) {
      bolNumberFromReserve = bolNumber;
      break;
    }
    if (bolNumberFromReserve == null) {
      throw new CC_NoBolNumberException('NO Bol Number in reserve');
    }
    Boolean isBolUsed = false;
    for (Bill_Of_Lading__c bol : [
      SELECT Id
      FROM Bill_Of_Lading__c
      WHERE Bill_Of_Lading_Number__c = :bolNumberFromReserve.Name
    ]) {
      isBolUsed = true;
    }
    if (isBolUsed == true) {
      bolNumberFromReserve.Is_Used__c = true;
      //DMLUtility.updateRecords(new List<BOL_Number__c>{bolNumberFromReserve},false);
      update bolNumberFromReserve;
      throw new CC_NoBolNumberException(
        'BOL number ' +
        bolNumberFromReserve.Name +
        ' is already taken Please update the reserve BOL number data with unique number'
      );
    }
    bolNumberFromReserve.Is_Used__c = true;
    //DMLUtility.updateRecords(new List<BOL_Number__c>{bolNumberFromReserve},false);
    update bolNumberFromReserve;

    Booking__c objBooking = new Booking__c();
    objBooking.Id = strBookingId;
    objBooking.Bill_of_Lading_Number__c = bolNumberFromReserve.Name;
    DMLUtility.updateRecords(new List<Booking__c>{ objBooking }, false);
    return objBooking.Bill_of_Lading_Number__c;
  }
}
