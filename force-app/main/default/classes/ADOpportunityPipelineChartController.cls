/*
 * Name: ADOpportunityPipelineChartController
 * Purpose: Controller class for OpportunityPipelineChart component
 * which fetches data to draw opportunity pipeline chart.
 * Author: Nagarro
 * Created Date: 08-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADOpportunityPipelineChartController {
  /*
   * Method Name: getOpportunityChartData
   * Input Parameters:
   * Id idAccountId: This holds parent/current account Id.
   * AD_MasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: ADOpportunityPipelineChartDataWrapper
   * Purpose: Calculate stage wise opportunity pipeline amount by calling the utility class.
   */
  @AuraEnabled
  public static ADOpportunityPipelineChartDataWrapper getOpportunityChartData(
    Id idAccountId,
    ADMasterFilterWrapper objMasterFilter
  ) {
    Set<String> setOppotrunityCloseYear = new Set<String>();
    //Filter accounts
    List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(
      ADAccountDashboardUtil.getAllRelatedAccount(idAccountId),
      objMasterFilter
    );
    //Get related opportunities and apply filter on those
    List<Opportunity> lstRelatedOpportunities = ADAccountDashboardUtil.applyOpportunityFilter(
      ADAccountDashboardUtil.getAllRelatedOpportunities(
        lstFilteredAccounts,
        objMasterFilter
      ),
      objMasterFilter
    );
    //Get opportunity stages in list so that order of stages will be maintained
    List<String> lstOpportunityStage = ADAccountDashboardUtil.getOpportunityStage();
    //Get opportunity stages map with value and label, to handle the case of stage labels achange in future.
    Map<String, String> mapOpportunityStage = ADAccountDashboardUtil.getOpportunityStageMap();
    List<Decimal> lstOpportunityPipelineAmountByStage = new List<Decimal>();
    List<Decimal> lstOpportunityPipelineAmountByStageActual = new List<Decimal>();
    Map<String, Decimal> mapOpportunityPipeLineAmountByStage = new Map<String, Decimal>();
    Decimal decMaxCount = 1.00;
    //Get the closed status label
    Account_Dashboard_Custom_Metadata__mdt objAccountDashboardCustomMetadata = [
      SELECT Opportunity_Non_Pipeline_Stages__c, Opportunity_Conversion_Stage__c
      FROM Account_Dashboard_Custom_Metadata__mdt
      WHERE DeveloperName = 'Custom_Metadata_1'
      LIMIT 1
    ];
    List<String> lstNonPipelineStages = new List<String>();
    Decimal decOpportunityAmount;
    ADOpportunityPipelineChartDataWrapper objOpportunityPipelineChartDataWrapper = new ADOpportunityPipelineChartDataWrapper();

    for (
      String strNonPipelineStage : objAccountDashboardCustomMetadata.Opportunity_Non_Pipeline_Stages__c.split(
        ConstantClass.STRING_SPLITTER_OPPORTUNITY_STAGE
      )
    ) {
      lstNonPipelineStages.add(strNonPipelineStage);
    }

    //Initialize the mapOpportunityPipeLineAmountByStage map for each opportunity stage.
    for (String strOpportunityStage : lstOpportunityStage) {
      if (!lstNonPipelineStages.contains(strOpportunityStage)) {
        mapOpportunityPipeLineAmountByStage.put(strOpportunityStage, 0.00);
      }
    }
    lstOpportunityStage.clear();
    lstOpportunityStage.addAll(mapOpportunityPipeLineAmountByStage.keySet());

    //Sum pipeline opportunities amount by stage.
    for (Opportunity objOpportunity : lstRelatedOpportunities) {
      if (String.isNotBlank(objOpportunity.Est_Decision_Year__c)) {
        setOppotrunityCloseYear.add(
          String.valueOf(objOpportunity.Est_Decision_Year__c)
        );
      }
      if (
        mapOpportunityPipeLineAmountByStage.containsKey(
          objOpportunity.StageName
        ) &&
        !objOpportunity.isClosed &&
        !String.isBlank(objOpportunity.StageName)
      ) {
        mapOpportunityPipeLineAmountByStage.put(
          mapOpportunityStage.containsKey(objOpportunity.StageName)
            ? mapOpportunityStage.get(objOpportunity.StageName)
            : objOpportunity.StageName,
          null != objOpportunity.Amount
            ? mapOpportunityPipeLineAmountByStage.get(
                objOpportunity.StageName
              ) + objOpportunity.Amount
            : mapOpportunityPipeLineAmountByStage.get(objOpportunity.StageName)
        );
      } else if (
        !objOpportunity.isClosed && !String.isBlank(objOpportunity.StageName)
      ) {
        mapOpportunityPipeLineAmountByStage.put(
          mapOpportunityStage.containsKey(objOpportunity.StageName)
            ? mapOpportunityStage.get(objOpportunity.StageName)
            : objOpportunity.StageName,
          null != objOpportunity.Amount ? objOpportunity.Amount : 0.00
        );
        lstOpportunityStage.add(objOpportunity.StageName);
      }
    }

    //Compile opportunity data which will be used to created returnable wrapper.
    for (String strOpportunityStage : lstOpportunityStage) {
      //Converting amount in million and rounding uop to two decimal places and adding to the pipeline amount list.
      decOpportunityAmount = (mapOpportunityPipeLineAmountByStage.get(
          strOpportunityStage
        ) / Integer.valueOf(Label.AD_AMOUNT_CONVERTER))
        .setScale(Integer.valueOf(Label.AD_VALUE_SCALE), RoundingMode.FLOOR);
      lstOpportunityPipelineAmountByStage.add(decOpportunityAmount);
      lstOpportunityPipelineAmountByStageActual.add(
        mapOpportunityPipeLineAmountByStage.get(strOpportunityStage)
      );
      if (decMaxCount < decOpportunityAmount) {
        decMaxCount = decOpportunityAmount;
      }
    }

    //Creating the reaponse wrapper which will be returned by this method.
    objOpportunityPipelineChartDataWrapper.lstOpportunityStage = lstOpportunityStage;
    objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStage = lstOpportunityPipelineAmountByStage;
    objOpportunityPipelineChartDataWrapper.lstOpportunityPipelineAmountByStageActual = lstOpportunityPipelineAmountByStageActual;
    objOpportunityPipelineChartDataWrapper.lstFilteredAccounts = lstFilteredAccounts;
    objOpportunityPipelineChartDataWrapper.lstEstDecisionYear = new List<String>(
      setOppotrunityCloseYear
    );

    return objOpportunityPipelineChartDataWrapper;
  }
}
