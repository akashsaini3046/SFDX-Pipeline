public with sharing class CC_BolPartyWrapper {
  @auraenabled
  public String name { get; set; }
  @auraenabled
  public List<String> referenceNumber { get; set; }
  @auraenabled
  public List<ReferenceNumberWrapper> referenceNumbers { get; set; }
  @auraenabled
  public String addressLine1 { get; set; }
  @auraenabled
  public String addressLine2 { get; set; }
  @auraenabled
  public String addressLine3 { get; set; }
  @auraenabled
  public String addressLine4 { get; set; }
  @auraenabled
  public String email { get; set; }
  @auraenabled
  public String phone { get; set; }
  @auraenabled
  public Boolean isPrimary { get; set; }
  // Consignee fields

  @auraenabled
  public String destinationTaxIdType { get; set; }
  @auraenabled
  public String destinationTaxIdNumber { get; set; }
  @auraenabled
  public String registrationId { get; set; }
  @auraenabled
  public String taxIdNumber { get; set; }
  @auraenabled
  public String EINSSNumber { get; set; }

  //Forwarding Agent fields
  @auraenabled
  public String FMCNumber { get; set; }
  @auraenabled
  public String CHBNumber { get; set; }

  // Header for the
  @auraenabled
  public String uiHeader { get; set; }
  @auraenabled
  public Integer uiLocationOrder { get; set; }

  @auraenabled
  public String partyType { get; set; }
  @auraenabled
  public String partyId { get; set; }
  @auraenabled
  public Boolean isDeleted { get; set; }
  // From booking
  @auraenabled
  public String bookingPartyId { get; set; }
  @auraenabled
  public String bookingPartyName { get; set; }
  @auraenabled
  public String bookingPartyAddressLine1 { get; set; }
  @auraenabled
  public String bookingPartyAddressLine2 { get; set; }
  @auraenabled
  public String bookingPartyAddressLine3 { get; set; }
  @auraenabled
  public String bookingPartyAddressLine4 { get; set; }
  @auraenabled
  public String bookingPartyPhone { get; set; }
  @auraenabled
  public String bookingPartyEmail { get; set; }
  @auraenabled
  public String bookingPartyTaxIdNumber { get; set; }
  @auraenabled
  public String bookingFMCNumber { get; set; }
  @auraenabled
  public String bookingCHBNumber { get; set; }

  public CC_BolPartyWrapper() {
    this.referenceNumber = new List<String>();
    this.referenceNumbers = new List<ReferenceNumberWrapper>();
    this.isDeleted = false;
    this.bookingPartyId = '';
  }
}
