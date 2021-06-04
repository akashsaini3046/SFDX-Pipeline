/*
 * Name: ADOpportunityConversionRateController
 * Purpose: Controller class for Opportunity Conversion Rate Controller Component
 * which calculates opportunity conversion rate.
 * Author: Nagarro
 * Created Date: 18-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADOpportunityConversionRateController {
  /*
   * Method Name: getOpportunityConversionRate
   * Input Parameters:
   * Id idAccountId: This holds parent/current account Id.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: Map<String, String>
   * Purpose: Calculate opportunity conversion rate by considering closed-won and total opportunities.
   */
  @AuraEnabled
  public static Map<String, String> getOpportunityConversionRate(
    Id idAccountId,
    ADMasterFilterWrapper objMasterFilter
  ) {
    //This veriable holds total opportunity count after applying filter
    Decimal intTotalfilteredOpportunityCount = 0;
    //This veriable holds colosed won opportunity count after applying filter
    Decimal intTotalfilteredClosedOwnOpportunityCount = 0;

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
    //Get the closed status label
    Account_Dashboard_Custom_Metadata__mdt objAccountDashboardCustomMetadata = [
      SELECT Opportunity_Non_Pipeline_Stages__c, Opportunity_Conversion_Stage__c
      FROM Account_Dashboard_Custom_Metadata__mdt
      WHERE DeveloperName = 'Custom_Metadata_1'
      LIMIT 1
    ];
    Decimal decConversionRate;

    for (Opportunity objOpportunity : lstRelatedOpportunities) {
      //Converted opportunities count
      if (
        objOpportunity.StageName ==
        objAccountDashboardCustomMetadata.Opportunity_Conversion_Stage__c
      ) {
        intTotalfilteredClosedOwnOpportunityCount++;
      }
    }

    //Total opportunities count. If the count is zero then initialize it with one to handle divide by zero error.
    intTotalfilteredOpportunityCount = (lstRelatedOpportunities.size() > 0
      ? lstRelatedOpportunities.size()
      : 1);

    //Calculate opportunity conversion rate
    decConversionRate =
      (intTotalfilteredClosedOwnOpportunityCount /
      intTotalfilteredOpportunityCount) * 100;
    decConversionRate = decConversionRate.setScale(
      Integer.valueOf(Label.AD_VALUE_SCALE),
      RoundingMode.FLOOR
    );

    return new Map<String, String>{
      'ConversionRate' => String.valueOf(decConversionRate),
      'Filtered Year' => objMasterFilter.strSelectedYear
    };
  }
}
