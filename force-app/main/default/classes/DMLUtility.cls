/*
 * 11-06-2020 – Lovesh Tomar – Created this class for handling DML operations.
 *
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 11-06-2020
 * @author      : Nagarro
 * @description : Utility for DML Operations
 * @history     : Version 1.0
 * @test class  : DMLUtilityTest
 */
public with sharing class DMLUtility implements DmlInterface {
  public interface DmlInterface {
    Database.SaveResult[] insertRecords(
      List<SObject> records,
      Boolean allOrNoneIndicator
    );
    Database.SaveResult[] updateRecords(
      List<SObject> records,
      Boolean allOrNoneIndicator
    );
    //Database.UpsertResult[] upsertRecords(List < SObject > records, Schema.SObjectField externalIDField, Boolean allOrNoneIndicator);
    Database.DeleteResult[] deleteRecords(
      List<SObject> records,
      Boolean allOrNoneIndicator
    );
    Database.UnDeleteResult[] unDeleteRecords(
      List<SObject> records,
      Boolean allOrNoneIndicator
    );
  }
  /*
   * @purpose     : Method to insert SObject records
   * @parameter   : records - The SObject records to be inserted
   * @parameter   : allOrNoneIndicator - Boolean indicator for partial insert
   * @return      : Database.SaveResult[]
   */
  public static Database.SaveResult[] insertRecords(
    List<SObject> records,
    Boolean allOrNoneIndicator
  ) {
    Database.SaveResult[] results = Database.insert(
      records,
      allOrNoneIndicator
    );
    List<Database.Error> dataBaseErrors = new List<Database.Error>();
    for (Database.SaveResult result : results) {
      if (!result.isSuccess()) {
        Database.Error[] dmlErrors = result.getErrors();

        dataBaseErrors.addAll(dmlErrors);
      }
    }
    if (dataBaseErrors != null && !dataBaseErrors.isEmpty()) {
      LogFactory.logDatabaseErrors(
        'DMLUtility',
        'insertRecords',
        dataBaseErrors
      );
    }
    return results;
  }

  /*
   * @purpose     : Method to update SObject records
   * @parameter   : records - The SObject records to be updated
   * @parameter   : allOrNoneIndicator - Boolean indicator for partial update
   * @return      : Database.SaveResult[]
   */
  public static Database.SaveResult[] updateRecords(
    List<SObject> records,
    Boolean allOrNoneIndicator
  ) {
    Database.SaveResult[] results = Database.update(
      records,
      allOrNoneIndicator
    );
    if (results != null && !records.isEmpty()) {
      List<Database.Error> dataBaseErrors = new List<Database.Error>();
      for (Database.SaveResult result : results) {
        if (!result.isSuccess()) {
          Database.Error[] dmlErrors = result.getErrors();
          dataBaseErrors.addAll(dmlErrors);
        }
      }
      if (dataBaseErrors != null && !dataBaseErrors.isEmpty()) {
        LogFactory.logDatabaseErrors(
          'DMLUtility',
          'updateRecords',
          dataBaseErrors
        );
      }
    }
    return results;
  }

  /*
   * @purpose     : Method to upsert SObject records
   * @parameter   : records - The SObject records to be upserted
   * @parameter   : externalIDField - The field to be used for upsert operation.
   * @parameter   : allOrNoneIndicator - Boolean indicator for partial upsert
   * @return      : Database.UpsertResult[]
   */
  /*  public static Database.UpsertResult[] upsertRecords(List < SObject > records, Schema.SObjectField externalIDField, Boolean allOrNoneIndicator) {
        Database.UpsertResult[] results = Database.upsert(records, externalIDField, allOrNoneIndicator);
             List<Database.Error> dataBaseErrors= new List<Database.Error>();
             for (Database.UpsertResult result: results) {
                if (!result.isSuccess()) {
                     Database.Error[] dmlErrors = result.getErrors();
                     dataBaseErrors.addAll(dmlErrors);
                 }
             }
             if(dataBaseErrors!=null && !dataBaseErrors.isEmpty()){
                 LogFactory.logDatabaseErrors('DMLUtility','upsertRecords',dataBaseErrors);
             }
         return results;
     }  */

  /*
   * @purpose     : Method to delete SObject records
   * @parameter   : records - The SObject records to be deleted
   * @parameter   : allOrNoneIndicator - Boolean indicator for partial delete
   * @return      : Database.DeleteResult[]
   */
  public static Database.DeleteResult[] deleteRecords(
    List<SObject> records,
    Boolean allOrNoneIndicator
  ) {
    Database.DeleteResult[] results = Database.delete(
      records,
      allOrNoneIndicator
    );
    List<Database.Error> dataBaseErrors = new List<Database.Error>();
    for (Database.DeleteResult result : results) {
      if (!result.isSuccess()) {
        Database.Error[] dmlErrors = result.getErrors();
        dataBaseErrors.addAll(dmlErrors);
      }
    }
    if (dataBaseErrors != null && !dataBaseErrors.isEmpty()) {
      LogFactory.logDatabaseErrors(
        'DMLUtility',
        'deleteRecords',
        dataBaseErrors
      );
    }
    return results;
  }

  /*
   * @purpose     : Method to undelete SObject records
   * @parameter   : records - The SObject records to be undeleted
   * @parameter   : allOrNoneIndicator - Boolean indicator for partial undelete
   * @return      : Database.UndeleteResult[]
   */
  public static Database.UndeleteResult[] unDeleteRecords(
    List<SObject> records,
    Boolean allOrNoneIndicator
  ) {
    Database.UndeleteResult[] results = Database.undelete(
      records,
      allOrNoneIndicator
    );
    List<Database.Error> dataBaseErrors = new List<Database.Error>();
    for (Database.UndeleteResult result : results) {
      if (!result.isSuccess()) {
        Database.Error[] dmlErrors = result.getErrors();
        dataBaseErrors.addAll(dmlErrors);
      }
    }
    if (dataBaseErrors != null && !dataBaseErrors.isEmpty()) {
      LogFactory.logDatabaseErrors(
        'DMLUtility',
        'unDeleteRecords',
        dataBaseErrors
      );
    }
    return results;
  }
}
