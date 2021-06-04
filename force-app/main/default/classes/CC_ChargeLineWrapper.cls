public class CC_ChargeLineWrapper {
  @AuraEnabled
  public String chargeLineId { get; set; }
  @AuraEnabled
  public String strFreightCharge { get; set; }
  @AuraEnabled
  public String strRatedAs { get; set; }
  @AuraEnabled
  public String strPer { get; set; }
  @AuraEnabled
  public String strRateTarrif { get; set; }
  @AuraEnabled
  public String strPaymentTerm { get; set; }
  @AuraEnabled
  public String strPayerName { get; set; }
  @AuraEnabled
  public String strPaymentLocation { get; set; }
  @AuraEnabled
  public String strValue { get; set; }

  public CC_ChargeLineWrapper() {
  }
}
