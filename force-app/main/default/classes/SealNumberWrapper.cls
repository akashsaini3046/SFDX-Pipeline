public class SealNumberWrapper {
  @AuraEnabled
  public String strSealNumber { get; set; }
  public SealNumberWrapper(String strSealNumber) {
    this.strSealNumber = strSealNumber;
  }
}
