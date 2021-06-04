/*
 * @company     : Nagarro Inc.
 * @date        : 31-08-2020
 * @author      : Nagarro
 * @description : DAO for sObject
 * @history     : Version 1.0
 * @test class  : SobjectDAOTest
 */
public inherited sharing class SobjectDAO implements IsObjectDAO {
  /*
   * @company     : Nagarro Inc.
   * @date        : 16-07-2020
   * @author      : Nagarro
   * @description : Interface for the DAO - Contains methods which must be implemented
   * @history     : Version 1.0
   */
  public interface IsObjectDAO {
    List<sObject> getsObjectData(String query);
  }

  /*
   * @purpose     : Method to get sObject detail.
   * @parameter   : query - Query to Execute
   * @return      : List<sObject> - List of sObject Records.
   */
  public static List<sObject> getsObjectData(String query) {
    try {
      return Database.query(query);
    } catch (Exception ex) {
      LogFactory.error(
        'SobjectDAO',
        'getsObjectData',
        'ERROR',
        ex.getLineNumber() +
        '  ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      return null;
    }
  }
}
