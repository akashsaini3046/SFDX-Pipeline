public class ReferenceNumberWrapper {
  @AuraEnabled
  public String strRefNumber { get; set; }
  public ReferenceNumberWrapper() {
    this.strRefNumber = '';
  }
}
