/*
 * Name: ADOpportunityPipelineChartDataWrapper
 * Purpose: Wrapper class to represent Chart Data
 * Author: Nagarro
 * Created Date: 08-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADOpportunityPipelineChartDataWrapper {
  @AuraEnabled
  public List<String> lstOpportunityStage { get; set; }
  @AuraEnabled
  public List<Decimal> lstOpportunityPipelineAmountByStage { get; set; }
  @AuraEnabled
  public List<Decimal> lstOpportunityPipelineAmountByStageActual { get; set; }
  @AuraEnabled
  public Integer intMaxCount { get; set; }
  @AuraEnabled
  public Integer intChartInterval { get; set; }
  @AuraEnabled
  public List<Id> lstFilteredAccounts { get; set; }
  @AuraEnabled
  public List<String> lstEstDecisionYear { get; set; }
}
