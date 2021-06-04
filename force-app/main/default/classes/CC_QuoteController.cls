public without sharing class CC_QuoteController {
  @AuraEnabled
  public static CC_BookingWrapper getBookingWrapper() {
    CC_BookingWrapper bookingWrapper = CC_BookingWrapper.getBookingWrapper();
    return bookingWrapper;
  }

  @AuraEnabled(continuation=true cacheable=true)
  public static object getRates(String stringWrapperRequest) {
    Continuation continuationObject = new Continuation(50);
    continuationObject.continuationMethod = 'processRatingResponse';

    CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(
      stringWrapperRequest,
      CC_BookingWrapper.class
    );
    system.debug('bookingwrapper---->>>>' + JSON.serialize(bookingwrapper));
    if (bookingWrapper.shipmentMap.get('CONTAINER').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('CONTAINER');
    }
    if (bookingWrapper.shipmentMap.get('VEHICLE').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('VEHICLE');
    }
    if (bookingWrapper.shipmentMap.get('BREAKBULK').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('BREAKBULK');
    }
    CC_SoftshipRatingRequest ratingRequest = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingwrapper
    );
    System.debug('ratingRequest111--->' + ratingRequest);
    String requestBody = JSON.serialize(ratingRequest, true);
    System.debug('requestBody--->' + requestBody);
    System.debug(
      'service value---> ' + CC_SoftshipRatingConstant.FINDAROUTEPOST
    );

    HttpRequest ratingHTTPRequest = APICalloutUtility.createContinuationAPIRequest(
      CC_SoftshipRatingConstant.FINDAROUTEPOST,
      requestBody,
      null,
      ''
    );
    System.debug('ratingRequest222--->' + ratingHTTPRequest);
    continuationObject.addHttpRequest(ratingHTTPRequest);
    //continuationObject.state=ratingHTTPRequest;
    return continuationObject;
  }

  @AuraEnabled(cacheable=true)
  public static CC_SoftshipRatingResponse processRatingResponse(
    List<String> labels,
    Object state
  ) {
    System.debug('labels----> ' + labels);
    System.debug('State----> ' + state);
    String responseString = '';
    CC_SoftshipRatingResponse responseWrapper = new CC_SoftshipRatingResponse();
    try {
      HttpResponse response = Continuation.getResponse(labels[0]);
      if (
        response.getStatusCode() >= 2000 &&
        response.getStatusCode() <= 2004
      ) {
        responseWrapper.success = false;
        responseWrapper.isTimeoutError = true;
        return responseWrapper;
      }
      System.debug('response--->' + response);
      System.debug(response.getBody());
      responseString = response.getBody();
      responseString = responseString.replace('"Number":', '"NumberX":');
      responseString = responseString.replace('"From":', '"FromX":');
      responseWrapper = (CC_SoftshipRatingResponse) JSON.deserialize(
        responseString,
        CC_SoftshipRatingResponse.class
      );
      System.debug('responseWrapper--->' + responseWrapper);
    } catch (JSONException e) {
      Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
        responseString
      );
      if (
        !(Boolean) response.get('success') &&
        response.get('result') != null &&
        (String) response.get('result') != ''
      ) {
        String message = (String) response.get('result');
        responseWrapper.success = false;
        responseWrapper.errorMessage = message;
      }
    } catch (Exception e) {
      responseWrapper.success = false;
    }
    return responseWrapper;
  }

  @AuraEnabled
  public static void createCaseAndNotify(
    String bookingWrapperString,
    String responseString,
    String selectedRoutesList,
    String rateMapping
  ) {
    try {
      sendNotificationEmail(
        System.Label.Email_Notification_Rating_Server_Down,
        bookingWrapperString,
        responseString,
        rateMapping
      );
    } catch (Exception ex) {
      LogFactory.error(
        'CC_QuoteController',
        'createCaseAndNotify',
        'Sending Email',
        'Line Number : ' +
        ex.getLineNumber() +
        ' Message : ' +
        ex.getMessage() +
        ' Stack Trace :' +
        ex.getStackTraceString()
      );
    }
    LogFactory.saveLog();
  }

  public static void sendNotificationEmail(
    String emailAddresses,
    String bookingWrapperString,
    String responseString,
    String rateMapping
  ) {
    CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(
      bookingWrapperString,
      CC_BookingWrapper.class
    );
    String cargoType = '';
    if (bookingWrapper.shipmentMap.get('CONTAINER').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('CONTAINER');
      cargoType = 'CONTAINER';
    }
    if (bookingWrapper.shipmentMap.get('VEHICLE').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('VEHICLE');
      cargoType = 'VEHICLE';
    }
    if (bookingWrapper.shipmentMap.get('BREAKBULK').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('BREAKBULK');
      cargoType = 'BREAKBULK';
    }
    CC_SoftshipRatingRequest ratingRequest = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingwrapper
    );
    String requestBody = JSON.serializePretty(ratingRequest, true);
    Map<String, String> originDestination = getOriginDestination(
      bookingwrapper
    );
    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    String subject = System.Label.Notification_Server_Down_Email_Subject;
    String htmlBody = '<html>';
    htmlBody += 'Hi Admins,<br/><br/>';
    htmlBody +=
      'Environment : <b> ' +
      URL.getSalesforceBaseUrl().getHost() +
      ' </b><br/>';
    htmlBody +=
      'Origin : <b> ' +
      originDestination.get('origin') +
      ' </b><br/>';
    htmlBody +=
      'Destination : <b> ' +
      originDestination.get('destination') +
      ' </b><br/>';
    htmlBody +=
      'Requested By : <b> ' +
      bookingwrapper.booking.Customer_Email__c +
      ' </b><br/>';
    htmlBody += 'Cargo Type : <b> ' + cargoType + ' </b><br/>';
    htmlBody +=
      'Cargo Ready Date : <b> ' +
      bookingWrapper.booking.Ready_Date__c.format() +
      ' </b><br/>';
    Map<String, String> jsonValues = new Map<String, String>();
    List<Object> rateMappings = (List<Object>) JSON.deserializeUntyped(
      rateMapping
    );
    if (rateMappings != null && !rateMappings.isEmpty()) {
      htmlBody += 'Cargo Details : <br/>';
      htmlBody += '<table style="border: 1px solid #636363;"><tr><th style="border: 1px solid #636363;">Items</th><th style="border: 1px solid #636363;">Quantity</th></tr>';
      for (Object obj : rateMappings) {
        Map<String, Object> rateMap = (Map<String, Object>) obj;
        htmlBody +=
          '<tr><td style="border: 1px solid #636363;">' +
          String.valueOf(rateMap.get('containerName')).replace('___', ' (') +
          ')</td><td style="border: 1px solid #636363;">' +
          String.valueOf(rateMap.get('quantity')) +
          '</td></tr>';
      }
      htmlBody += '</table><br/>';
    }
    htmlBody += 'JSON Request : <b> ' + requestBody + ' </b><br/>';
    htmlBody += '<br/><br/>Thanks<br/>Veloz Team</html>';

    semail.setSubject(subject);
    semail.setHtmlBody(htmlBody);
    List<String> emailsAddrs = emailAddresses.split(';');
    String[] emailAddressArray = new List<String>(emailsAddrs.size());
    for (Integer i = 0; i < emailsAddrs.size(); i++) {
      emailAddressArray[i] = emailsAddrs.get(i);
    }
    String[] sendTo = emailAddressArray;
    semail.setToAddresses(sendTo);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ semail });
  }

  private static Map<String, String> getOriginDestination(
    CC_BookingWrapper bookingwrapper
  ) {
    String Origin = '', Destination = '';
    if (
      bookingwrapper.booking.Description__c != null &&
      bookingwrapper.booking.Description__c != ''
    ) {
      if (
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.PORT_TO_PORT
        ) ||
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.RAIL_TO_PORT
        ) ||
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.PORT_TO_RAIL
        ) ||
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.RAIL_TO_RAIL
        )
      ) {
        String OriginRailorPort = bookingwrapper.booking.Description__c.contains(
            CC_Constants.PORT_TO_PORT
          ) ||
          bookingwrapper.booking.Description__c.contains(
            CC_Constants.PORT_TO_RAIL
          )
          ? CC_Constants.ORIGIN_PORT
          : CC_Constants.ORIGIN_RAIL;
        String originCode = bookingwrapper.booking.Customer_Origin_Code__c !=
          null
          ? bookingwrapper.booking.Customer_Origin_Code__c
          : '';
        Origin = OriginRailorPort + ' : ' + Origincode + '\n';
        String DestRailorPort = bookingwrapper.booking.Description__c.contains(
            CC_Constants.PORT_TO_PORT
          ) ||
          bookingwrapper.booking.Description__c.contains(
            CC_Constants.RAIL_TO_PORT
          )
          ? CC_Constants.DESTINATION_PORT
          : CC_Constants.DESTINATION_RAIL;
        String destCode = bookingwrapper.booking.Customer_Destination_Code__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_Code__c
          : '';
        Destination = DestRailorPort + ' : ' + destCode + '\n';
      } else if (
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.DOOR_TO_DOOR
        )
      ) {
        String oCity = bookingwrapper.booking.Customer_Origin_City__c != null
          ? bookingwrapper.booking.Customer_Origin_City__c
          : '';
        String oState = bookingwrapper.booking.Customer_Origin_State__c != null
          ? bookingwrapper.booking.Customer_Origin_State__c
          : '';
        String oCountry = bookingwrapper.booking.Customer_Origin_Country__c !=
          null
          ? bookingwrapper.booking.Customer_Origin_Country__c
          : '';
        String oZip = bookingwrapper.booking.Customer_Origin_Zip__c != null
          ? bookingwrapper.booking.Customer_Origin_Zip__c
          : '';
        Origin =
          CC_Constants.ORIGIN +
          ' : ' +
          oCity +
          ' ' +
          oState +
          ' ' +
          oCountry +
          ' ' +
          oZip +
          '\n';
        String dCity = bookingwrapper.booking.Customer_Destination_City__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_City__c
          : '';
        String dState = bookingwrapper.booking.Customer_Destination_State__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_State__c
          : '';
        String dCountry = bookingwrapper.booking.Customer_Destination_Country__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_Country__c
          : '';
        String dZip = bookingwrapper.booking.Customer_Destination_Zip__c != null
          ? bookingwrapper.booking.Customer_Destination_Zip__c
          : '';
        Destination =
          CC_Constants.DESTINATION +
          ' : ' +
          dCity +
          ' ' +
          dState +
          ' ' +
          dCountry +
          ' ' +
          dZip +
          '\n';
      } else if (
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.DOOR_TO_PORT
        ) ||
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.DOOR_TO_RAIL
        )
      ) {
        String oCity = bookingwrapper.booking.Customer_Origin_City__c != null
          ? bookingwrapper.booking.Customer_Origin_City__c
          : '';
        String oState = bookingwrapper.booking.Customer_Origin_State__c != null
          ? bookingwrapper.booking.Customer_Origin_State__c
          : '';
        String oCountry = bookingwrapper.booking.Customer_Origin_Country__c !=
          null
          ? bookingwrapper.booking.Customer_Origin_Country__c
          : '';
        String oZip = bookingwrapper.booking.Customer_Origin_Zip__c != null
          ? bookingwrapper.booking.Customer_Origin_Zip__c
          : '';
        Origin =
          CC_Constants.ORIGIN +
          ' : ' +
          oCity +
          ' ' +
          oState +
          ' ' +
          oCountry +
          ' ' +
          oZip +
          '\n';
        String destCode = bookingwrapper.booking.Customer_Destination_Code__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_Code__c
          : '';
        String PortorRail = bookingwrapper.booking.Description__c.contains(
            CC_Constants.DOOR_TO_PORT
          )
          ? CC_Constants.DESTINATION_PORT
          : CC_Constants.DESTINATION_RAIL;
        Destination = PortorRail + ' : ' + destCode + '\n';
      } else if (
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.PORT_TO_DOOR
        ) ||
        bookingwrapper.booking.Description__c.contains(
          CC_Constants.RAIL_TO_DOOR
        )
      ) {
        String PortorRail = bookingwrapper.booking.Description__c.contains(
            CC_Constants.PORT_TO_DOOR
          )
          ? CC_Constants.ORIGIN_PORT
          : CC_Constants.ORIGIN_RAIL;
        String originCode = bookingwrapper.booking.Customer_Origin_Code__c !=
          null
          ? bookingwrapper.booking.Customer_Origin_Code__c
          : '';
        Origin = PortorRail + ' : ' + Origincode + '\n';
        String dCity = bookingwrapper.booking.Customer_Destination_City__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_City__c
          : '';
        String dState = bookingwrapper.booking.Customer_Destination_State__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_State__c
          : '';
        String dCountry = bookingwrapper.booking.Customer_Destination_Country__c !=
          null
          ? bookingwrapper.booking.Customer_Destination_Country__c
          : '';
        String dZip = bookingwrapper.booking.Customer_Destination_Zip__c != null
          ? bookingwrapper.booking.Customer_Destination_Zip__c
          : '';
        Destination =
          CC_Constants.DESTINATION +
          ' : ' +
          dCity +
          ' ' +
          dState +
          ' ' +
          dCountry +
          ' ' +
          dZip +
          '\n';
      }
    }
    return new Map<String, String>{
      'origin' => Origin,
      'destination' => Destination
    };
  }

  @AuraEnabled
  public static CC_BookingWrapper submitQuote(
    String stringWrapperRequest,
    String softshipRatingResponseString,
    String selectedRoutesList,
    String rateMapping
  ) {
    System.debug('print routeList----> ' + selectedRoutesList);
    System.debug('print Mapping----> ' + rateMapping);

    CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(
      stringWrapperRequest,
      CC_BookingWrapper.class
    );
    CC_SoftshipRatingResponse ratingResponse = (CC_SoftshipRatingResponse) JSON.deserialize(
      softshipRatingResponseString,
      CC_SoftshipRatingResponse.class
    );

    system.debug('bookingwrapper---->>>>' + JSON.serialize(bookingwrapper));
    try {
      bookingwrapper.isError = false;
      bookingwrapper.errorMessage = '';
      if (
        ratingResponse != null &&
        ratingResponse.success &&
        ratingResponse.result != null &&
        ratingResponse.result.size() > 0
      ) {
        bookingwrapper = createQuoteWithChargeLines(
          bookingwrapper,
          ratingResponse,
          selectedRoutesList,
          rateMapping
        );
        System.debug(bookingwrapper);
        for (Quote__c createdQuote : bookingWrapper.listQuote) {
          setVoyageData(bookingwrapper, createdQuote, ratingResponse);
          createChildRecords(bookingwrapper, createdQuote);
        }
      } else {
        Quote__c quote = createQuoteData(bookingwrapper);
        system.debug('quote---->>>>' + JSON.serialize(quote));
        quote.Pending_Reason__c = 'Unable to retrieve rates at this time, please try again or call the customer help desk for more assistance';
        insert quote;
        Quote__c createdQuote = [
          SELECT Id, Name, Status__c
          FROM Quote__c
          WHERE Id = :quote.Id
          LIMIT 1
        ];
        bookingWrapper.listQuote = new List<Quote__c>{ createdQuote };
        createChildRecords(bookingwrapper, createdQuote);
      }
    } catch (Exception e) {
      bookingwrapper.isError = true;
      bookingwrapper.errorMessage = e.getMessage();
      LogFactory.error(
        'CC_QuoteController',
        'submitQuote',
        'Veloz Get Quote Community',
        e.getLineNumber() +
        ' ' +
        e.getMessage()
      );
      LogFactory.saveLog();
    }
    System.debug(JSON.serialize(bookingwrapper));
    return bookingwrapper;
  }

  public static CC_BookingWrapper setVoyageData(
    CC_BookingWrapper bookingwrapper,
    Quote__c createdQuote,
    CC_SoftshipRatingResponse ratingResponse
  ) {
    List<Voyage__c> listVoyage = new List<Voyage__c>();
    for (CC_SoftshipRatingResponse.result route : ratingResponse.result) {
      if (String.valueOf(route.RouteId) == createdQuote.Route_Id__c) {
        for (CC_SoftshipRatingResponse.Schedules schedule : route.Schedules) {
          for (CC_SoftshipRatingResponse.Segments segment : schedule.Segments) {
            if (segment.IsOcean) {
              Voyage__c voyage = new Voyage__c();
              voyage.Vessel_Name__c = segment.VesselName;
              voyage.Voyage_Number__c = segment.VoyageNumber.NumberX;
              voyage.Loading_Location_Code__c = segment.FromLocation.Code;
              voyage.Discharge_Location_Code__c = segment.ToLocation.Code;
              voyage.Estimate_Sail_Date__c = Date.valueOf(
                schedule.StartSailingDate.LocalPortTime
              );
              voyage.Estimate_Arrival_Date__c = Date.valueOf(
                schedule.EndSailingDate.LocalPortTime
              );
              listVoyage.add(voyage);
            }
          }
        }
      }
    }
    bookingWrapper.shipmentMap.get('CONTAINER').listVogage.clear();
    bookingWrapper.shipmentMap.get('CONTAINER').listVogage.addAll(listVoyage);
    bookingWrapper.shipmentMap.get('VEHICLE').listVogage.clear();
    bookingWrapper.shipmentMap.get('VEHICLE').listVogage.addAll(listVoyage);
    bookingWrapper.shipmentMap.get('BREAKBULK').listVogage.clear();
    bookingWrapper.shipmentMap.get('BREAKBULK').listVogage.addAll(listVoyage);
    system.debug('--->>>' + bookingWrapper);
    return bookingwrapper;
  }

  public static CC_BookingWrapper createChildRecords(
    CC_BookingWrapper bookingwrapper,
    Quote__c createdQuote
  ) {
    if (bookingWrapper.shipmentMap.get('CONTAINER').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('CONTAINER');
    }
    if (bookingWrapper.shipmentMap.get('VEHICLE').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('VEHICLE');
    }
    if (bookingWrapper.shipmentMap.get('BREAKBULK').isSelected) {
      bookingWrapper.shipment = bookingWrapper.shipmentMap.get('BREAKBULK');
    }

    bookingWrapper.shipment.shipment = createShipmentRecord(
      bookingwrapper,
      createdQuote
    );
    for (Voyage__c voyage : bookingWrapper.shipment.listVogage) {
      voyage.Id = null;
      voyage.Shipment__c = bookingWrapper.shipment.shipment.Id;
      voyage.Name = createdQuote.Name + '-' + voyage.Voyage_Number__c;
    }
    insert bookingWrapper.shipment.listVogage;
    createFreightRecord(bookingWrapper, createdQuote.Name);
    createRequirementAndCommodities(
      bookingWrapper,
      createdQuote.Name,
      bookingwrapper.shipment.listCargo[0].cargoType
    );
    return bookingwrapper;
  }

  public static Quote__c createQuoteData(CC_BookingWrapper bookingwrapper) {
    Booking__c booking = bookingwrapper.booking;
    Quote__c newQuote = new Quote__c();
    newQuote.Account__c = booking.Account__c;
    newQuote.Status__c = 'Sent to Pricing';
    newQuote.Quote_Type__c = 'FCL';
    newQuote.Additional_Information__c = booking.Additional_Information__c;
    newQuote.Company_Name__c = booking.Company_Name__c;
    newQuote.Contact__c = booking.Contact__c;
    newQuote.Contract__c = booking.Contract__c;
    newQuote.Contact_Name__c = booking.Contact_Name__c;
    newQuote.Contact_Number__c = booking.Contact_Number__c;
    newQuote.Contract_Number__c = booking.Contract_Number__c;
    newQuote.Customer_Destination_City__c = booking.Customer_Destination_City__c;
    newQuote.Customer_Destination_Code__c = booking.Customer_Destination_Code__c;
    newQuote.Customer_Destination_Country__c = booking.Customer_Destination_Country__c;
    newQuote.Customer_Destination_State__c = booking.Customer_Destination_State__c;
    newQuote.Customer_Destination_Zip__c = booking.Customer_Destination_Zip__c;
    newQuote.Customer_Email__c = booking.Customer_Email__c;
    newQuote.Customer_Origin_City__c = booking.Customer_Origin_City__c;
    newQuote.Customer_Origin_Code__c = booking.Customer_Origin_Code__c;
    newQuote.Customer_Origin_Country__c = booking.Customer_Origin_Country__c;
    newQuote.Customer_Origin_State__c = booking.Customer_Origin_State__c;
    newQuote.Customer_Origin_Zip__c = booking.Customer_Origin_Zip__c;
    newQuote.Description__c = booking.Description__c;
    newQuote.Destination_Drayage__c = booking.Destination_Drayage__c;
    newQuote.Destination_Type__c = booking.Destination_Type__c;
    newQuote.Port_of_Load__c = booking.Port_of_Load__c;
    newQuote.Port_of_Discharge__c = booking.Port_of_Discharge__c;
    newQuote.Is_Hazardous__c = booking.Is_Hazardous__c;
    newQuote.Origin_Drayage__c = booking.Origin_Drayage__c;
    newQuote.Origin_Type__c = booking.Origin_Type__c;
    //newQuote.Pending_Reason__c = booking.Pending_Reason__c;
    newQuote.Ready_Date__c = booking.Ready_Date__c;
    //newQuote.Total_Amount__c = booking.Total_Amount__c;
    //newQuote.Transit_Time__c = booking.Transit_Time__c;
    newQuote.Transportation_Management_System_Destina__c = booking.Transportation_Management_System_Destina__c;
    newQuote.Transportation_Management_System_Origin__c = booking.Transportation_Management_System_Origin__c;

    return newQuote;
  }

  public static CC_BookingWrapper createQuoteWithChargeLines(
    CC_BookingWrapper bookingwrapper,
    CC_SoftshipRatingResponse ratingResponse,
    String selectedRoutesList,
    String rateMapping
  ) {
    system.debug('-->>>' + selectedRoutesList);
    system.debug('-->>>' + rateMapping);
    List<Charge_Line__c> chargeLines = new List<Charge_Line__c>();
    List<Object> rateMappings = (List<Object>) JSON.deserializeUntyped(
      rateMapping
    );
    List<Object> selectedRoutes = (List<Object>) JSON.deserializeUntyped(
      selectedRoutesList
    );
    Map<String, Quote__c> routeIdVsQuoteRecord = new Map<String, Quote__c>();
    Map<String, CC_SoftshipRatingResponse.ValuesGroup> routIdVsDocValueData = new Map<String, CC_SoftshipRatingResponse.ValuesGroup>();
    Map<String, Decimal> routIdVsDuration = new Map<String, Decimal>();
    Map<String, Decimal> routIdVsDurationInHours = new Map<String, Decimal>();
    Map<String, Map<String, String>> selectedRouteVsTransModes = new Map<String, Map<String, String>>();
    Integer quantity = 0;
    for (Object obj : rateMappings) {
      Map<String, Object> rateMap = (Map<String, Object>) obj;
      quantity += Integer.valueOf(rateMap.get('quantity'));
    }
    for (Object obj : selectedRoutes) {
      Map<String, Object> routeMap = (Map<String, Object>) obj;
      Map<String, String> jsonValues = new Map<String, String>();
      String btwPortString = String.valueOf(routeMap.get('betweenPortsOnly'));
      System.debug(' btwPortString ' + btwPortString);
      List<Map<String, String>> bwtPort = (List<Map<String, String>>) JSON.deserialize(
        btwPortString,
        List<Map<String, String>>.class
      );
      System.debug('bwtPort');
      System.debug(bwtPort);
      Map<String, String> startLoc = (Map<String, String>) JSON.deserialize(
        String.valueOf(routeMap.get('startLocation')),
        Map<String, String>.class
      );
      Map<String, String> endLoc = (Map<String, String>) JSON.deserialize(
        String.valueOf(routeMap.get('endLocation')),
        Map<String, String>.class
      );
      if (bwtPort.size() == 0) {
        if (
          String.valueOf(startLoc.get('orgDest')) == 'Port' &&
          String.valueOf(endLoc.get('orgDest')) == 'Port'
        ) {
          jsonValues.put(
            'pol',
            String.valueOf(startLoc.get('displayName')) +
            ' (' +
            String.valueOf(startLoc.get('displayCode')) +
            ') '
          );
          jsonValues.put(
            'pod',
            String.valueOf(endLoc.get('displayName')) +
            ' (' +
            String.valueOf(endLoc.get('displayCode')) +
            ') '
          );
        } else {
          jsonValues.put('pol', 'NA');
          jsonValues.put('pod', 'NA');
        }
      }
      if (bwtPort.size() == 2) {
        jsonValues.put(
          'pol',
          String.valueOf(bwtPort[0].get('displayName')) +
          ' (' +
          String.valueOf(bwtPort[0].get('displayCode')) +
          ') '
        );
        jsonValues.put(
          'pod',
          String.valueOf(bwtPort[1].get('displayName')) +
          ' (' +
          String.valueOf(bwtPort[1].get('displayCode')) +
          ') '
        );
      }
      if (bwtPort.size() == 1) {
        if (String.valueOf(startLoc.get('orgDest')) != 'Port') {
          jsonValues.put(
            'pol',
            String.valueOf(bwtPort[0].get('displayName')) +
            ' (' +
            String.valueOf(bwtPort[0].get('displayCode')) +
            ') '
          );
          jsonValues.put(
            'pod',
            String.valueOf(endLoc.get('displayName')) +
            ' (' +
            String.valueOf(endLoc.get('displayCode')) +
            ') '
          );
        } else {
          jsonValues.put(
            'pol',
            String.valueOf(startLoc.get('displayName')) +
            ' (' +
            String.valueOf(startLoc.get('displayCode')) +
            ') '
          );
          jsonValues.put(
            'pod',
            String.valueOf(bwtPort[0].get('displayName')) +
            ' (' +
            String.valueOf(bwtPort[0].get('displayCode')) +
            ') '
          );
        }
      }
      jsonValues.put('routeId', String.valueOf(routeMap.get('routeId')));
      jsonValues.put(
        'startModes',
        String.valueOf(
          routeMap.get('startModes') != null ? routeMap.get('startModes') : ''
        )
      );
      jsonValues.put(
        'endModes',
        String.valueOf(
          routeMap.get('endModes') != null ? routeMap.get('endModes') : ''
        )
      );
      selectedRouteVsTransModes.put(
        String.valueOf(routeMap.get('routeId')),
        jsonValues
      );
    }
    for (CC_SoftshipRatingResponse.result route : ratingResponse.result) {
      System.debug('-->' + route.CalculatedContributionResult.ItemValues);
      if (
        selectedRouteVsTransModes != null &&
        !selectedRouteVsTransModes.isEmpty() &&
        selectedRouteVsTransModes.keySet()
          .contains(String.valueOf(route.RouteId))
      ) {
        if (
          route.CalculatedContributionResult != null &&
          route.CalculatedContributionResult.ItemValues != null &&
          !route.CalculatedContributionResult.ItemValues.isEmpty() &&
          route.CalculatedContributionResult.ItemValues[0].ValuesDataRevenue !=
          null &&
          !route.CalculatedContributionResult.ItemValues[0]
            .ValuesDataRevenue.isEmpty() &&
          route.CalculatedContributionResult.ItemValues[0]
            .ValuesDataRevenue[0]
            .ValuesGroup != null &&
          !route.CalculatedContributionResult.ItemValues[0]
            .ValuesDataRevenue[0]
            .ValuesGroup.isEmpty()
        ) {
          routIdVsDocValueData.put(
            String.valueOf(route.RouteId),
            route.CalculatedContributionResult.ItemValues[0]
              .ValuesDataRevenue[0]
              .ValuesGroup[0]
          );
          System.debug('Key --' + String.valueOf(route.RouteId));
          System.debug(
            'value --' +
            route.CalculatedContributionResult.ItemValues[0]
              .ValuesDataRevenue[0]
              .ValuesGroup[0]
          );
        }
        if (route.Duration != null && route.Duration.AmountInDays != null) {
          routIdVsDuration.put(
            String.valueOf(route.RouteId),
            route.Duration.AmountInDays
          );
        }
        if (route.Duration != null && route.Duration.AmountinHours != null) {
          routIdVsDurationInHours.put(
            String.valueOf(route.RouteId),
            route.Duration.AmountinHours
          );
        }
      }
    }
    if (routIdVsDocValueData != null && !routIdVsDocValueData.isEmpty()) {
      for (String routeId : routIdVsDocValueData.keySet()) {
        Quote__c quote = createQuoteData(bookingwrapper);
        quote.Total_Amount__c = routIdVsDocValueData.get(routeId).TotalSum;
        //quote.Transit_Time__c = CC_FindARouteHelper.getDays(String.valueOf(routIdVsDuration.get(routeId)));
        quote.Transit_Time__c = routIdVsDurationInHours.get(routeId);
        quote.Status__c = 'Active';
        quote.Pending_Reason__c = '';
        quote.Route_Id__c = routeId;
        quote.Vessel_Name__c = '';
        quote.Voyage_Number__c = '';
        //quote.EEI_Charges__c =Decimal.valueOf(System.Label.CC_EEI_Charge);
        //quote.INS_Charge__c =Decimal.valueOf(System.Label.CC_INS_Charge)*quantity;
        for (CC_SoftshipRatingResponse.result route : ratingResponse.result) {
          if (String.valueOf(route.RouteId) == routeId) {
            quote.No_of_Stop__c = String.valueOf(route.Legs.size() - 1);
            for (
              CC_SoftshipRatingResponse.Schedules schedule : route.Schedules
            ) {
              for (
                CC_SoftshipRatingResponse.Segments segment : schedule.Segments
              ) {
                if (segment.IsOcean) {
                  quote.Vessel_Name__c = segment.VesselName;
                  quote.Voyage_Number__c = segment.VoyageNumber.NumberX;
                  break;
                }
              }
            }
          }
        }

        quote.Port_of_Load__c = selectedRouteVsTransModes.get(routeId)
          .get('pol');
        quote.Port_of_Discharge__c = selectedRouteVsTransModes.get(routeId)
          .get('pod');
        String startMode = getTransMode(
          selectedRouteVsTransModes,
          routeId,
          'startModes'
        );
        String endMode = getTransMode(
          selectedRouteVsTransModes,
          routeId,
          'endModes'
        );
        if (startMode != '') {
          quote.Transportation_Management_System_Origin__c = startMode;
        }
        if (endMode != '') {
          quote.Transportation_Management_System_Destina__c = endMode;
        }
        routeIdVsQuoteRecord.put(routeId, quote);
      }
      insert routeIdVsQuoteRecord.values();
      System.debug('Map---> ' + routIdVsDocValueData);

      List<Quote__c> quotes = CC_WithoutSharingUtility.getQuoteWithChargeLineByQuoteIds(
        (new Map<Id, Quote__c>(routeIdVsQuoteRecord.values()).keySet())
      );
      for (String routeId : routIdVsDocValueData.keySet()) {
        System.debug(
          'routIdVsDocValueData-- ' + routIdVsDocValueData.get(routeId)
        );
        chargeLines.addAll(
          createChargeLine(
            routIdVsDocValueData.get(routeId),
            routeIdVsQuoteRecord.get(routeId),
            rateMappings
          )
        );
      }
      System.debug(chargeLines);
      insert chargeLines;
      if (routeIdVsQuoteRecord != null && !routeIdVsQuoteRecord.isEmpty()) {
        System.debug(routeIdVsQuoteRecord);
        bookingwrapper.listQuote = quotes;
      }
    }
    return bookingwrapper;
  }

  private static String getTransMode(
    Map<String, Map<String, String>> selectedRouteVsTransModes,
    String routeId,
    String modeName
  ) {
    String value = selectedRouteVsTransModes.get(routeId).get(modeName);
    if (value.equalsIgnoreCase('MOTOR / RAIL')) {
      return 'M';
    } else if (value.equalsIgnoreCase('ALL MOTOR')) {
      return 'A';
    } else if (value.equalsIgnoreCase('RAIL')) {
      return 'R';
    } else {
      return '';
    }
  }

  @AuraEnabled
  public static void sendQuoteEmail(
    String emailAddress,
    String bookingwrapper
  ) {
    System.debug(bookingwrapper);
    CC_BookingWrapper bookingwrapperDeserial = (CC_BookingWrapper) JSON.deserialize(
      bookingwrapper,
      CC_BookingWrapper.class
    );
    CC_VelozRouteEmailQuoteController.sendEmailToQuotes(
      emailAddress,
      (new Map<Id, Quote__c>(bookingwrapperDeserial.listQuote)).keySet(),
      false
    );
  }

  public static List<Charge_Line__c> createChargeLine(
    CC_SoftshipRatingResponse.ValuesGroup valueGroup,
    Quote__c quote,
    List<Object> rateMapping
  ) {
    System.debug('valuegroup----> ' + valueGroup);
    System.debug('Quote----> ' + quote);
    System.debug('ratemapping----> ' + rateMapping);
    List<Charge_Line__c> chargeLines = new List<Charge_Line__c>();
    Map<String, Object> itemNumberVsObject = new Map<String, Object>();
    Map<String, Map<String, String>> itemNumberVsValues = new Map<String, Map<String, String>>();
    for (Object obj : rateMapping) {
      Map<String, Object> rateMap = (Map<String, Object>) obj;
      Map<String, String> jsonValues = new Map<String, String>();
      jsonValues.put(
        'year',
        rateMap.containsKey('year') ? String.valueOf(rateMap.get('year')) : ''
      );
      jsonValues.put(
        'containerName',
        String.valueOf(rateMap.get('containerName'))
      );
      jsonValues.put('quantity', String.valueOf(rateMap.get('quantity')));
      jsonValues.put(
        'containerCode',
        String.valueOf(rateMap.get('containerCode'))
      );
      itemNumberVsValues.put(
        String.valueOf(rateMap.get('itemNum')),
        jsonValues
      );
      System.debug('JsonValues Map ' + jsonValues);
      System.debug('itemNumberVsValues Map ' + itemNumberVsValues);
    }

    if (
      valueGroup.DocValuesData != null && !valueGroup.DocValuesData.isEmpty()
    ) {
      for (
        CC_SoftshipRatingResponse.DocValuesData docValueData : valueGroup.DocValuesData
      ) {
        Charge_Line__c chargeLine = new Charge_Line__c();
        if (docValueData.ItemNumber > 0) {
          chargeLine.Name =
            itemNumberVsValues.get(String.valueOf(docValueData.ItemNumber))
              .get('containerCode') +
            '-' +
            docValueData.Description;
          System.debug(
            'ItemNumber --- ' + String.valueOf(docValueData.ItemNumber)
          );
          System.debug(
            'itemNumberVsValue ---' +
            itemNumberVsValues.get(String.valueOf(docValueData.ItemNumber))
          );
          System.debug('chargeLine ' + chargeLine);
          chargeLine.Item_Name__c = itemNumberVsValues.get(
              String.valueOf(docValueData.ItemNumber)
            )
            .get('containerName');
          chargeLine.Item_Code__c = itemNumberVsValues.get(
              String.valueOf(docValueData.ItemNumber)
            )
            .get('containerCode');
          chargeLine.Quantity__c = Decimal.valueOf(
            itemNumberVsValues.get(String.valueOf(docValueData.ItemNumber))
              .get('quantity')
          );
          chargeLine.Item_Sequence__c = String.valueOf(docValueData.ItemNumber);
          chargeLine.Item_Year__c = itemNumberVsValues.get(
              String.valueOf(docValueData.ItemNumber)
            )
            .get('year');
        } else {
          chargeLine.Name = 'Others ' + docValueData.Description;
          chargeLine.Item_Sequence__c = String.valueOf(docValueData.ItemNumber);
          chargeLine.Item_Code__c = 'ExtraCharge';
          chargeLine.Item_Name__c = 'Extra Charge';
        }
        chargeLine.Amount_Target__c = docValueData.AmountTarget;
        chargeLine.Basis__c = String.valueOf(docValueData.Basis);
        chargeLine.Charge_Code__c = docValueData.ChargeCode;
        chargeLine.Rate__c = docValueData.Rate;
        chargeLine.Quote__c = quote.Id;
        chargeLine.ChargeDescription__c = docValueData.Description;
        chargeLines.add(chargeLine);
      }
    }
    return chargeLines;
  }

  public static Shipment__c createShipmentRecord(
    CC_BookingWrapper bookingwrapper,
    Quote__c quote
  ) {
    Booking__c booking = bookingwrapper.booking;
    Shipment__c shipment = bookingwrapper.shipment.shipment;
    shipment.id = null;
    shipment.Shipment_Number__c = '001';
    shipment.Name = quote.Name + '-001';
    shipment.Quote__c = quote.Id;

    shipment.Origin_Port__c = booking.Customer_Origin_Code__c;
    shipment.Origin_Code__c = booking.Customer_Origin_Code__c;
    shipment.Origin_City__c = booking.Customer_Origin_City__c;
    shipment.Origin_Country__c = booking.Customer_Origin_Country__c;
    shipment.Origin_Zip__c = booking.Customer_Origin_Zip__c;
    shipment.Origin_State__c = booking.Customer_Origin_State__c;

    shipment.Destination_Port__c = booking.Customer_Destination_Code__c;
    shipment.Destination_Code__c = booking.Customer_Destination_Code__c;
    shipment.Destination_City__c = booking.Customer_Destination_City__c;
    shipment.Destination_Country__c = booking.Customer_Destination_Country__c;
    shipment.Destination_Zip__c = booking.Customer_Destination_Zip__c;
    shipment.Destination_State__c = booking.Customer_Destination_State__c;
    upsert shipment;
    return shipment;
  }

  public static List<FreightDetail__c> createFreightRecord(
    CC_BookingWrapper bookingwrapper,
    String recordName
  ) {
    List<FreightDetail__c> listFreight = new List<FreightDetail__c>();
    integer i = 0;
    String cargoType = '';
    for (
      CC_BookingWrapper.CargoWrapper cargo : bookingwrapper.shipment.listCargo
    ) {
      if (cargo.cargoType == 'container') {
        cargoType = 'EQUIP';
      } else {
        cargoType = cargo.cargoType;
      }

      for (
        CC_BookingWrapper.FreightDetailWrapper freightwrap : cargo.listFreightDetailWrapper
      ) {
        i++;
        FreightDetail__c freight = freightwrap.freightDetail;
        freight.id = null;
        freight.FreightId__c = '00' + String.valueOf(i);
        freight.Name = recordName + '-00' + String.valueOf(i);
        if (cargoType != 'EQUIP') {
          if (freightwrap.typeOfPackage == 'PVEH') {
            freight.Privately_Owned_Dealer_Owned_Vehicle__c = 'P';
          }
          if (freightwrap.typeOfPackage == 'CVEH') {
            freight.Privately_Owned_Dealer_Owned_Vehicle__c = 'D';
          }
          freight.Package_Type__c = freightwrap.typeOfPackage;
          freight.Package_Quantity__c = freight.Freight_Quantity__c;
          freight.Commodity_Code__c = freightwrap.commodityCode;
          freight.Commodity_Name__c = freightwrap.commodityDesc;
          if (freightwrap.measureUnit == 'lb/ft') {
            freight.Declared_Weights_Unit_of_Measure__c = 'lb';
            freight.Measure_Unit__c = 'ft';
          } else {
            freight.Declared_Weights_Unit_of_Measure__c = 'kg';
            freight.Measure_Unit__c = 'm';
          }
        }

        freight.Cargo_Type__c = cargoType;
        freight.Shipment__c = bookingwrapper.shipment.shipment.Id;
        listFreight.add(freight);
      }
    }
    upsert listFreight;
    return listFreight;
  }

  public static void createRequirementAndCommodities(
    CC_BookingWrapper bookingwrapper,
    String recordName,
    String cargoType
  ) {
    List<Requirement__c> listRequirement = new List<Requirement__c>();
    List<Commodity__c> listCommodity = new List<Commodity__c>();
    if (cargoType == 'container') {
      for (
        CC_BookingWrapper.CargoWrapper cargo : bookingwrapper.shipment.listCargo
      ) {
        for (
          CC_BookingWrapper.FreightDetailWrapper freightwrap : cargo.listFreightDetailWrapper
        ) {
          FreightDetail__c freight = freightwrap.freightDetail;
          /*Integer commodityCont = 1;
    Boolean isCreateFromRequirement=false;    
    if(freightwrap.listCommodityWrapper.size()==0){
    isCreateFromRequirement=true;
    }
    for(CC_BookingWrapper.CommodityWrapper comWrap : freightwrap.listCommodityWrapper){
    Commodity__c commodity = comWrap.commodity;
    commodity.CommodityId__c = '00'+String.valueOf(commodityCont);
    commodity.Name = recordName+'-00'+String.valueOf(commodityCont);                            
    commodity.Freight__c = freight.Id;
    listCommodity.add(commodity);
    commodityCont++;
    }*/
          Integer requirementCont = 1;
          for (
            CC_BookingWrapper.RequirementWrapper reqWrap : freightwrap.listRequirementWrapper
          ) {
            Requirement__c requirement = reqWrap.requirement;
            requirement.id = null;
            requirement.RequirementId__c =
              '00' + String.valueOf(requirementCont);
            requirement.Name =
              recordName +
              '-00' +
              String.valueOf(requirementCont);
            requirement.Container_Code__c = reqWrap.containerType;
            requirement.Commodity_Code__c = reqWrap.commodityCode;
            requirement.Commodity_Name__c = reqWrap.commodityDesc;
            requirement.Freight__c = freight.Id;
            /*if(isCreateFromRequirement){
    CC_BookingWrapper.CommodityWrapper comWrapper= new CC_BookingWrapper.CommodityWrapper();
    comWrapper.commodity = new Commodity__c(Name=recordName+'-00'+String.valueOf(commodityCont),
    Freight__c = freight.Id,Commodity__c= reqWrap.commodityDesc, Contract_Number__c = bookingwrapper.booking.Contract_Number__c,
    CommodityId__c = '00'+String.valueOf(commodityCont)
    );
    freightwrap.listCommodityWrapper.add(comWrapper);
    }*/
            listRequirement.add(requirement);
            requirementCont++;
            //commodityCont++;
          }
        }
      }

      upsert listRequirement;
    }
    //upsert listCommodity;
  }

  @AuraEnabled
  public static CC_BookingWrapper quoteForCaseCreation(
    String stringWrapperRequest
  ) {
    CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(
      stringWrapperRequest,
      CC_BookingWrapper.class
    );
    LIST<Quote__c> quoteforCaseList = new List<Quote__c>();
    for (Quote__c quote : bookingWrapper.listQuote) {
      if (quote.Status__c == 'Sent to Pricing') {
        quoteforCaseList.add(
          new Quote__c(Id = quote.Id, Status__c = 'Sent to Pricing')
        );
      }
    }
    if (quoteforCaseList.size() > 0) {
      update quoteforCaseList;
    }

    return bookingwrapper;
  }

  @AuraEnabled
  public static CC_BookingWrapper getBookingWrapperFromQuote(Id QuoteId) {
    CC_BookingWrapper.ShipmentWrapper Shipment = new CC_BookingWrapper.ShipmentWrapper();
    CC_BookingWrapper.CargoWrapper cargo = new CC_BookingWrapper.CargoWrapper();
    List<CC_BookingWrapper.FreightDetailWrapper> ListFDWrap = new List<CC_BookingWrapper.FreightDetailWrapper>();
    CC_BookingWrapper bookingWrapper = CC_BookingWrapper.getBookingWrapper();
    List<FreightDetail__c> ListFreightDetails = new List<FreightDetail__c>();
    String query =
      'SELECT CreatedDate, Name, Id, Account__c, Account__r.Name, Additional_Information__c, Contract__c, Contract__r.Name, Contract_Number__c, Customer_Email__c,Customer_Destination_City__c, Customer_Destination_Code__c, Contact_Number__c,' +
      ' Customer_Destination_Country__c, Customer_Destination_State__c, Contact__c, Contact__r.Name, Customer_Destination_Zip__c,Customer_Origin_City__c, Transportation_Management_System_Destina__c, Transportation_Management_System_Origin__c,' +
      'Customer_Origin_Code__c, Customer_Origin_Country__c, Customer_Origin_State__c, Company_Name__c, Customer_Origin_Zip__c, Description__c, Valid_To__c, Is_Hazardous__c, Ready_Date__c, Destination_Type__c, Destination_Drayage__c,' +
      ' toLabel(Status__c), Total_Amount__c, Transit_Time__c,Vessel_Name__c,Voyage_Number__c,No_of_Stop__c,Quote_Type__c, Origin_Type__c, Origin_Drayage__c,Port_of_Discharge__c, Port_of_Load__c, Contact_Name__c FROM Quote__c WHERE Id IN :accountIds';
    List<Quote__c> newQuote = QuoteDAO.getQuoteByQuery(
      query,
      new List<Id>{ QuoteId }
    );
    newQuote[0].Port_of_Load__c = null;
    newQuote[0].Port_of_Discharge__c = null;
    bookingWrapper = getQuoteDataInWrap(newQuote[0]);
    ListFreightDetails = QuoteDAO.getFreightDetailsByQuoteIds(
      new Set<Id>{ QuoteId }
    );
    List<Container__c> listContainers = [
      SELECT
        Id,
        Name,
        CICS_ISO_Code__c,
        Description__c,
        EBR__c,
        Genset_Type__c,
        Genset__c,
        Group__c,
        Handle_As__c,
        Height__c,
        Hide__c,
        Reefer__c,
        Size__c,
        Softship_ISO_Code__c,
        Tare__c,
        Type__c,
        Width__c,
        Used_For__c
      FROM Container__c
      ORDER BY NAME ASC
    ];
    Map<String, String> containerNameDescMap = new Map<String, String>();
    Map<String, Container__c> containerIdMap = new Map<String, Container__c>();
    for (Container__c contVar : listContainers) {
      if (
        containerNameDescMap.isEmpty() ||
        !containerNameDescMap.containsKey(contVar.Name)
      ) {
        containerNameDescMap.put(contVar.Name, contVar.Description__c);
      }
      if (
        containerIdMap.isEmpty() || !containerIdMap.containsKey(contVar.Name)
      ) {
        containerIdMap.put(contVar.Name, contVar);
      }
    }

    for (Quote__c quote : newQuote) {
      cargo.isHazardous = quote.Is_Hazardous__c;
    }
    Set<Id> FDIds = new Set<Id>();
    if (ListFreightDetails.size() > 0) {
      for (FreightDetail__c fdVar : ListFreightDetails) {
        if (fdVar.Cargo_Type__c == 'EQUIP') {
          cargo.cargoType = 'container';
          FDIds.add(fdVar.Id);
          Shipment = bookingWrapper.shipmentMap.get('CONTAINER');
        } else if (fdVar.Cargo_Type__c == 'BBULK') {
          cargo.cargoType = 'breakbulk';
          Shipment = bookingWrapper.shipmentMap.get('BREAKBULK');
        } else if (fdVar.Cargo_Type__c == 'AUTO') {
          cargo.cargoType = 'vehicle';
          Shipment = bookingWrapper.shipmentMap.get('VEHICLE');
        }
        CC_BookingWrapper.FreightDetailWrapper FDWrap = new CC_BookingWrapper.FreightDetailWrapper();
        FDWrap.freightDetail = fdVar;
        if (fdVar.Cargo_Type__c != 'EQUIP') {
          if (fdVar.Privately_Owned_Dealer_Owned_Vehicle__c == 'P') {
            FDWrap.typeOfPackage = 'PVEH';
          }
          if (fdVar.Privately_Owned_Dealer_Owned_Vehicle__c == 'D') {
            FDWrap.typeOfPackage = 'CVEH';
          }
          FDWrap.typeOfPackage = fdVar.Package_Type__c;
          FDWrap.commodityCode = fdVar.Commodity_Code__c;
          FDWrap.commodityDesc = fdVar.Commodity_Name__c;
          if (
            fdVar.Declared_Weights_Unit_of_Measure__c == 'lb' ||
            fdVar.Measure_Unit__c == 'ft'
          ) {
            FDWrap.measureUnit = 'lb/ft';
          } else {
            FDWrap.measureUnit = 'kg/m';
          }
        }
        ListFDWrap.add(FDWrap);
      }
      cargo.listFreightDetailWrapper = ListFDWrap;
      if (FDIds.size() > 0) {
        List<Requirement__c> ListRequirements = QuoteDAO.getRequirementByFreightDetailIds(
          FDIds
        );
        List<CC_BookingWrapper.RequirementWrapper> ListReqWrap = new List<CC_BookingWrapper.RequirementWrapper>();
        for (Requirement__c RqVar : ListRequirements) {
          CC_BookingWrapper.RequirementWrapper ReqWrap = new CC_BookingWrapper.RequirementWrapper();
          ReqWrap.requirement = RqVar;
          ReqWrap.containerType = RqVar.Container_Code__c;
          ReqWrap.commodityCode = RqVar.Commodity_Code__c;
          ReqWrap.commodityDesc = RqVar.Commodity_Name__c;
          ReqWrap.containerDesc = containerNameDescMap.get(
            RqVar.Container_Code__c
          );
          ReqWrap.container = containerIdMap.get(RqVar.Container_Code__c);
          ListReqWrap.add(ReqWrap);
        }
        CC_BookingWrapper.FreightDetailWrapper FDWrap = cargo.listFreightDetailWrapper[0];
        FDWrap.listRequirementWrapper = ListReqWrap;
        cargo.listFreightDetailWrapper = new List<CC_BookingWrapper.FreightDetailWrapper>{
          FDWrap
        };
      }
      Shipment.listcargo = new List<CC_BookingWrapper.CargoWrapper>{ cargo };
      Shipment.isSelected = true;
      if (Shipment.cargoType == 'container') {
        bookingwrapper.shipmentMap.put('CONTAINER', Shipment);
      } else if (Shipment.cargoType == 'breakbulk') {
        bookingwrapper.shipmentMap.put('BREAKBULK', Shipment);
        CC_BookingWrapper.ShipmentWrapper contShipment = bookingWrapper.shipmentMap.get(
          'CONTAINER'
        );
        contShipment.isSelected = false;
        bookingWrapper.shipmentMap.put('CONTAINER', contShipment);
      } else if (Shipment.cargoType == 'vehicle') {
        bookingwrapper.shipmentMap.put('VEHICLE', Shipment);
        CC_BookingWrapper.ShipmentWrapper contShipment = bookingWrapper.shipmentMap.get(
          'CONTAINER'
        );
        contShipment.isSelected = false;
        bookingWrapper.shipmentMap.put('CONTAINER', contShipment);
      }
    }
    system.debug('bookingWrapper with Quote Info' + bookingWrapper);
    return bookingWrapper;
  }

  private static CC_BookingWrapper getQuoteDataInWrap(Quote__c newQuote) {
    CC_BookingWrapper bookingWrapper = CC_BookingWrapper.getBookingWrapper();
    Booking__c booking = new Booking__c();
    booking.Account__c = newQuote.Account__c;
    booking.Additional_Information__c = newQuote.Additional_Information__c;
    booking.Company_Name__c = newQuote.Company_Name__c;
    booking.Contact__c = newQuote.Contact__c;
    booking.Contract__c = newQuote.Contract__c;
    booking.Contact_Name__c = newQuote.Contact_Name__c;
    booking.Contact_Number__c = newQuote.Contact_Number__c;
    booking.Contract_Number__c = newQuote.Contract_Number__c;
    booking.Customer_Destination_City__c = newQuote.Customer_Destination_City__c;
    booking.Customer_Destination_Code__c = newQuote.Customer_Destination_Code__c;
    booking.Customer_Destination_Country__c = newQuote.Customer_Destination_Country__c;
    booking.Customer_Destination_State__c = newQuote.Customer_Destination_State__c;
    booking.Customer_Destination_Zip__c = newQuote.Customer_Destination_Zip__c;
    booking.Customer_Email__c = newQuote.Customer_Email__c;
    booking.Customer_Origin_City__c = newQuote.Customer_Origin_City__c;
    booking.Customer_Origin_Code__c = newQuote.Customer_Origin_Code__c;
    booking.Customer_Origin_Country__c = newQuote.Customer_Origin_Country__c;
    booking.Customer_Origin_State__c = newQuote.Customer_Origin_State__c;
    booking.Customer_Origin_Zip__c = newQuote.Customer_Origin_Zip__c;
    booking.Description__c = newQuote.Description__c;
    booking.Destination_Drayage__c = newQuote.Destination_Drayage__c;
    booking.Destination_Type__c = newQuote.Destination_Type__c;
    booking.Port_of_Load__c = newQuote.Port_of_Load__c;
    booking.Port_of_Discharge__c = newQuote.Port_of_Discharge__c;
    booking.Is_Hazardous__c = newQuote.Is_Hazardous__c;
    booking.Origin_Drayage__c = newQuote.Origin_Drayage__c;
    booking.Origin_Type__c = newQuote.Origin_Type__c;
    booking.Ready_Date__c = newQuote.Ready_Date__c;
    booking.Transportation_Management_System_Destina__c = newQuote.Transportation_Management_System_Destina__c;
    booking.Transportation_Management_System_Origin__c = newQuote.Transportation_Management_System_Origin__c;
    bookingWrapper.booking = booking;
    if (bookingWrapper.booking.Account__c != null) {
      bookingWrapper.AccountName = newQuote.Account__r.Name;
    }
    if (bookingWrapper.booking.Contract__c != null) {
      bookingWrapper.booking.Contract_Number__c = newQuote.Contract__r.Name;
      //bookingWrapper.ContactName=newQuote.Contact__r.Name;
    }
    return bookingWrapper;
  }

  /*@AuraEnabled
    public static List<Location__c> fetchSubLocation(String locCode,String locType){
        List<Location__c> listLocation = new List<Location__c>();
        String subLocType = '';
        if(locType=='PORT'){
            subLocType='BERTH';
        }
        if(locType=='RAIL RAMP'){
            subLocType='RAIL';
        }
        
        listLocation = LocationDAO.getSubLocationsByUNLocCode(locCode,subLocType);
        return listLocation;
    }*/
}
