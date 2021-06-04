/*
 * @company     : Nagarro Inc.
 * @date        : 08-13-2020
 * @author      : Nagarro
 * @description : controller for BOL edit page
 * @history     : Version 1.0
 */
public class BOLEditController {
  /*
   * Purpose: This will return list of BOl to the class .
   * Parameters:
   */
  @auraenabled
  public static BolView getBol(
    String bookingId,
    String bolId,
    Boolean isForEdit
  ) {
    return new CC_FetchBOLUtil().fetchBOLData(bookingId, bolId, isForEdit);
  }

  @AuraEnabled
  public static BolView saveBOLData(String bolView, Id bookingId, Id bolId) {
    BOLEditController.BolView objBolView = (BOLEditController.BolView) JSON.deserialize(
      bolView,
      BOLEditController.BolView.class
    );
    //new CC_SaveBOLUtil().saveBOLData(objBolView, bolId);
    return new CC_FetchBOLUtil().fetchBOLData(bookingId, bolId, true);
  }

  @auraenabled
  public static List<Map<String, String>> getTaxOptions(
    String objectName,
    String fieldName
  ) {
    List<Map<String, String>> plValuesLst = new List<Map<String, String>>();
    Schema.DescribeFieldResult fieldResult;

    fieldResult = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap()
      .get(fieldName)
      .getDescribe();
    List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry ple : pleList) {
      Map<String, String> plValueMap = new Map<String, String>();
      plValueMap.put('label', ple.getLabel());
      plValueMap.put('value', ple.getValue());
      plValuesLst.add(plValueMap);
    }
    return plValuesLst;
  }

  public class BolView {
    @auraenabled
    public CC_BolCustomerReferenceWrapper customerReference { get; set; }
    @auraenabled
    public List<CC_BolPartyWrapper> partyList { get; set; }
    @auraenabled
    public List<CC_BolPartyWrapper> shipperLst { get; set; }
    @auraenabled
    public List<CC_BolPartyWrapper> forwarderLst { get; set; }
    @auraenabled
    public List<CC_BolPartyWrapper> notifyPartyLst { get; set; }
    @auraenabled
    public List<CC_BolPartyWrapper> alsoNotifyPartyLst { get; set; }
    @auraenabled
    public List<CC_BolPartyWrapper> consigneeLst { get; set; }
    @auraenabled
    public CC_BOLRouteDetailsWrapper routingDetails { get; set; }
    @auraenabled
    public String routingInstructions { get; set; }
    @AuraEnabled
    public Map<String, List<CC_ChargeLineWrapper>> chargeLine { get; set; }
    @auraenabled
    public List<CC_BOLCargoEquipmentWrapper> cargoEquipment { get; set; }
    @auraenabled
    public CC_BolAdditionalInformationWrapper additionalInformation {
      get;
      set;
    }
    @auraenabled
    public Boolean isHazardious { get; set; }
    @AuraEnabled
    public String emergencyContactPhone { get; set; }
    @AuraEnabled
    public String emergencyHazContactPhone { get; set; }
    @AuraEnabled
    public String emergencyContactName { get; set; }

    public BolView() {
      this.customerReference = new CC_BolCustomerReferenceWrapper();
      this.partyList = new List<CC_BolPartyWrapper>();
      this.shipperLst = new List<CC_BolPartyWrapper>();
      this.forwarderLst = new List<CC_BolPartyWrapper>();
      this.notifyPartyLst = new List<CC_BolPartyWrapper>();
      this.alsoNotifyPartyLst = new List<CC_BolPartyWrapper>();
      this.consigneeLst = new List<CC_BolPartyWrapper>();
      this.routingDetails = new CC_BOLRouteDetailsWrapper();
      this.routingInstructions = '';
      chargeLine = new Map<String, List<CC_ChargeLineWrapper>>();
      this.cargoEquipment = new List<CC_BOLCargoEquipmentWrapper>();
      this.additionalInformation = new CC_BolAdditionalInformationWrapper();
    }
  }

  @AuraEnabled
  public static String fetchPDFUrl(
    String bookingId,
    String bolId,
    String strPageName
  ) {
    String PDFUrl;
    String communityUrlPathPrefix = CommonUtility.getCommunityUrlPathPrefix();
    if (Network.getNetworkId() != null) {
      PDFUrl =
        '/' +
        communityUrlPathPrefix +
        '/apex/' +
        strPageName +
        '?bookingId=' +
        bookingId +
        '&bolId=' +
        bolId;
    } else {
      PDFUrl =
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/' +
        strPageName +
        '?Id=' +
        bookingId +
        '&bolId=' +
        bolId;
    }
    System.debug('PDFUrl is ' + PDFUrl);
    return PDFUrl;
  }
}
