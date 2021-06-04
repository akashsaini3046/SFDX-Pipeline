public class HTSNumberWrapper {
  @AuraEnabled
  public String strHTSType { get; set; }
  @AuraEnabled
  public String strHTSNoandDesc { get; set; }
  @AuraEnabled
  public String strHTSNoId { get; set; }
  @AuraEnabled
  public String strHTSNoSelectedItem { get; set; }
  public HTSNumberWrapper(String strHTSType, String strHTSNoandDesc) {
    this.strHTSType = strHTSType;
    this.strHTSNoandDesc = strHTSNoandDesc;
  }
  public HTSNumberWrapper(
    String strHTSType,
    String strHTSNoandDesc,
    String strHTSNoId
  ) {
    this.strHTSType = strHTSType;
    this.strHTSNoandDesc = strHTSNoandDesc;
    this.strHTSNoId = strHTSNoId;
    this.strHTSNoSelectedItem = strHTSNoandDesc;
  }
}
