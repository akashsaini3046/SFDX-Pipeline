/*
 * Name: ADActualVsNormalisedRevenueController
 * Purpose: Controller class for Actual Vs Normalised Revenue component
 * Author: Nagarro
 * Created Date: 08-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */

public class ADActualVsNormalisedRevenueController {
  @AuraEnabled
  public String strActualRevenue { get; set; }
  @AuraEnabled
  public String strNormalisedRevenue { get; set; }

  /*
   * Method Name: getActualAndNormalisedRevenue
   * Input Parameters:
   * Id accountId: This holds parent/current account Id.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: AD_ActualVsNormalisedRevenueController
   * Purpose: This method gets data for expected opportunity pipeline and total opportunity pipeline from all the open opportunities related to the account
   */
  @AuraEnabled
  public static ADActualVsNormalisedRevenueController getActualAndNormalisedRevenue(
    Id accountId,
    ADMasterFilterWrapper objMasterFilter
  ) {
    Decimal actualRevenue;
    Decimal normalisedRevenue;

    //Filter accounts
    List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(
      ADAccountDashboardUtil.getAllRelatedAccount(accountId),
      objMasterFilter
    );

    //Get related open opportunities(as they will be considered pipeline opportunities) and apply filter on those
    List<Opportunity> opportunityList = ADAccountDashboardUtil.applyOpportunityFilter(
      ADAccountDashboardUtil.getAllRelatedOpenOpportunities(
        lstFilteredAccounts,
        objMasterFilter
      ),
      objMasterFilter
    );
    ADActualVsNormalisedRevenueController obj = new ADActualVsNormalisedRevenueController();

    actualRevenue = 0.00;
    normalisedRevenue = 0.00;

    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        actualRevenue =
          actualRevenue + (opp.Amount == null ? 0.00 : opp.Amount);
        normalisedRevenue =
          normalisedRevenue +
          (opp.NormalisedRevenue__c == null ? 0.00 : opp.NormalisedRevenue__c);
      }
    }
    actualRevenue = actualRevenue / Integer.valueOf(Label.AD_AMOUNT_CONVERTER);
    normalisedRevenue =
      normalisedRevenue / Integer.valueOf(Label.AD_AMOUNT_CONVERTER);

    obj.strActualRevenue = String.valueOf(
      actualRevenue.setScale(
        Integer.valueOf(Label.AD_VALUE_SCALE),
        RoundingMode.FLOOR
      )
    );
    obj.strNormalisedRevenue = String.valueOf(
      normalisedRevenue.setScale(
        Integer.valueOf(Label.AD_VALUE_SCALE),
        RoundingMode.FLOOR
      )
    );

    return obj;
  }
}
