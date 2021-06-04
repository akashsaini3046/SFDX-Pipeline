public with sharing class CC_BOLRouteDetailsWrapper {
  @AuraEnabled
  public String vesselName { get; set; }
  @AuraEnabled
  public String vesselId { get; set; }
  @AuraEnabled
  public String vesselNameSelectedItem { get; set; }
  @AuraEnabled
  public String voyageNumber { get; set; }
  @AuraEnabled
  public String relayPoint { get; set; }
  @AuraEnabled
  public String pointAndCountry { get; set; }
  @AuraEnabled
  public String portOfLoading { get; set; }
  @AuraEnabled
  public String portOfLoadingId { get; set; }
  @AuraEnabled
  public String portOfLoadingSelectedItem { get; set; }
  @AuraEnabled
  public String loadingPier { get; set; }
  @AuraEnabled
  public String loadingPierId { get; set; }
  @AuraEnabled
  public String loadingPierSelectedItem { get; set; }
  @AuraEnabled
  public String portOfDischarge { get; set; }
  @AuraEnabled
  public String portOfDischargeId { get; set; }
  @AuraEnabled
  public String portOfDischargeSelectedItem { get; set; }
  @AuraEnabled
  public String placeOfDelivery { get; set; }
  @AuraEnabled
  public String placeOfDeliveryId { get; set; }
  @AuraEnabled
  public String placeOfDeliverySelectedItem { get; set; }
  @AuraEnabled
  public String flag { get; set; }
  @AuraEnabled
  public String placeOfReciept { get; set; }
  @AuraEnabled
  public String placeOfRecieptId { get; set; }
  @AuraEnabled
  public String placeOfRecieptSelectedItem { get; set; }
  @AuraEnabled
  public String routingDetails { get; set; }
  @AuraEnabled
  public String originalsToBeReleasedAt { get; set; }
  @AuraEnabled
  public Id voyageId { get; set; }

  // booking fields
  @AuraEnabled
  public Boolean isOldRoute { get; set; }
  @AuraEnabled
  public String oldVoyageNumber { get; set; }
  @AuraEnabled
  public String oldVesselName { get; set; }
  @AuraEnabled
  public String oldPortOfLoading { get; set; }
  @AuraEnabled
  public String oldPortOfDischarge { get; set; }
  @AuraEnabled
  public String oldPlaceOfReciept { get; set; }
  @AuraEnabled
  public String oldPointAndCountry { get; set; }
  @AuraEnabled
  public String oldPlaceOfDelivery { get; set; }
}
