/*
 * Name: OpportunitySplitServiceWrapper
 * Purpose: Wrapper class which is acts as response for opportunity split
 * Author: Nagarro
 * Created Date: 18-Feb-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class OpportunitySplitServiceWrapper {
  @AuraEnabled
  public Id idLineItem { get; set; }
  @AuraEnabled
  public String strProductName { get; set; }
  @AuraEnabled
  public String strTrade { get; set; }
  @AuraEnabled
  public String strOriginCountry { get; set; }
  @AuraEnabled
  public String strDestinationCountry { get; set; }
  @AuraEnabled
  public Decimal decQuantity { get; set; }
  @AuraEnabled
  public Decimal decUnitPrice { get; set; }
  @AuraEnabled
  public Decimal decTotalPrice { get; set; }
  @AuraEnabled
  public Decimal decLostUnitPrice { get; set; }
  @AuraEnabled
  public Decimal decLostTotalPrice { get; set; }
  @AuraEnabled
  public Boolean boolServiceStatus { get; set; }
}
