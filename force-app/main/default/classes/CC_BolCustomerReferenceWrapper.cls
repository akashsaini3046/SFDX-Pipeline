public with sharing class CC_BolCustomerReferenceWrapper {
  public class Inbond {
    @auraenabled
    public String inbondType { get; set; }
    @auraenabled
    public String inbondNumber { get; set; }

    public Inbond(String inbondType, String inbondNumber) {
      this.inbondType = inbondType;
      this.inbondNumber = inbondNumber;
    }
  }

  public class CustomerParty {
    @auraenabled
    public String partyType { get; set; }
    @auraenabled
    public String referenceNumber { get; set; }
    public CustomerParty(String partyType, String referenceNumber) {
      this.partyType = partyType;
      this.referenceNumber = referenceNumber;
    }
  }

  @auraenabled
  public Date sentDate { get; set; }
  @auraenabled
  public String bolStatus { get; set; }
  @auraenabled
  public Date cargoAvailableForTransportDate { get; set; }
  @auraenabled
  public String bookingNumber { get; set; }
  @auraenabled
  public String billOfLadingNumber { get; set; }
  @auraenabled
  public Boolean eeiSupport { get; set; }
  @auraenabled
  public String contractNumber { get; set; }
  @auraenabled
  public String scacCode { get; set; }
  @auraenabled
  public List<ITNNumberWrapper> itnNumberLst { get; set; }
  @auraenabled
  public List<Inbond> inbondList { get; set; }
  @auraenabled
  public List<CustomerParty> partyList { get; set; }
  @auraenabled
  public String einNumber { get; set; }
  @auraenabled
  public String exemptionClause { get; set; }
  @auraenabled
  public Date option4Date { get; set; }
  @auraenabled
  public String strbolExporterRefNumber { get; set; }
  @auraenabled
  public String strbolForwarderRefNumber { get; set; }
  @auraenabled
  public List<String> bolExporterReferenceNumber { get; set; }
  @auraenabled
  public List<String> bolForwarderReferenceNumber { get; set; }

  // Old Booking variables
  @auraenabled
  public String oldContractNumber { get; set; }
  @auraenabled
  public String oldExemptionClause { get; set; }

  public CC_BolCustomerReferenceWrapper() {
    this.itnNumberLst = new List<ITNNumberWrapper>();
    this.inbondList = new List<Inbond>();
    this.partyList = new List<CustomerParty>();
    this.bolExporterReferenceNumber = new List<String>();
    this.bolForwarderReferenceNumber = new List<String>();
    strbolExporterRefNumber = '';
    strbolForwarderRefNumber = '';
  }
}
