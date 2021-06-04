public with sharing class CC_ContractDetailController {
  @AuraEnabled
  public static ContractDetailWrapper getContractsRecord(Id contractId) {
    ContractDetailWrapper contractDetailWrapper = new ContractDetailWrapper();
    Contract contractRecord = new Contract();
    try {
      contractRecord = [
        SELECT
          Id,
          Name,
          Account.Name,
          Account.CVIF__c,
          AccountId,
          Softship_Contract_Number__c,
          (
            SELECT Id, Account__r.Name, Account__r.CVIF__c, Account__c
            FROM Contract_Accounts__r
          )
        FROM Contract
        WHERE Id = :contractId
      ];
      if (contractRecord != null) {
        contractDetailWrapper.contract = contractRecord;
        List<List<AffiliatesWrapper>> affiliatesList = new List<List<AffiliatesWrapper>>();
        affiliatesList.add(getAffiliateWrapperList(contractRecord, null));
        for (
          Contract_Account__c contractAccount : contractRecord.Contract_Accounts__r
        ) {
          affiliatesList.add(getAffiliateWrapperList(null, contractAccount));
        }
        contractDetailWrapper.affiliatesList = affiliatesList;
      }
      return contractDetailWrapper;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_AccountDetailController',
        'getAccountRecord',
        'Account Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      return null;
    }
  }

  private static List<AffiliatesWrapper> getAffiliateWrapperList(
    Contract contract,
    Contract_Account__c contractAccount
  ) {
    List<AffiliatesWrapper> affiliatesWrapperList = new List<AffiliatesWrapper>();
    if (contract != null) {
      AffiliatesWrapper affName = new AffiliatesWrapper(
        'Affiliates',
        contract.Account.Name,
        'url',
        'accountDetail/' + contract.AccountId
      );
      AffiliatesWrapper affCvif = new AffiliatesWrapper(
        'CVIF ID',
        contract.Account.CVIF__c,
        'text',
        null
      );
      affiliatesWrapperList.add(affName);
      affiliatesWrapperList.add(affCvif);
    }
    if (contractAccount != null) {
      AffiliatesWrapper affName = new AffiliatesWrapper(
        'Affiliates',
        contractAccount.Account__r.Name,
        'url',
        'accountDetail/' + contractAccount.Account__c
      );
      AffiliatesWrapper affCvif = new AffiliatesWrapper(
        'CVIF ID',
        contractAccount.Account__r.CVIF__c,
        'text',
        null
      );
      affiliatesWrapperList.add(affName);
      affiliatesWrapperList.add(affCvif);
    }
    return affiliatesWrapperList;
  }

  public class ContractDetailWrapper {
    @AuraEnabled
    public Contract contract { get; set; }
    @AuraEnabled
    public List<List<AffiliatesWrapper>> affiliatesList { get; set; }

    ContractDetailWrapper() {
      this.contract = new Contract();
      this.affiliatesList = new List<List<AffiliatesWrapper>>();
    }
  }

  public class AffiliatesWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String dataType;
    @AuraEnabled
    public String redirectUrl;

    AffiliatesWrapper(
      String label,
      String value,
      String dataType,
      String redirectUrl
    ) {
      this.label = label;
      this.value = (value != null ? value : '');
      this.dataType = dataType;
      this.redirectUrl = (redirectUrl != null ? redirectUrl : '');
    }
  }
}
