/*
 * @company     : Nagarro Inc.
 * @date        : 31-08-2020
 * @author      : Nagarro
 * @description : DAO for Contact. and Related Objects
 * @history     : Version 1.0
 * @test class  : ContactDAOTest
 */
public inherited sharing class ContactDAO implements IContactDAO {
  /*
   * @company     : Nagarro Inc.
   * @date        : 16-07-2020
   * @author      : Nagarro
   * @description : Interface for the DAO - Contains methods which must be implemented
   * @history     : Version 1.0
   */
  public interface IContactDAO {
    Integer getTotalContactsByQueryAccountIds(
      String query,
      List<Id> accountIds
    );
    List<Contact> getContactsByEmails(Set<String> setEmails);
    List<Contact> getContactsByIds(Set<Id> contactIds);
    List<Contact> getContactsDetailByFirstNLastNPhoneEmail(
      String firstName,
      String lastname,
      String phone,
      String email,
      Id accountId
    );
  }

  /*
   * @purpose     : Method to get Total Contacts by List of Account Id.
   * @parameter   : query - Query String to be executed
   * @parameter   : List of account Ids
   * @return      : Integer - Number of Contacts
   */
  public static Integer getTotalContactsByQueryAccountIds(
    String query,
    List<Id> accountIds
  ) {
    AggregateResult results = Database.query(query);
    Integer totalRecords = (Integer) results.get('Total');
    return totalRecords;
  }

  /*
   * @purpose		: Method to get contacts list by set of Emails.
   * @parameter	: emails - Set of Emails.
   * return 		: List of Contacts
   */
  public static List<Contact> getContactsByEmails(Set<String> setEmails) {
    return [SELECT Id, Email FROM Contact WHERE Email IN :setEmails];
  }

  /*
   * @purpose		: Method to get contacts list by Id.
   * @parameter	: emails - Set of Emails.
   * return 		: List of Contacts
   */
  public static List<Contact> getContactsByIds(Set<Id> contactIds) {
    return [SELECT Id, Name, Email, Phone FROM Contact WHERE Id IN :contactIds];
  }

  public static List<Contact> getContactsDetailByFirstNLastNPhoneEmail(
    String firstName,
    String lastname,
    String phone,
    String email,
    Id accountId
  ) {
    return [
      SELECT Id, FirstName, LastName, Email, Phone
      FROM Contact
      WHERE
        AccountId = :accountId
        AND FirstName = :firstName
        AND LastName = :lastname
        AND Email = :email
        AND Phone = :phone
    ];
  }
}
