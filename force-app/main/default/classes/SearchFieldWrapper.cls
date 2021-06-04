/*
 * Name: SearchFieldWrapper
 * Purpose: Wrapper crass for search filed.
 * Author: Nagarro
 * Created Date: 28-Feb-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class SearchFieldWrapper {
  @AuraEnabled
  public String value { get; set; }
  @AuraEnabled
  public String label { get; set; }
}
