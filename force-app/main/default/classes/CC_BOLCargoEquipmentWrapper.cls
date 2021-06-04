public with sharing class CC_BOLCargoEquipmentWrapper {
  @AuraEnabled
  public String containerSizeType { get; set; }
  @AuraEnabled
  public List<SealNumberWrapper> sealNumbers { get; set; }
  @AuraEnabled
  public List<HTSNumberWrapper> htsNumbers { get; set; }
  @AuraEnabled
  public String quantity { get; set; }
  @AuraEnabled
  public String packageType { get; set; }
  @AuraEnabled
  public String containerNO1 { get; set; }
  @AuraEnabled
  public String containerNO2 { get; set; }
  @AuraEnabled
  public String cargoDescription { get; set; }
  @AuraEnabled
  public String cargoDescriptionS { get; set; }
  @AuraEnabled
  public Boolean copyCheckbox { get; set; }
  @AuraEnabled
  public String commodity { get; set; }
  @AuraEnabled
  public List<DockReceiptWrapper> dockReceiptNumbers { get; set; }
  @AuraEnabled
  public String weight { get; set; }
  @AuraEnabled
  public String weightLBS { get; set; }
  @AuraEnabled
  public String weightUnit { get; set; }
  @AuraEnabled
  public String vgmweight { get; set; }
  @AuraEnabled
  public String vgmweightLBS { get; set; }
  @AuraEnabled
  public String vgmweightUnit { get; set; }
  @AuraEnabled
  public String volume { get; set; }
  @AuraEnabled
  public String volumeUnit { get; set; }
  @AuraEnabled
  public String ventSettings { get; set; }
  @AuraEnabled
  public String temperature { get; set; }
  @AuraEnabled
  public String temperatureF { get; set; }
  @AuraEnabled
  public String temperatureUnit { get; set; }
  @AuraEnabled
  public String bookingInst { get; set; }
  @AuraEnabled
  public String cargovalue { get; set; }
  @AuraEnabled
  public Boolean hazardous { get; set; }
  @AuraEnabled
  public List<HazardousCommodityWrapper> hazardousCommodityLst { get; set; }
  @AuraEnabled
  public Id equipmentId { get; set; }
  @AuraEnabled
  public String equipmentNumberCopy { get; set; }
  @AuraEnabled
  public Id billItemId { get; set; }
  @AuraEnabled
  public Id commodityId { get; set; }
  @AuraEnabled
  public Integer Index { get; set; }
  @AuraEnabled
  public Boolean isDeleted { get; set; }

  public CC_BOLCargoEquipmentWrapper() {
    this.sealNumbers = new List<SealNumberWrapper>();
    this.htsNumbers = new List<HTSNumberWrapper>();
    this.dockReceiptNumbers = new List<DockReceiptWrapper>();
    this.hazardousCommodityLst = new List<HazardousCommodityWrapper>();
    this.equipmentId = null;
    this.billItemId = null;
    this.isDeleted = false;
    this.vgmweight = '';
    this.ventSettings = '';
    this.vgmweightUnit = '';
    this.vgmweightLBS = '';
  }
}
