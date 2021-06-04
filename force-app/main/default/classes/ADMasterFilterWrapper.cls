/*
 * Name: ADMasterFilterWrapper
 * Purpose: Wrapper class to represent Dashboard Filter
 * Author: Nagarro
 * Created Date: 09-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADMasterFilterWrapper {
  @AuraEnabled
  public List<Id> lstSelectedAccounts { get; set; }
  @AuraEnabled
  public List<Id> lstSelectedOwners { get; set; }
  @AuraEnabled
  public String strSelectedTopFilter { get; set; }
  @AuraEnabled
  public String strSelectedOppSizeFilterOperator { get; set; }
  @AuraEnabled
  public String strOppSizeVal { get; set; }
  @AuraEnabled
  public String strSelectedYear { get; set; }
}
