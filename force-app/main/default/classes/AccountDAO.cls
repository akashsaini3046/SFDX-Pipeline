/*
 * @company     : Nagarro Inc.
 * @date        : 31-08-2020
 * @author      : Nagarro
 * @description : DAO for Account. and Related Objects
 * @history     : Version 1.0
 * @test class  : AccountDAOTest
 */
public inherited sharing class AccountDAO implements IAccountDAO {
  /*
   * @company     : Nagarro Inc.
   * @date        : 16-07-2020
   * @author      : Nagarro
   * @description : Interface for the DAO - Contains methods which must be implemented
   * @history     : Version 1.0
   */
  public interface IAccountDAO {
    Map<String, Id> getAccountDataFromContract(Set<String> contractSet);
    List<Account> getAccountByCVIF(Set<String> setOfCVIF);
    Account getAccountByAccountId(Id accountId);
    List<AccountTeamMember> getAccountTeamMembersByAccountId(Id accountId);
    Integer getTotalChildAccountsByQuery(String query, Id accountId);
    List<Account> getAccountDetailsByAccountIds(Set<Id> accountId);
  }

  /*
   * @purpose     : Method to get Account detail from the contract data.
   * @parameter   : contractSet - contract set
   * @return      : Map < String, Id > - Map of Contract number and Account Id.
   */
  public static Map<String, Id> getAccountDataFromContract(
    Set<String> contractSet
  ) {
    Map<String, Id> mapOfContractAndAccount = new Map<String, Id>();
    for (Contract contractRec : [
      SELECT Id, Name, AccountId
      FROM Contract
      WHERE Name IN :contractSet
    ]) {
      mapOfContractAndAccount.put(contractRec.Name, contractRec.AccountId);
    }
    return mapOfContractAndAccount;
  }

  /*
   * @purpose     : Method to get Account detail by CVIF Ids.
   * @parameter   : setOfCVIF - set Of CVIF
   * @return      : List<Account > - List of Account
   */
  public static List<Account> getAccountByCVIF(Set<String> setOfCVIF) {
    return [SELECT id, CVIF__c FROM Account WHERE CVIF__c IN :setOfCVIF];
  }

  /*
   * @purpose     : Method to get Account Details containing Child Account by Account Id.
   * @parameter   : accountId - account Id
   * @return      : Account - Fetched Account
   */
  public static Account getAccountByAccountId(Id accountId) {
    return [
      SELECT
        Name,
        CVIF__c,
        ParentId,
        Parent.Name,
        OwnerId,
        Owner.FirstName,
        Owner.LastName,
        ChangeAccountOwner__c,
        Phone,
        toLabel(Type),
        toLabel(Region__c),
        Sales_Rep_Region__c,
        toLabel(Industry),
        (
          SELECT Id, Name, CVIF__c, OwnerId, Owner.FirstName, Owner.LastName
          FROM ChildAccounts
        )
      FROM Account
      WHERE id = :accountId
    ];
  }

  /*
   * @purpose     : Method to get Account Details by Account Ids.
   * @parameter   : accountId - account Id
   * @return      : Account - Fetched Account
   */
  public static List<Account> getAccountDetailsByAccountIds(
    Set<Id> accountIds
  ) {
    return [
      SELECT
        Name,
        CVIF__c,
        ParentId,
        Parent.Name,
        OwnerId,
        Owner.FirstName,
        Owner.LastName,
        Email__c,
        ChangeAccountOwner__c,
        Phone,
        toLabel(Type),
        toLabel(Region__c),
        Sales_Rep_Region__c,
        toLabel(Industry)
      FROM Account
      WHERE Id IN :accountIds
    ];
  }

  /*
   * @purpose     : Method to get Account Team Members by Account Id.
   * @parameter   : accountId - account Id
   * @return      : List of AccountTeamMembers - Fetched Account Team Members
   */
  public static List<AccountTeamMember> getAccountTeamMembersByAccountId(
    Id accountId
  ) {
    return [
      SELECT
        Id,
        AccountId,
        TeamMemberRole,
        User.FirstName,
        User.LastName,
        UserId
      FROM AccountTeamMember
      WHERE AccountId = :accountId
    ];
  }

  /*
   * @purpose     : Method to get Total Child Accounts by Account Id.
   * @parameter   : query - Query String to be executed
   * @parameter   : accountId - account Id
   * @return      : Integer - Number of Child Accounts
   */
  public static Integer getTotalChildAccountsByQuery(
    String query,
    Id accountId
  ) {
    AggregateResult results = Database.query(query);
    Integer totalRecords = (Integer) results.get('Total');
    return totalRecords;
  }
}
