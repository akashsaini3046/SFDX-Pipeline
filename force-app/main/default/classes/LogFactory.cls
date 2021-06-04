/*
 * 26-06-2020 – Drupad Preeenja – Created this class for Logging various kind of information.
 *
 */

/*
 * @company        : Nagarro Inc.
 * @date           : 26-06-2020
 * @author         : Nagarro
 * @description    : To log the information and to track any error if occurred
 * @history        : Version 1.0
 * @test class     : LogFactoryTest
 */
public class LogFactory {
  // Final String constants for the Error and Info Type
  private static final String TYPE_ERROR = 'ERROR';
  private static final String TYPE_INFO = 'INFO';

  // Getter and Setter for the list of the Log records created in a transaction
  private static List<Log__c> allLogs {
    get {
      if (allLogs == null) {
        allLogs = new List<Log__c>();
      }
      return allLogs;
    }
    set;
  }

  /*
   * @purpose      : Method to create a Log record with type ERROR
   * @parameter    : sourceClass - Name of the class where the error originated
   * @parameter    : sourceMethod - Name of the method where the error originated
   * @parameter    : title - Title for the error
   * @parameter    : message - Output message containing information related to the error (Stacktrace, Message etc.)
   * @return       : void
   */
  public static void error(
    String sourceClass,
    String sourceMethod,
    String title,
    String message
  ) {
    newLog(TYPE_ERROR, sourceClass, sourceMethod, title, message);
  }

  /*
   * @purpose      : Method to create a Log record with type INFO
   * @parameter    : sourceClass - Name of the class where the logging of info is performed
   * @parameter    : sourceMethod - Name of the methodwhere the logging of info is performed
   * @parameter    : title - Title for the information
   * @parameter    : message - Output message containing information which is to be logged
   * @return       : void
   */
  public static void info(
    String sourceClass,
    String sourceMethod,
    String title,
    String message
  ) {
    newLog(TYPE_INFO, sourceClass, sourceMethod, title, message);
  }

  /*
   * @purpose      : Method to upsert all the Log records created in the transaction and re initializing the allLogs variable for new logs.
   * @return       : void
   */
  public static void saveLog() {
    if (allLogs != null && !allLogs.isEmpty()) {
      upsert allLogs;
      allLogs.clear();
      allLogs = new List<Log__c>();
    }
  }

  /*
   * @purpose      : Method to create a Log record with level type as INFO or Error and to add the record to the allLogs variable
   * @parameter    : level - Level of the information log wheather it is an ERROR or INFO
   * @parameter    : sourceClass - Name of the class where the logging is performed
   * @parameter    : sourceMethod - Name of the methodwhere the logging is performed
   * @parameter    : title - Title for the information
   * @parameter    : message - Output message containing information which is to be logged
   * @return       : void
   */
  private static void newLog(
    String level,
    String sourceClass,
    String sourceMethod,
    String title,
    String message
  ) {
    Log__c logItem = new Log__c(
      Level__c = level,
      Source_class__c = sourceClass,
      Source_method__c = sourceMethod,
      Title__c = String.isNotBlank(title) && title.length() > 255
        ? title.substring(0, 255)
        : title,
      Description__c = message
    );
    allLogs.add(logItem);
  }

  /*
   * @purpose      : Method to upsert all the Logs in future.
   * @parameter    : level - Level of the information log wheather it is an ERROR or INFO
   * @parameter    : sourceClass - Name of the class where the logging is performed
   * @parameter    : sourceMethod - Name of the method where the logging is performed
   * @parameter    : messages - List of string of messages to be logged
   * @return       : void
   */
  @future
  public static void saveLogFuture(
    String level,
    String sourceClass,
    String sourceMethod,
    List<String> messages
  ) {
    for (String message : messages) {
      newLog(
        level,
        sourceClass,
        sourceMethod,
        sourceClass +
        ' : ' +
        sourceMethod,
        message
      );
    }
    saveLog();
  }

  /*
   * @purpose      : Method to create log records for the List of Database Errors.
   * @parameter    : sourceClass - Name of the class where the logging is performed
   * @parameter    : sourceMethod - Name of the methodwhere the logging is performed
   * @parameter    : error - list of Database error instances
   * @return       : void
   */
  public static void logDatabaseErrors(
    String sourceClass,
    String sourceMethod,
    List<Database.Error> errors
  ) {
    List<String> messages = new List<String>();
    for (Database.Error err : errors) {
      messages.add(
        err.getStatusCode() +
        ' : ' +
        err.getMessage() +
        ' : ' +
        err.getFields()
      );
    }
    saveLogFuture(TYPE_ERROR, sourceClass, sourceMethod, messages);
  }
}
