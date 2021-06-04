public class CC_BolAdditionalInformationWrapper {
  @AuraEnabled
  public Boolean boolOriginalBillOfLading { get; set; }
  @AuraEnabled
  public Boolean boolWayBill { get; set; }
  @AuraEnabled
  public Boolean boolFreighted { get; set; }
  @AuraEnabled
  public Boolean boolPrintCargo { get; set; }
  @AuraEnabled
  public Boolean boolPrintExclCharge { get; set; }
  @AuraEnabled
  public Boolean boolPrintInbNumber { get; set; }
  @AuraEnabled
  public Boolean boolLetterOfCredit { get; set; }
  @AuraEnabled
  public String comments { get; set; }
  @AuraEnabled
  public String releaseInstructions { get; set; }

  public CC_BolAdditionalInformationWrapper() {
  }
}
