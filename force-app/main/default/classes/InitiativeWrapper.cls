/*
 * Name: InitiativeWrapper
 * Purpose: Wrapper crass for nitiative.
 * Author: Nagarro
 * Created Date: 21-Feb-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class InitiativeWrapper {
  @AuraEnabled
  public String label { get; set; }
  @AuraEnabled
  public String value { get; set; }
  public InitiativeWrapper(String strName, String strId) {
    label = strName;
    value = strId;
  }
}
