public class DockReceiptWrapper {
  @AuraEnabled
  public String strDockNumber { get; set; }
  public DockReceiptWrapper(String strDockNumber) {
    this.strDockNumber = strDockNumber;
  }
}
