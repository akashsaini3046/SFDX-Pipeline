/*
 * Name: SendEmailToPricingTeamController
 * Purpose: Controller class for Email Sent Functionality For Pricing Quote On Click of Send Email button.
 * Author: Nagarro
 * Created Date: 11-April-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */

public class SendEmailToPricingTeamController {
  public Opportunity opportunity { get; set; }
  public Contact conForEmail;
  public Boolean emailMessageSent { get; set; }

  public SendEmailToPricingTeamController(
    ApexPages.StandardController controller
  ) {
    opportunity = (Opportunity) controller.getRecord();
    emailMessageSent = false;
  }

  /*
   * Method Name: sendEmail
   * Purpose: Sending Email to Pricing team
   */

  //Email is sent to the pricing team on click of Send Email button
  public void sendEmail() {
    try {
      conForEmail = [
        SELECT Id, Name
        FROM Contact
        WHERE
          AccountId IN (
            SELECT AccountId
            FROM Opportunity
            WHERE Id = :opportunity.Id
          )
        LIMIT 1
      ];
      List<String> emailAddressesList;
      if (opportunity.PricingTeamEmailPicklist__c != null) {
        emailAddressesList = new List<String>();
        emailAddressesList = opportunity.PricingTeamEmailPicklist__c.split(';');

        if (emailAddressesList != null && !emailAddressesList.isEmpty()) {
          EmailTemplate emailTemplate = [
            SELECT id, Name
            FROM EmailTemplate
            WHERE DeveloperName = 'Request_For_Quote_Generation'
            LIMIT 1
          ];
          Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
          singleEmail.setWhatId(opportunity.Id);
          singleEmail.setTemplateID(emailTemplate.Id);
          singleEmail.setToAddresses(emailAddressesList);
          singleEmail.setTargetObjectId(conForEmail.Id);
          singleEmail.saveAsActivity = true;
          singleEmail.setTreatTargetObjectAsRecipient(false);

          if (singleEmail != null) {
            String customLabelValue;
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(
              new List<Messaging.SingleEmailMessage>{ singleEmail }
            );
            if (results != null && !results.isEmpty() && results[0].success) {
              emailMessageSent = true;
              customLabelValue = System.Label.SentEmailMessageSuccess;
            } else
              customLabelValue = System.Label.SentEmailMessageFailure;

            if (customLabelValue != null) {
              if (emailMessageSent)
                ApexPages.addMessage(
                  new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    customLabelValue
                  )
                );
              else
                ApexPages.addMessage(
                  new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    customLabelValue
                  )
                );
            }
          }
        }
      }
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Email exception' + e.getMessage()
        )
      );
    }
  }
  /*
   * Method Name: redirect
   * Purpose: For redirecting page back to Opportunity detail page after the email is sent
   */
  public pagereference redirect() {
    PageReference pageRef = new PageReference('/' + opportunity.Id);
    pageRef.setRedirect(true);
    return pageRef;
  }
}
