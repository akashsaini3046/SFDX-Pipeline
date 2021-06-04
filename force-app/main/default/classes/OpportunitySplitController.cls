/*
 * Name: OpportunitySplitController
 * Purpose: Controller class for Opportunity split component
 * Author: Nagarro
 * Created Date: 18-Feb-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public without sharing class OpportunitySplitController {
  /*
   * Method Name: getOpportunityLineItems
   * Input Parameters:
   * Id idOpportunity: This holds current opportunity Id.
   * Return value: List<OpportunitySplitServiceWrapper>
   * Purpose: get opportunity line items which are related to current opportunity.
   */
  @AuraEnabled
  public static List<OpportunitySplitServiceWrapper> getOpportunityLineItems(
    Id idOpportunity,
    String strSource
  ) {
    List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = new List<OpportunitySplitServiceWrapper>();
    List<OpportunityLineItem> lstOpportunitLineItems = new List<OpportunityLineItem>();

    lstOpportunitLineItems = [
      SELECT
        Id,
        Product2.Name,
        Trade__c,
        Lost_Sales_Price__c,
        Lost_Revenue__c,
        toLabel(OriginCountry__c),
        toLabel(DestinationCountry__c),
        Quantity,
        UnitPrice,
        TotalPrice,
        Service_Status__c,
        Opportunity.Is_Split_Taken_Care__c
      FROM OpportunityLineItem
      WHERE OpportunityId = :idOpportunity
    ];

    if (strSource == 'DESKTOP_CLOSED_WON') {
      //Bypass trigger handlers from execution becuse lineitems contain all fields hence trigger execution is not required.
      //Get the handlers to bypass.
      Opportunity_Split_Constant__mdt objOpportunitySplitCustomMetadata = [
        SELECT Trigger_Handlers__c
        FROM Opportunity_Split_Constant__mdt
        WHERE DeveloperName = 'Bypass_Handlers'
        LIMIT 1
      ];
      for (
        String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
          ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
        )
      ) {
        TriggerHandler.bypass(strHandlerToBypass);
      }

      //Commit the won stage in opportunity line items which are part of un-splited opportunity
      if (
        commitWonStage(lstOpportunitLineItems, idOpportunity) == true &&
        getOpportunity(idOpportunity).Is_Split_Taken_Care__c == false
      ) {
        //Mark opportunity as split if unsplited
        markOpportunityAsSplit(idOpportunity);
      }

      //Reset trigger handlers bypass
      for (
        String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
          ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
        )
      ) {
        TriggerHandler.clearBypass(strHandlerToBypass);
      }
    }

    for (OpportunityLineItem objOpportunityLineItem : lstOpportunitLineItems) {
      OpportunitySplitServiceWrapper objOpportunitySplitServiceWrapper = new OpportunitySplitServiceWrapper();
      objOpportunitySplitServiceWrapper.idLineItem = objOpportunityLineItem.Id;
      objOpportunitySplitServiceWrapper.strProductName = objOpportunityLineItem.Product2.Name;
      objOpportunitySplitServiceWrapper.strTrade = objOpportunityLineItem.Trade__c;
      objOpportunitySplitServiceWrapper.strOriginCountry = objOpportunityLineItem.OriginCountry__c;
      objOpportunitySplitServiceWrapper.strDestinationCountry = objOpportunityLineItem.DestinationCountry__c;
      objOpportunitySplitServiceWrapper.decQuantity = objOpportunityLineItem.Quantity;
      objOpportunitySplitServiceWrapper.decUnitPrice = objOpportunityLineItem.UnitPrice;
      objOpportunitySplitServiceWrapper.decTotalPrice = objOpportunityLineItem.TotalPrice;
      objOpportunitySplitServiceWrapper.decLostUnitPrice = objOpportunityLineItem.Lost_Sales_Price__c;
      objOpportunitySplitServiceWrapper.decLostTotalPrice = objOpportunityLineItem.Lost_Revenue__c;
      objOpportunitySplitServiceWrapper.boolServiceStatus = (objOpportunityLineItem.Service_Status__c ==
        Label.OPS_SERVICE_STATUS_LOST
        ? false
        : true);
      lstOpportunitySplitServiceWrapper.add(objOpportunitySplitServiceWrapper);
    }

    return lstOpportunitySplitServiceWrapper;
  }

  /*
   * Method Name: getWonAndLostOppSize
   * Input Parameters:
   * Id idOpportunity: This holds current opportunity Id.
   * Return value: Map<String, Decimal>
   * Purpose: get won and lost line item size.
   */
  @AuraEnabled
  public static Map<String, Decimal> getWonAndLostOppSize(Id idOpportunity) {
    Decimal decWonServiceSize = 0.00, decLostServiceSize = 0.00;
    for (OpportunityLineItem objOpportunityLineItem : [
      SELECT Id, TotalPrice, Service_Status__c, Lost_Revenue__c
      FROM OpportunityLineItem
      WHERE OpportunityId = :idOpportunity
    ]) {
      if (
        objOpportunityLineItem.Service_Status__c ==
        Label.OPS_SERVICE_STATUS_WON ||
        (objOpportunityLineItem.Service_Status__c == null)
      ) {
        decWonServiceSize += objOpportunityLineItem.TotalPrice;
      } else if (
        objOpportunityLineItem.Service_Status__c ==
        Label.OPS_SERVICE_STATUS_LOST
      ) {
        decLostServiceSize += objOpportunityLineItem.Lost_Revenue__c;
      }
    }
    return new Map<String, Decimal>{
      'WON_OPP_SIZE' => decWonServiceSize,
      'LOST_OPP_SIZE' => decLostServiceSize
    };
  }

  /*
   * Method Name: commitWonStage
   * Input Parameters:
   * List<OpportunityLineItem> lstOpportunitLineItems: This holds opportunity LineItem.
   * Return value: boolean
   * Purpose: This methos will mark opportunity line item as won.
   */
  private static boolean commitWonStage(
    List<OpportunityLineItem> lstOpportunitLineItems,
    Id idOpportunity
  ) {
    List<OpportunityLineItem> lstOpportunityLineItemToCommitWon = new List<OpportunityLineItem>();
    Boolean boolResult = true;

    //Set spit progress on flag in opportunity
    try {
      update new Opportunity(
        Id = idOpportunity,
        Opportunity_Split_in_Progress__c = true
      );
    } catch (Exception objEx) {
      System.debug(
        'OpportunitySplitController > saveSplitOpportunity ::' +
        objEx.getMessage()
      );
      boolResult = false;
    }

    if (boolResult) {
      for (
        OpportunityLineItem objOpportunityLineItem : lstOpportunitLineItems
      ) {
        if (
          objOpportunityLineItem.Opportunity.Is_Split_Taken_Care__c == false
        ) {
          objOpportunityLineItem.Service_Status__c = Label.OPS_SERVICE_STATUS_WON;
          lstOpportunityLineItemToCommitWon.add(
            new OpportunityLineItem(
              Id = objOpportunityLineItem.Id,
              Service_Status__c = Label.OPS_SERVICE_STATUS_WON
            )
          );
        }
      }

      try {
        if (!lstOpportunityLineItemToCommitWon.isEmpty()) {
          update lstOpportunityLineItemToCommitWon;
        }
      } catch (Exception objEx) {
        System.debug(
          'OpportunitySplitController > commitWonStage ::' + objEx.getMessage()
        );
        boolResult = false;
      }
    }

    //Set spit progress off flag in opportunity
    try {
      update new Opportunity(
        Id = idOpportunity,
        Opportunity_Split_in_Progress__c = false
      );
    } catch (Exception objEx) {
      System.debug(
        'OpportunitySplitController > saveSplitOpportunity ::' +
        objEx.getMessage()
      );
      boolResult = false;
    }

    return boolResult;
  }

  /*
   * Method Name: markOpportunityAsSplited
   * Input Parameters:
   * Id idOpportunity: This holds current opportunity Id.
   * Return value:
   * Purpose: This methos will mark opportunity as splited.
   */
  public static boolean markOpportunityAsSplit(Id idOpportunity) {
    Boolean boolResult = true;

    try {
      update new Opportunity(Id = idOpportunity, Is_Split_Taken_Care__c = true);
    } catch (Exception objEx) {
      boolResult = false;
      System.debug(
        'OpportunitySplitController > markOpportunityAsSplited ::' +
        objEx.getMessage()
      );
    }

    return boolResult;
  }

  /*
   * Method Name: getOpportunity
   * Input Parameters:
   * Id idOpportunity: This holds current opportunity Id.
   * Return value: Opportunity
   * Purpose: returns current opportunity with specified fields.
   */
  @AuraEnabled
  public static Opportunity getOpportunity(Id idOpportunity) {
    return [
      SELECT
        Is_Split_Taken_Care__c,
        Current_User_Profile__c,
        StageName,
        (SELECT Id FROM OpportunityLineItems)
      FROM Opportunity
      WHERE Id = :idOpportunity
    ];
  }

  /*
   * Method Name: saveSplitOpportunity
   * Input Parameters:
   * Id idOpportunity: This holds current opportunity Id.
   * List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper: This holds opportunity line items which are shown on split UI.
   * Return value: Boolean
   * Purpose: This method is used to marks opportunity line item as lost or won. It checks whether service is marked as loss, if lost service then it copies the unit price into lost sales price and mark the service as lost.
   */
  @AuraEnabled
  public static Boolean saveSplitOpportunity(
    Id idOpportunity,
    List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper
  ) {
    List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
    List<Id> lstOpportunityLineItemIds = new List<Id>();
    Map<Id, OpportunityLineItem> mapOpportunityLineItems = new Map<Id, OpportunityLineItem>();
    Savepoint objSavepoint;
    Boolean boolResult = true;
    String strServiceStatus;

    //Set spit progress on flag in opportunity
    try {
      update new Opportunity(
        Id = idOpportunity,
        Opportunity_Split_in_Progress__c = true
      );
    } catch (Exception objEx) {
      System.debug(
        'OpportunitySplitController > saveSplitOpportunity ::' +
        objEx.getMessage()
      );
      boolResult = false;
    }

    //Bypass trigger handlers from execution becuse lineitems contain all fields hence trigger execution is not required.
    //Get the handlers to bypass.
    Opportunity_Split_Constant__mdt objOpportunitySplitCustomMetadata = [
      SELECT Trigger_Handlers__c
      FROM Opportunity_Split_Constant__mdt
      WHERE DeveloperName = 'Bypass_Handlers'
      LIMIT 1
    ];
    for (
      String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
        ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
      )
    ) {
      TriggerHandler.bypass(strHandlerToBypass);
    }

    //Get lineitems from the lstOpportunitySplitServiceWrapper.
    for (
      OpportunitySplitServiceWrapper objOpportunitySplitServiceWrapper : lstOpportunitySplitServiceWrapper
    ) {
      lstOpportunityLineItemIds.add(
        objOpportunitySplitServiceWrapper.idLineItem
      );
    }

    //Get the line items and associated lost salesprice.
    try {
      mapOpportunityLineItems = new Map<Id, OpportunityLineItem>(
        [
          SELECT Id, Service_Status__c, UnitPrice, Lost_Sales_Price__c
          FROM OpportunityLineItem
          WHERE Id IN :lstOpportunityLineItemIds
        ]
      );
    } catch (Exception objEx) {
      System.debug(
        'OpportunitySplitController > saveSplitOpportunity ::' +
        objEx.getMessage()
      );
      boolResult = false;
    }

    // Mark a savepoint.
    objSavepoint = Database.setSavepoint();

    if (boolResult) {
      //Handle update in the opportunity line items based on the service status selected by user.
      for (
        OpportunitySplitServiceWrapper objOpportunitySplitServiceWrapper : lstOpportunitySplitServiceWrapper
      ) {
        if (objOpportunitySplitServiceWrapper.boolServiceStatus == true) {
          if (
            mapOpportunityLineItems.get(
              objOpportunitySplitServiceWrapper.idLineItem
            ) != null &&
            mapOpportunityLineItems.get(
                objOpportunitySplitServiceWrapper.idLineItem
              )
              .Service_Status__c == Label.OPS_SERVICE_STATUS_LOST &&
            mapOpportunityLineItems.get(
                objOpportunitySplitServiceWrapper.idLineItem
              )
              .UnitPrice == 0.00 &&
            mapOpportunityLineItems.get(
                objOpportunitySplitServiceWrapper.idLineItem
              )
              .Lost_Sales_Price__c != null
          ) {
            //Replace unit plice with lost sales price in case if service is marked as won after marking it as lossed earlier provided current unit price is 0.00.
            lstOpportunityLineItem.add(
              new OpportunityLineItem(
                id = objOpportunitySplitServiceWrapper.idLineItem,
                Service_Status__c = Label.OPS_SERVICE_STATUS_WON,
                Lost_Sales_Price__c = null,
                UnitPrice = mapOpportunityLineItems.get(
                    objOpportunitySplitServiceWrapper.idLineItem
                  )
                  .Lost_Sales_Price__c
              )
            );
          } else {
            lstOpportunityLineItem.add(
              new OpportunityLineItem(
                id = objOpportunitySplitServiceWrapper.idLineItem,
                Service_Status__c = Label.OPS_SERVICE_STATUS_WON,
                Lost_Sales_Price__c = null
              )
            );
          }
        } else if (
          objOpportunitySplitServiceWrapper.boolServiceStatus == false
        ) {
          strServiceStatus = Label.OPS_SERVICE_STATUS_LOST;
          //Handle the case if already split opportunity has been reopened for spliting.
          if (
            mapOpportunityLineItems.containsKey(
              objOpportunitySplitServiceWrapper.idLineItem
            )
          ) {
            if (
              mapOpportunityLineItems.get(
                objOpportunitySplitServiceWrapper.idLineItem
              ) != null &&
              mapOpportunityLineItems.get(
                  objOpportunitySplitServiceWrapper.idLineItem
                )
                .Service_Status__c != strServiceStatus
            ) {
              lstOpportunityLineItem.add(
                new OpportunityLineItem(
                  id = objOpportunitySplitServiceWrapper.idLineItem,
                  Service_Status__c = Label.OPS_SERVICE_STATUS_LOST,
                  Lost_Sales_Price__c = objOpportunitySplitServiceWrapper.decUnitPrice,
                  UnitPrice = 0.00
                )
              );
            }
          }
        }
      }
    }

    if (!lstOpportunityLineItem.isEmpty() && boolResult) {
      try {
        update lstOpportunityLineItem;
        update new Opportunity(
          Id = idOpportunity,
          Is_Split_Taken_Care__c = true
        );
      } catch (Exception objEx) {
        System.debug(
          'OpportunitySplitController > saveSplitOpportunity ::' +
          objEx.getMessage()
        );
        boolResult = false;
      }
    }

    if (boolResult == false) {
      // Rollback current transaction
      Database.rollback(objSavepoint);
    }

    //Reset trigger handlers bypass
    for (
      String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
        ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
      )
    ) {
      TriggerHandler.clearBypass(strHandlerToBypass);
    }

    //Set spit progress off flag in opportunity
    try {
      update new Opportunity(
        Id = idOpportunity,
        Opportunity_Split_in_Progress__c = false
      );
    } catch (Exception objEx) {
      System.debug(
        'OpportunitySplitController > saveSplitOpportunity ::' +
        objEx.getMessage()
      );
      boolResult = false;
    }

    return boolResult;
  }

  /*
   * Method Name: getUIThemeDescription
   * Input Parameters:
   * Return value: String
   * Purpose: This method is used to get UI theme which is being used.
   */
  @AuraEnabled
  public static String getUIThemeDescription() {
    String theme = UserInfo.getUiThemeDisplayed();
    return theme;
  }

  /*
   * Method Name: restoreLostOpportunityLineItem
   * Input Parameters:
   * List<Opportunity> lstNewOpportunity: This holds new opportunity list
   * Map<Id, Opportunity> mapOldOpportunity: this holds opportunity old map
   * Return value:
   * Purpose: This method is used to restore the lost opportunity line item to its previous salesprice and quoted price.
   */
  public static void restoreLostOpportunityLineItem(
    List<Opportunity> lstNewOpportunity,
    Map<Id, Opportunity> mapOldOpportunity
  ) {
    List<OpportunityLineItem> lstOpportunityLineItems = new List<OpportunityLineItem>();
    Set<Id> lstOpportunityToBeConsideredForLineItemUpdate = new Set<Id>();
    List<Opportunity> lstOpportunityToRestore = new List<Opportunity>();

    for (Opportunity objOpportunity : lstNewOpportunity) {
      if (
        objOpportunity.StageName != Label.OPS_LABEL_CLOSED_WON_OPP &&
        objOpportunity.StageName != Label.OPS_OPP_STAGE_CLOSED_LOST &&
        mapOldOpportunity != null &&
        mapOldOpportunity.get(objOpportunity.Id) != null &&
        mapOldOpportunity.get(objOpportunity.Id).StageName !=
        objOpportunity.StageName
      ) {
        lstOpportunityToBeConsideredForLineItemUpdate.add(objOpportunity.Id);
        lstOpportunityToRestore.add(
          new Opportunity(
            Id = objOpportunity.Id,
            Is_Split_Taken_Care__c = false
          )
        );
      }
    }

    lstOpportunityLineItems = [
      SELECT Id, Service_Status__c, Lost_Sales_Price__c, UnitPrice
      FROM OpportunityLineItem
      WHERE OpportunityId IN :lstOpportunityToBeConsideredForLineItemUpdate
    ];

    for (OpportunityLineItem objOpportunityLineItem : lstOpportunityLineItems) {
      if (
        objOpportunityLineItem.Service_Status__c ==
        Label.OPS_SERVICE_STATUS_LOST &&
        objOpportunityLineItem.UnitPrice == 0.00 &&
        objOpportunityLineItem.Lost_Sales_Price__c != null &&
        objOpportunityLineItem.Lost_Sales_Price__c != 0.00
      ) {
        objOpportunityLineItem.UnitPrice = objOpportunityLineItem.Lost_Sales_Price__c;
      }
      objOpportunityLineItem.Service_Status__c = null;
      objOpportunityLineItem.Lost_Sales_Price__c = null;
    }

    if (!lstOpportunityLineItems.isEmpty()) {
      try {
        update lstOpportunityLineItems;
      } catch (Exception objEx) {
        System.debug(
          'OpportunitySplitController > restoreLostOpportunityLineItem ::' +
          objEx.getMessage()
        );
      }
    }

    if (!lstOpportunityToRestore.isEmpty()) {
      try {
        update lstOpportunityToRestore;
      } catch (Exception objEx) {
        System.debug(
          'OpportunitySplitController > restoreLostOpportunityLineItem ::' +
          objEx.getMessage()
        );
      }
    }
  }
}
