public without sharing class ContractNotificationFomApex {
  public static void notifyUsers(
    Set<String> recipientsIds,
    String targetId,
    String accName
  ) {
    // Get the Id for our custom notification type
    CustomNotificationType notificationType = [
      SELECT Id, DeveloperName
      FROM CustomNotificationType
      WHERE DeveloperName = 'Contracts_Notification'
    ];

    // Create a new custom notification
    Messaging.CustomNotification notification = new Messaging.CustomNotification();

    // Set the contents for the notification
    notification.setTitle('Contract Notification');
    notification.setBody(
      'Contract Out for Signature to the customer ' + accName
    );

    // Set the notification type and target
    notification.setNotificationTypeId(notificationType.Id);
    notification.setTargetId(targetId);

    // Actually send the notification
    try {
      notification.send(recipientsIds);
    } catch (Exception e) {
      System.debug('Problem sending notification: ' + e.getMessage());
    }
  }
}
