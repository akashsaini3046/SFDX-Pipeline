public without sharing class CC_FindARouteController {
  @AuraEnabled
  public static CC_BookingWrapper getBookingWrapper() {
    CC_BookingWrapper bookingWrapper = CC_BookingWrapper.getBookingWrapper();
    return bookingWrapper;
  }

  @AuraEnabled
  public static CC_SoftshipRatingResponse getSoftShipResponse(
    String stringBookingWrapper
  ) {
    CC_SoftshipRatingResponse response = new CC_SoftshipRatingResponse();
    List<CC_SoftshipRatingResponse.Schedules> Schedules = new List<CC_SoftshipRatingResponse.Schedules>();
    CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(
      stringBookingWrapper,
      CC_BookingWrapper.class
    );
    system.debug('bookingwrapper====>' + bookingwrapper);
    bookingWrapper.shipment.listCargo[0].cargoType = 'Container';
    bookingWrapper.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Is_Empty__c = false;
    bookingWrapper.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .containerType = '40DS';
    bookingWrapper.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .containerDesc = '40\' Dry Container';
    bookingWrapper.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Quantity__c = 1.0;
    bookingWrapper.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .commodityDesc = 'Cargo, NOS';
    bookingWrapper.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .commodityCode = System.label.CC_CargoNOS_Code;
    CC_SoftshipRatingRequest ratingRequest = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingwrapper
    );
    System.debug('ratingRequest ' + ratingRequest);
    response = CC_SoftshipRatingReqGenerate.sendRatingRequest(ratingRequest);
    system.debug('---->>>>' + JSON.serialize(response));

    return response;
  }
  @AuraEnabled
  public static List<CC_SoftshipRatingResponse.Schedules> getSchedules(
    String responseString
  ) {
    CC_SoftshipRatingResponse response = (CC_SoftshipRatingResponse) JSON.deserialize(
      responseString,
      CC_SoftshipRatingResponse.class
    );
    List<CC_SoftshipRatingResponse.Schedules> Schedules = new List<CC_SoftshipRatingResponse.Schedules>();
    Schedules = CC_FindARouteHelper.getSchedules(response);
    return Schedules;
  }

  @AuraEnabled
  public static List<Location__c> fetchLocation(String recordId) {
    List<Location__c> listLocation = new List<Location__c>();
    listLocation = LocationDAO.getLocationsByIds(new Set<Id>{ recordId });
    return listLocation;
  }
  @AuraEnabled
  public static List<Location__c> fetchSubLocation(
    String locCode,
    String locType
  ) {
    List<Location__c> listLocation = new List<Location__c>();
    String subLocType = '';
    if (locType == 'PORT') {
      subLocType = 'BERTH';
    }
    if (locType == 'RAIL RAMP') {
      subLocType = 'RAIL';
    }

    listLocation = LocationDAO.getSubLocationsByUNLocCode(locCode, subLocType);
    return listLocation;
  }

  /*
     @AuraEnabled
    public static boolean sendEmail(String stringSchedules, String stringEmail){
        
        try{
            System.debug('nooo');
            System.debug(stringEmail);
            System.debug(stringSchedules);
            List<CC_SoftshipRatingResponse.Schedules> scheduleList = (List<CC_SoftshipRatingResponse.Schedules>) JSON.deserialize(stringSchedules, List<CC_SoftshipRatingResponse.Schedules>.class);
            List<EmailAddress> emails = (List<EmailAddress>) JSON.deserialize(stringEmail, List<EmailAddress>.class);
            System.debug('yessss');
            system.debug(scheduleList);
            system.debug(emails);
            List<String> sendTo= new List<String>();
            for(EmailAddress email : emails){
                sendTo.add(email.emailValue);
            }
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(sendTo);
            mail.setSenderDisplayName('Crowley Routes and Schedules');
            mail.setSubject('Routes and Schedules  From '+scheduleList[0].startLocation+' To '+scheduleList[0].endLocation);
            String body = 'Dear User ';
            String headerstyle = 'style=\"background-color: #2F76FB;\"';
            
            body+='<html><head>';
            body+='<style type=\"text/css\">';
            body+='table, th, td {  border: 1px solid black;  border-collapse: collapse;}';
            body+='td { padding:10px;}';
            body+='</style></head>';
            body+='<h1 style=\"text-align:center;\">Schedule Information</h1><br/><br/>';
            body+='<table align=\"center\">';
            for(Integer j = 0;j<scheduleList.size();j++){
                CC_SoftshipRatingResponse.Schedules schedule=scheduleList[j];
            body+='	<tr>';
            body+='		<th '+headerstyle+'>Origin</th>';
            body+='		<th '+headerstyle+'>Destination</th>';
            body+='		<th '+headerstyle+'>Departure On</th>';
            body+='		<th '+headerstyle+'>Arrival On</th>';
            body+='		<th '+headerstyle+'>Transit Time</th>';
            body+='	</tr>';
            body+='	<tbody>';
            body+='		<tr>';
            body+='			<td>'+schedule.startLocation+'</td>';
            body+='			<td>'+schedule.endLocation+'</td>';						
            body+='			<td>'+schedule.StartDate.Utc+'</td>';
            body+='			<td>'+schedule.EndDate.Utc+'</td>';
            body+='			<td>'+schedule.totalDays+' Days</td>';
            body+='		</tr><br/>';
            
            if(schedule.numberOfStops>0){
                body+='		<tr><th colspan="5">';
                body+='			<b>No of Stops '+schedule.numberOfStops+'</b>';
                body+='		</th></tr>';
                body+='		<tr>';
                body+='			<th>Port</th>';
                body+='			<th>Vessel Name/Transport Mode</th>';
                body+='			<th>Voyage Number</th>';
                body+='			<th>Arrival On</th>';
                body+='			<th>Departure On</th>';
                body+='		</tr>';
                integer i=0;
                for(CC_SoftshipRatingResponse.Segments segment : schedule.Segments){
                    if(i>0){
                        body+='		<tr>';
                        if(segment.FromSubDisplayName != null){
                            body+='			<td>'+segment.FromSubDisplayName+' '+segment.FromLocation.Code+'</td>';
                        }else{
                            body+='			<td>'+segment.Leg.StartPosition.DisplayName+' '+segment.FromLocation.Code+'</td>';
                        }
                        if(segment.IsOcean){
                            
                            body+='			<td>'+segment.VesselCode.Code+'</td>';						
                            body+='			<td>'+segment.VoyageNumber.NumberX+'</td>';
                            body+='			<td>'+segment.arrivalToDisplay+'</td>';
                            body+='			<td>'+segment.FromX.Berths[0].Departure.Utc+'</td>';
                        }else{
                            body+='			<td>'+segment.TransportModeCode.Code+'</td>';						
                            body+='			<td></td>';
                            body+='			<td>'+segment.arrivalToDisplay+'</td>';
                            body+='			<td>'+segment.DepartureTime.Utc+'</td>';
                        }
                        body+='		</tr>';
                    }
                    i++;
                }
            }
            body+='	</tbody>';
            }
            body+='	</table>';
            body+='	</html>';
            
            mail.setHtmlBody(body);
            mails.add(mail);
            
            Messaging.sendEmail(mails);
            
        }
        catch(Exception ex){
            System.debug(ex.getLineNumber()+'  '+ex.getMessage());
            LogFactory.error('CC_FindARouteController', 'sendEmail' , 'ERROR', ex.getLineNumber()+'  '+ex.getMessage());
            LogFactory.saveLog();
            return false;    
        }  
        return true;
    } */

  @AuraEnabled
  public static boolean sendEmail(String stringEmail, String quoteId) {
    try {
      List<EmailAddress> emails = (List<EmailAddress>) JSON.deserialize(
        stringEmail,
        List<EmailAddress>.class
      );
      Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
      String noReplyCustomLabel = System.Label.From_Email_Address_for_Quote_Summary;
      String emailTemplateName = System.Label.Quote_Summary_Email_Template_Name;
      OrgWideEmailAddress crowleyNoReply = [
        SELECT Id, Address
        FROM OrgWideEmailAddress
        WHERE Displayname = :noReplyCustomLabel
        LIMIT 1
      ];
      EmailTemplate template = [
        SELECT id, Subject, HtmlValue, Body
        FROM EmailTemplate
        WHERE name = 'CC_RouteFinder'
      ];
      String subject = template.Subject;
      String htmlBody = template.HtmlValue;
      String plainBody = template.Body;
      List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
      System.debug(UserInfo.getUserId());
      /*Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.myPartition');
            sessionPartition.put('schedules', stringSchedules);
            sessionPartition.put('booking', bookingString); */
      Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
      PageReference pref = page.RouteSchedulesPDF;
      pref.getParameters().put('Id', quoteId);
      Blob b;
      if (Test.isRunningTest()) {
        b = blob.valueOf('Unit.Test');
      } else {
        b = pref.getContentAsPDF();
      }
      attach.setFileName('Schedule' + '.pdf');
      attach.setBody(b);
      attachments.add(attach);

      //semail.setSenderDisplayName('Crowley');
      semail.setSubject(subject);
      semail.setHtmlBody(htmlBody);
      semail.setPlainTextBody(plainBody);
      semail.setUseSignature(false);
      semail.setOrgWideEmailAddressId(crowleyNoReply.id);
      semail.setTreatTargetObjectAsRecipient(false);
      semail.setTargetObjectId(UserInfo.getUserId());
      List<String> sendTo = new List<String>();
      for (EmailAddress email : emails) {
        sendTo.add(email.emailValue);
      }
      semail.setToAddresses(sendTo);
      semail.setFileAttachments(attachments);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ semail });
      System.debug('end of try');
    } catch (Exception ex) {
      System.debug(ex.getLineNumber() + '  ' + ex.getMessage());
      return false;
    }
    return true;
  }

  @AuraEnabled
  public static Boolean getIsOpenCommunity() {
    String communityName = CommonUtility.getCommunityName();
    if (communityName == System.Label.OpenCommunityName) {
      return true;
    }
    return false;
  }
  public class EmailAddress {
    @AuraEnabled
    public string emailValue { get; set; }
  }
  @AuraEnabled
  public static String createRouteRecord(
    String stringSchedules,
    String bookingString
  ) {
    Log__c route = new Log__c();
    route.ScheduleWrapper__c = stringSchedules;
    route.StringBooking__c = bookingString;
    insert route;
    return route.Id;
  }
}
