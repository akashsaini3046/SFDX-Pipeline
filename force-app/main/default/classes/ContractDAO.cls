public without sharing class ContractDAO {
  @AuraEnabled
  public static List<Contract> getContract(Id contractId) {
    List<Contract> listContract = [
      SELECT
        Id,
        Contracted_Commodities__c,
        Contracted_Commodities_Vehicle__c,
        Contracted_Equipments__c
      FROM Contract
      WHERE Id = :contractId
    ];
    return listContract;
  }
}
