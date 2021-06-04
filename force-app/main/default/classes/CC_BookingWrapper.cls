public class CC_BookingWrapper {
  @AuraEnabled
  public Booking__c booking { get; set; }
  @AuraEnabled
  public String AccountName { get; set; }
  @AuraEnabled
  public String ContactName { get; set; }
  @AuraEnabled
  public Map<String, List<Party__c>> mapParty { get; set; }
  @AuraEnabled
  public List<Booking_Remark__c> listRemark { get; set; }
  @AuraEnabled
  public TransportWrapper transportOrigin { get; set; }
  @AuraEnabled
  public TransportWrapper transportDestination { get; set; }
  @AuraEnabled
  public ShipmentWrapper shipment { get; set; }
  @AuraEnabled
  public Map<String, ShipmentWrapper> shipmentMap { get; set; }
  @AuraEnabled
  public Boolean isError { get; set; }
  @AuraEnabled
  public Integer selectedRouteId { get; set; }
  @AuraEnabled
  public Integer selectedScheduleSequence { get; set; }
  @AuraEnabled
  public String errorMessage { get; set; }
  @AuraEnabled
  public List<Quote__c> listQuote { get; set; }
  @AuraEnabled
  public String originPort { get; set; }
  @AuraEnabled
  public String destinationPort { get; set; }
  @AuraEnabled
  public String originLocationCode { get; set; }
  @AuraEnabled
  public String destinationLocationCode { get; set; }

  public CC_BookingWrapper() {
    this.booking = new Booking__c();
    this.listRemark = new List<Booking_Remark__c>{ new Booking_Remark__c() };
    this.mapParty = new Map<String, List<Party__c>>();
    mapParty.put(
      'Customer',
      new List<Party__c>{ new Party__c(Type__c = 'CUST', Is_Primary__c = true) }
    );
    mapParty.put(
      'shiper',
      new List<Party__c>{ new Party__c(Type__c = 'SHP', Is_Primary__c = true) }
    );
    mapParty.put(
      'consignee',
      new List<Party__c>{ new Party__c(Type__c = 'CON', Is_Primary__c = true) }
    );
    mapParty.put('others', new List<Party__c>{ new Party__c(Type__c = '') });
    this.shipment = new ShipmentWrapper();
    this.shipmentMap = new Map<String, ShipmentWrapper>();
    shipmentMap.put('RORO', new ShipmentWrapper('roro'));
    shipmentMap.put('VEHICLE', new ShipmentWrapper('vehicle'));
    shipmentMap.put('BREAKBULK', new ShipmentWrapper('breakbulk'));
    shipmentMap.put('CONTAINER', new ShipmentWrapper('container'));
    this.transportOrigin = new TransportWrapper();
    this.transportDestination = new TransportWrapper();
    this.listQuote = new List<Quote__c>();
    this.isError = false;
    this.selectedRouteId = 0;
    this.selectedScheduleSequence = 0;
    this.originPort = '';
    this.destinationPort = '';
    this.originLocationCode = '';
    this.destinationLocationCode = '';
    this.AccountName = '';
    this.ContactName = '';
    this.errorMessage = '';
  }

  public class TransportWrapper {
    @AuraEnabled
    public Transport__c transport { get; set; }
    @AuraEnabled
    public List<Stop__c> listStop { get; set; }
    public TransportWrapper() {
      this.transport = new Transport__c();
      this.listStop = new List<Stop__c>{ new Stop__c() };
    }
  }

  public class ShipmentWrapper {
    @AuraEnabled
    public Shipment__c shipment { get; set; }
    @AuraEnabled
    public List<Voyage__c> listVogage { get; set; }
    @AuraEnabled
    public List<CargoWrapper> listCargo { get; set; }
    @AuraEnabled
    public String cargoType { get; set; }
    @AuraEnabled
    public boolean isSelected { get; set; }
    public ShipmentWrapper() {
      this.shipment = new Shipment__c();
      this.listVogage = new List<Voyage__c>();
      this.listCargo = new List<CargoWrapper>();
    }

    public ShipmentWrapper(String cargoType) {
      this.cargoType = cargoType;
      this.isSelected = (cargoType == 'container');
      this.shipment = new Shipment__c();
      this.listVogage = new List<Voyage__c>();
      this.listCargo = new List<CargoWrapper>{ new CargoWrapper() };
    }
  }
  public class CargoWrapper {
    @AuraEnabled
    public String cargoType { get; set; }
    @AuraEnabled
    public Boolean isHazardous { get; set; }
    @AuraEnabled
    public List<FreightDetailWrapper> listFreightDetailWrapper { get; set; }
    @AuraEnabled
    public String measureUnit { get; set; }
    public CargoWrapper() {
      this.cargoType = '';
      this.isHazardous = false;
      this.measureUnit = 'lb/ft';
      this.listFreightDetailWrapper = new List<FreightDetailWrapper>{
        new FreightDetailWrapper()
      };
    }
  }
  public class FreightDetailWrapper {
    @AuraEnabled
    public String commodityCode { get; set; }
    @AuraEnabled
    public String commodityDesc { get; set; }
    @AuraEnabled
    public String typeOfPackage { get; set; }
    @AuraEnabled
    public String packageDesc { get; set; }
    @AuraEnabled
    public List<String> lstVinDetail { get; set; }
    @AuraEnabled
    public List<VinWrapper> lstVinWrapper { get; set; }
    @AuraEnabled
    public FreightDetail__c freightDetail { get; set; }
    @AuraEnabled
    public List<CommodityWrapper> listCommodityWrapper { get; set; }
    @AuraEnabled
    public List<RequirementWrapper> listRequirementWrapper { get; set; }
    @AuraEnabled
    public String measureUnit { get; set; }

    public FreightDetailWrapper() {
      this.commodityDesc = 'NIT / Breakbulk, Vehicles, Boats';
      this.commodityCode = System.label.CC_NitBBCode;
      this.typeOfPackage = '';
      this.packageDesc = '';
      this.lstVinDetail = new List<String>();
      this.lstVinWrapper = new List<VinWrapper>();
      this.measureUnit = 'lb/ft';
      this.freightDetail = new FreightDetail__c(
        Marine_Cargo_Insurance__c = 'No'
      );
      this.listCommodityWrapper = new List<CommodityWrapper>{
        new CommodityWrapper()
      };
      this.listRequirementWrapper = new List<RequirementWrapper>{
        new RequirementWrapper()
      };
    }
  }

  public class CommodityWrapper {
    @AuraEnabled
    public String substanceDesc { get; set; }
    @AuraEnabled
    public Commodity__c commodity { get; set; }
    public CommodityWrapper() {
      this.substanceDesc = '';
      this.commodity = new Commodity__c();
    }
  }

  public class RequirementWrapper {
    @AuraEnabled
    public String commodityDesc { get; set; }
    @AuraEnabled
    public String containerType { get; set; }
    @AuraEnabled
    public String containerDesc { get; set; }
    @AuraEnabled
    public String commodityCode { get; set; }
    @AuraEnabled
    public String unitType { get; set; }
    @AuraEnabled
    public Requirement__c requirement { get; set; }
    @AuraEnabled
    public Container__c container { get; set; }
    @AuraEnabled
    public Decimal grossWeight { get; set; }
    public RequirementWrapper() {
      this.containerType = '';
      this.containerDesc = '';
      this.commodityDesc = '';
      this.commodityCode = '';
      this.unitType = '';
      this.grossWeight = 0;
      this.container = new Container__c();
      this.requirement = new Requirement__c(Marine_Cargo_Insurance__c = 'No');
    }
  }
  public class HazardousSubstanceWrapper {
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
    public HazardousSubstanceWrapper() {
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
    }
  }

  public class VinWrapper {
    @AuraEnabled
    public String Vin { get; set; }
    @AuraEnabled
    public String UnNumber { get; set; }
    public VinWrapper() {
      this.Vin = '';
      this.UnNumber = 'UN3166 - Gasoline';
    }
  }

  @AuraEnabled
  public static CC_BookingWrapper getBookingWrapper() {
    CargoWrapper cargoWrap = new CargoWrapper();
    cargoWrap.cargoType = 'container';
    ShipmentWrapper shipmentWrap = new ShipmentWrapper();
    shipmentWrap.listCargo.add(cargoWrap);
    CC_BookingWrapper bookWrapper = new CC_BookingWrapper();
    bookWrapper.shipment = shipmentWrap;
    return bookWrapper;
  }
}
