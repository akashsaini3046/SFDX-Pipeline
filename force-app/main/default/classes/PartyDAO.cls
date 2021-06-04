/*
 * @company     : Nagarro Inc.
 * @date        : 04-09-2020
 * @author      : Nagarro
 * @description : DAO for Party object
 * @history     : Version 1.0
 * @test class  : PartyDAOTest
 */
public without sharing class PartyDAO implements IPartyDAO {
  /*
   * @company     : Nagarro Inc.
   * @date        : 04-09-2020
   * @author      : Nagarro
   * @description : Interface for the DAO - Contains methods which must be implemented
   * @history     : Version 1.0
   */
  public interface IPartyDAO {
    List<Party__c> getPartyDetails(Set<Id> setOfPartyId);
    List<Party__c> getPartyDetailsByBooking(Set<Id> setOfBookingId);
  }

  /*
   * @purpose     : Method to get Party detail by party Ids.
   * @parameter   : setOfPartyId - set Of party ids
   * @return      : List<Party__c > - List of Party
   */
  public static List<Party__c> getPartyDetails(Set<Id> setOfPartyId) {
    return [
      SELECT
        id,
        Account__c,
        Type__c,
        Booking__c,
        Booking__r.Payment_Terms__c,
        Booking__r.Account__c,
        Booking__r.Contract_Number__c
      FROM Party__c
      WHERE id IN :setOfPartyId
    ];
  }

  /*
   * @purpose     : Method to get Party detail by Booking Ids.
   * @parameter   : setOfPartyId - set Of Booking ids
   * @return      : List<Party__c > - List of Party
   */
  public static List<Party__c> getPartyDetailsByBooking(
    Set<Id> setOfBookingId
  ) {
    return [
      SELECT
        id,
        Account__c,
        Type__c,
        Booking__c,
        Booking__r.Payment_Terms__c,
        Booking__r.Account__c,
        Booking__r.Contract_Number__c
      FROM Party__c
      WHERE
        Booking__c IN :setOfBookingId
        AND Type__c IN :CC_Constants.SHIPPER_CONSIGNEE
    ];
  }
}
