/*
 * Name: AccountInitiativeWrapper
 * Purpose: Wrapper crass for Accoun to be used in nitiative.
 * Author: Nagarro
 * Created Date: 07-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class AccountInitiativeWrapper {
  @AuraEnabled
  public String value { get; set; }
  @AuraEnabled
  public String label { get; set; }
}
