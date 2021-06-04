public without sharing class HazardousCommodityWrapper {
  @AuraEnabled
  public String SubstanceId { get; set; }
  @AuraEnabled
  public String Code { get; set; }
  @AuraEnabled
  public String UnNumber { get; set; }
  @AuraEnabled
  public String Prefix { get; set; }
  @AuraEnabled
  public String Suffix { get; set; }
  @AuraEnabled
  public String SubstanceName { get; set; }
  @AuraEnabled
  public String PrimaryClass { get; set; }
  @AuraEnabled
  public String Variation { get; set; }
  @AuraEnabled
  public String PackingGroup { get; set; }
  @AuraEnabled
  public String SecondaryClass { get; set; }
  @AuraEnabled
  public String TertiaryClass { get; set; }
  @AuraEnabled
  public String MarinePollutant { get; set; }
  @AuraEnabled
  public String LimitedQuantity { get; set; }
  @AuraEnabled
  public Boolean isSelected { get; set; }
  @AuraEnabled
  public Id commodityId { get; set; }
  @AuraEnabled
  public CommodityWrapper commodityWrap { get; set; }
  @AuraEnabled
  public Boolean isDeleted { get; set; }

  public HazardousCommodityWrapper() {
    this.SubstanceId = '';
    this.Code = '';
    this.UnNumber = '';
    this.Prefix = '';
    this.Suffix = '';
    this.SubstanceName = '';
    this.PrimaryClass = '';
    this.Variation = '';
    this.PackingGroup = '';
    this.SecondaryClass = '';
    this.TertiaryClass = '';
    this.MarinePollutant = '';
    this.LimitedQuantity = '';
    this.isSelected = false;
    this.commodityId = null;
    this.commodityWrap = new CommodityWrapper();
    this.isDeleted = false;
  }

  public without sharing class CommodityWrapper {
    @AuraEnabled
    public String substanceDesc { get; set; }
    @AuraEnabled
    public Commodity__c commodity { get; set; }
    public CommodityWrapper() {
      this.substanceDesc = '';
      this.commodity = new Commodity__c();
    }
  }
}
