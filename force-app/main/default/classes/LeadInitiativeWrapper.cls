/*
 * Name: LeadInitiativeWrapper
 * Purpose: Wrapper crass for Lead to be used in nitiative.
 * Author: Nagarro
 * Created Date: 12-Feb-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class LeadInitiativeWrapper {
  @AuraEnabled
  public String value { get; set; }
  @AuraEnabled
  public String label { get; set; }
}
