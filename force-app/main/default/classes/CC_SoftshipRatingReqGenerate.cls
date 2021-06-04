public class CC_SoftshipRatingReqGenerate {
  public static String getAPIResponse(String requestBody) {
    system.debug('getHeapSize()--------->' + Limits.getHeapSize());
    system.debug('getHeapSize() start--------->' + system.now());
    String responseString = APICalloutUtility.callAPIResponseService(
      CC_SoftshipRatingConstant.FINDAROUTEPOST,
      requestBody,
      null,
      ''
    );
    System.debug('responseString' + responseString);
    system.debug('getHeapSize() end--------->' + system.now());
    system.debug('getHeapSize()END--------->' + Limits.getHeapSize());
    return responseString;
  }

  public static CC_SoftshipRatingResponse sendRatingRequest(
    CC_SoftshipRatingRequest request
  ) {
    CC_SoftshipRatingResponse responseWrapper = new CC_SoftshipRatingResponse();
    String requestString = JSON.serialize(request, true);
    system.debug('requestString---------------->' + requestString);
    String responseString = getAPIResponse(requestString);
    responseString = responseString.replace('"Number":', '"NumberX":');
    responseString = responseString.replace('"From":', '"FromX":');
    system.debug('responseString---------------->' + responseString);

    responseWrapper = (CC_SoftshipRatingResponse) JSON.deserialize(
      responseString,
      CC_SoftshipRatingResponse.class
    );

    System.debug('responseWrapper ' + responseWrapper);
    return responseWrapper;
  }

  public static CC_SoftshipRatingRequest getRatingRequestWrapper(
    CC_BookingWrapper bookingWrap
  ) {
    CC_SoftshipRatingRequest requestWrapper = new CC_SoftshipRatingRequest();
    requestWrapper.Action = CC_SoftshipRatingConstant.CALCULATED_RATE;
    //requestWrapper.CalcRule = CC_SoftshipRatingConstant.STR_Y; //Rating API Change 16/12/2020
    requestWrapper.MaxNumberOfSchedules = CC_SoftshipRatingConstant.INTEGER_NO_OFSCHEDULE;
    requestWrapper.maxRoutes = CC_SoftshipRatingConstant.MAX_ROUTE;
    requestWrapper.DefaultOptionalServices = CC_SoftshipRatingConstant.STR_Y;
    requestWrapper.Booking = getBooking(bookingWrap);
    //requestWrapper.SelectedRoute = bookingWrap.selectedRouteId;
    return requestWrapper;
  }

  private static CC_SoftshipRatingRequest.Booking getBooking(
    CC_BookingWrapper bookingWrapper
  ) {
    CC_SoftshipRatingRequest.Booking booking = new CC_SoftshipRatingRequest.Booking();
    String bookingCargoType = bookingWrapper.shipment.listCargo[0].cargoType;
    booking.BookingAgency = getBookingAgency();
    booking.ShipmentType = CC_SoftshipRatingConstant.STR_FF;
    booking.BookingDate = '';
    booking.Customer = getCustomer(bookingWrapper);
    booking.Contract = getContract(bookingWrapper);
    booking.TransCurrency = getTransCurrency();
    booking.RequestedBookingRoute = getRequestedBookingRoute(bookingWrapper);
    //booking.BookingCargo = getBookingCargo(bookingWrapper); //Rating API Change 16/12/2020
    booking.BookingCargo = getBookingCargoList(bookingWrapper);
    booking.ShipmentCondition = bookingWrapper.booking.Payment_Terms__c;
    /*if(bookingWrapper.booking.Ready_Date__c != null){
            booking.ReadyDate = String.valueOf(bookingWrapper.booking.Ready_Date__c.year())+'-'+String.valueOf(bookingWrapper.booking.Ready_Date__c.month())+'-'+String.valueOf(bookingWrapper.booking.Ready_Date__c.day())+'T00:00:00Z';
        }else{
            booking.ReadyDate = String.valueOf(date.today().year())+'-'+String.valueOf(date.today().month())+'-'+String.valueOf(date.today().day())+'T00:00:00Z';
        }*/
    return booking;
  }

  private static CC_SoftshipRatingRequest.BookingAgency getBookingAgency() {
    CC_SoftshipRatingRequest.BookingAgency bookingAgency = new CC_SoftshipRatingRequest.BookingAgency();
    bookingAgency.Code = CC_SoftshipRatingConstant.STR_HQ;
    return bookingAgency;
  }

  private static CC_SoftshipRatingRequest.Customer getCustomer(
    CC_BookingWrapper bookingWrapper
  ) {
    CC_SoftshipRatingRequest.Customer customer = new CC_SoftshipRatingRequest.Customer();
    List<Account> account;
    if (bookingWrapper.booking.Account__c != null) {
      account = [
        SELECT Id, CVIF__c, Name
        FROM Account
        WHERE Id = :bookingWrapper.booking.Account__c
      ];
      customer.CustomerCode = getCustomerCode(
        account != null && !account.isEmpty() ? account[0].CVIF__c : ''
      );
      customer.CustomerName1 = account != null && !account.isEmpty()
        ? account[0].Name
        : '';
    } else {
      customer.CustomerCode = getCustomerCode('');
      customer.CustomerName1 = '';
    }
    return customer;
  }

  private static CC_SoftshipRatingRequest.CustomerCode getCustomerCode(
    String code
  ) {
    CC_SoftshipRatingRequest.CustomerCode customerCode = new CC_SoftshipRatingRequest.CustomerCode();
    customerCode.Code = code;
    return customerCode;
  }

  private static CC_SoftshipRatingRequest.Contract getContract(
    CC_BookingWrapper bookingWrapper
  ) {
    CC_SoftshipRatingRequest.Contract contract = new CC_SoftshipRatingRequest.Contract();
    if (String.isNotBlank(bookingWrapper.booking.Contract_Number__c)) {
      contract.ContractNumber = bookingWrapper.booking.Contract_Number__c;
    } else {
      contract.ContractNumber = '';
    }
    return contract;
  }
  private static CC_SoftshipRatingRequest.TransCurrency getTransCurrency() {
    CC_SoftshipRatingRequest.TransCurrency transCurrency = new CC_SoftshipRatingRequest.TransCurrency();
    transCurrency.Code = CC_SoftshipRatingConstant.STR_USD;
    return transCurrency;
  }

  private static CC_SoftshipRatingRequest.RequestedBookingRoute getRequestedBookingRoute(
    CC_BookingWrapper bookingWrapper
  ) {
    CC_SoftshipRatingRequest.RequestedBookingRoute requestedBookingRoute = new CC_SoftshipRatingRequest.RequestedBookingRoute();
    requestedBookingRoute.MaxTransshipments = CC_SoftshipRatingConstant.MAX_TRANSSHIPMENT;
    requestedBookingRoute.Legs = getLegsList(bookingWrapper);
    return requestedBookingRoute;
  }

  private static String checkNull(String strValue) {
    return (strValue != null) ? strValue : '';
  }

  /*private static List<CC_SoftshipRatingRequest.Legs> getLegsList(CC_BookingWrapper bookingWrapper) {
        List<CC_SoftshipRatingRequest.Legs> legs = new List<CC_SoftshipRatingRequest.Legs>();
        CC_SoftshipRatingRequest.Legs leg = new CC_SoftshipRatingRequest.Legs();
        leg.LegSequence = 1;
        if(bookingWrapper.booking.Ready_Date__c != null){
            leg.ReadyDate = String.valueOf(bookingWrapper.booking.Ready_Date__c.year())+'-'+String.valueOf(bookingWrapper.booking.Ready_Date__c.month())+'-'+String.valueOf(bookingWrapper.booking.Ready_Date__c.day())+'T00:00:00Z';
        }else{
            leg.ReadyDate = String.valueOf(date.today().year())+'-'+String.valueOf(date.today().month())+'-'+String.valueOf(date.today().day())+'T00:00:00Z';
        }
        leg.ReceiptTermCode = bookingWrapper.booking.Description__c.substring(0, 1);
        leg.DeliveryTermCode = bookingWrapper.booking.Description__c.substring(1);
        leg.StartLocation = bookingWrapper.booking.Customer_Origin_Code__c; 
        leg.EndLocation = bookingWrapper.booking.Customer_Destination_Code__c;         
        leg.StartSubLocationCode = bookingWrapper.booking.Pickup_Location__c;
        leg.EndSubLocationCode = bookingWrapper.booking.Delivery_Location__c;        
        leg.ReceiptTermBehavior =bookingWrapper.booking.Description__c.substring(0, 1);
        leg.ReceiptStopoverCode ='';
        leg.ReceiptTypeCode = checkNull(bookingWrapper.booking.Transportation_Management_System_Origin__c);
        leg.ReceiptDrayage = '';
        leg.DeliveryTermBehavior =bookingWrapper.booking.Description__c.substring(1);
        leg.DeliveryStopoverCode ='';
        leg.DeliveryTypeCode = checkNull(bookingWrapper.booking.Transportation_Management_System_Destina__c);
        leg.DeliveryDrayage = '';
        legs.add(leg);        
        return legs;
    }*/

  private static List<CC_SoftshipRatingRequest.Legs> getLegsList(
    CC_BookingWrapper bookingWrapper
  ) {
    List<CC_SoftshipRatingRequest.Legs> legs = new List<CC_SoftshipRatingRequest.Legs>();
    //CC_SoftshipRatingRequest.Legs leg = getLeg(bookingWrapper);
    if (
      (bookingWrapper.booking.Description__c == 'PR' ||
      bookingWrapper.booking.Description__c == 'PD') &&
      bookingWrapper.booking.Customer_Origin_Country__c == 'US' &&
      bookingWrapper.booking.Customer_Destination_Country__c == 'US'
    ) {
      bookingWrapper.booking.Pickup_Location__c = (CC_SoftshipRatingConstant.mapPortSublocation.get(
          bookingWrapper.booking.Customer_Origin_Code__c
        ) != null)
        ? CC_SoftshipRatingConstant.mapPortSublocation.get(
            bookingWrapper.booking.Customer_Origin_Code__c
          )
        : '';
    }

    if (
      (bookingWrapper.booking.Description__c == 'RP' ||
      bookingWrapper.booking.Description__c == 'DP') &&
      bookingWrapper.booking.Customer_Origin_Country__c == 'US' &&
      bookingWrapper.booking.Customer_Destination_Country__c == 'US'
    ) {
      bookingWrapper.booking.Delivery_Location__c = (CC_SoftshipRatingConstant.mapPortSublocation.get(
          bookingWrapper.booking.Customer_Destination_Code__c
        ) != null)
        ? CC_SoftshipRatingConstant.mapPortSublocation.get(
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        : '';
    }
    String POL = bookingWrapper.booking.Port_of_Load__c;
    String POD = bookingWrapper.booking.Port_of_Discharge__c;
    System.debug('POL  ' + POL + ' POD ' + POD);
    if (bookingWrapper.booking.Description__c == 'DD') {
      if (POL != null && POD != null && POL != '' && POD != '') {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            'DP',
            bookingWrapper.booking.Customer_Origin_Code__c,
            POL
          )
        );
        legs.add(getLeg(bookingWrapper, 2, 'PP', POL, POD));
        legs.add(
          getLeg(
            bookingWrapper,
            3,
            'PD',
            POD,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      } else if (POL != null && POL != '' && (POD == null || POD == '')) {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            'DP',
            bookingWrapper.booking.Customer_Origin_Code__c,
            POL
          )
        );
        legs.add(
          getLeg(
            bookingWrapper,
            2,
            'PD',
            POL,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      } else if ((POL == null || POL == '') && POD != null && POD != '') {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            'DP',
            bookingWrapper.booking.Customer_Origin_Code__c,
            POD
          )
        );
        legs.add(
          getLeg(
            bookingWrapper,
            2,
            'PD',
            POD,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      } else {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            bookingWrapper.booking.Description__c,
            bookingWrapper.booking.Customer_Origin_Code__c,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      }
    } else if (bookingWrapper.booking.Description__c == 'DP') {
      if (POL != null && POL != '') {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            'DP',
            bookingWrapper.booking.Customer_Origin_Code__c,
            POL
          )
        );
        legs.add(
          getLeg(
            bookingWrapper,
            2,
            'PP',
            POL,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      } else {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            bookingWrapper.booking.Description__c,
            bookingWrapper.booking.Customer_Origin_Code__c,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      }
    } else if (bookingWrapper.booking.Description__c == 'PD') {
      if (POD != null && POD != '') {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            'PP',
            bookingWrapper.booking.Customer_Origin_Code__c,
            POD
          )
        );
        legs.add(
          getLeg(
            bookingWrapper,
            2,
            'PD',
            POD,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      } else {
        legs.add(
          getLeg(
            bookingWrapper,
            1,
            bookingWrapper.booking.Description__c,
            bookingWrapper.booking.Customer_Origin_Code__c,
            bookingWrapper.booking.Customer_Destination_Code__c
          )
        );
      }
    } else {
      legs.add(
        getLeg(
          bookingWrapper,
          1,
          bookingWrapper.booking.Description__c,
          bookingWrapper.booking.Customer_Origin_Code__c,
          bookingWrapper.booking.Customer_Destination_Code__c
        )
      );
    }

    return legs;

    //legs.add(leg);
  }

  private static CC_SoftshipRatingRequest.Legs getLeg(
    CC_BookingWrapper bookingWrapper,
    Integer sequence,
    String description,
    String startPoint,
    String endPoint
  ) {
    CC_SoftshipRatingRequest.Legs leg = new CC_SoftshipRatingRequest.Legs();
    leg.LegSequence = sequence;
    if (bookingWrapper.booking.Ready_Date__c != null) {
      leg.ReadyDate =
        String.valueOf(bookingWrapper.booking.Ready_Date__c.year()) +
        '-' +
        String.valueOf(bookingWrapper.booking.Ready_Date__c.month()) +
        '-' +
        String.valueOf(bookingWrapper.booking.Ready_Date__c.day()) +
        'T00:00:00.0000000Z';
    } else {
      leg.ReadyDate =
        String.valueOf(date.today().year()) +
        '-' +
        String.valueOf(date.today().month()) +
        '-' +
        String.valueOf(date.today().day()) +
        'T00:00:00.0000000Z';
    }
    leg.ReceiptTermCode = description.substring(0, 1);
    leg.DeliveryTermCode = description.substring(1);
    leg.StartLocation = startPoint;
    leg.EndLocation = endPoint;
    leg.StartSubLocationCode = bookingWrapper.booking.Pickup_Location__c;
    leg.EndSubLocationCode = bookingWrapper.booking.Delivery_Location__c;
    leg.ReceiptTermBehavior = description.substring(0, 1);
    leg.ReceiptStopoverCode = '';
    if (description == 'PP') {
      leg.ReceiptTypeCode = '';
      leg.DeliveryTypeCode = '';
    } else {
      leg.ReceiptTypeCode = checkNull(
        bookingWrapper.booking.Transportation_Management_System_Origin__c
      );
      leg.DeliveryTypeCode = checkNull(
        bookingWrapper.booking.Transportation_Management_System_Destina__c
      );
    }

    leg.ReceiptDrayage = bookingWrapper.booking.Origin_Drayage__c;
    leg.DeliveryTermBehavior = description.substring(1);
    leg.DeliveryStopoverCode = '';
    leg.DeliveryDrayage = bookingWrapper.booking.Destination_Drayage__c;

    return leg;
  }

  //Rating API Change 16/12/2020
  private static List<CC_SoftshipRatingRequest.BookingCargo> getBookingCargoList(
    CC_BookingWrapper bookingWrapper
  ) {
    List<CC_SoftshipRatingRequest.BookingCargo> lstBookingCargo = new List<CC_SoftshipRatingRequest.BookingCargo>();
    List<Optional_Service__c> optionalServiceSettings = CustomSettingDAO.getOptionalService();

    List<CC_BookingWrapper.RequirementWrapper> allRequirementWrappers = new List<CC_BookingWrapper.RequirementWrapper>();
    for (
      CC_BookingWrapper.FreightDetailWrapper freightWrapper : bookingWrapper.shipment.listCargo[0]
        .listFreightDetailWrapper
    ) {
      if (
        freightWrapper != null &&
        freightWrapper.listRequirementWrapper != null
      ) {
        allRequirementWrappers.addAll(freightWrapper.listRequirementWrapper);
      }
    }

    String bookingCargoType = bookingWrapper.shipment.listCargo[0].cargoType;
    if (
      bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.CONTAINER)
    ) {
      if (
        bookingWrapper.shipment.listCargo[0].listFreightDetailWrapper != null &&
        bookingWrapper.shipment.listCargo[0].listFreightDetailWrapper.size() > 0
      ) {
        bookingCargoType = CC_SoftshipRatingConstant.MULTICONTAINER_CARGOTYPE;
      }
    }
    if (bookingCargoType.equalsIgnoreCase('AUTO')) {
      bookingCargoType = CC_SoftshipRatingConstant.RORO;
    }
    if (bookingCargoType.equalsIgnoreCase('BBULK')) {
      bookingCargoType = CC_SoftshipRatingConstant.BREAKBULK;
    }

    CC_SoftshipRatingRequest.BookingCargo bookingCargo = new CC_SoftshipRatingRequest.BookingCargo();
    Integer i = 1;
    Integer index = i - 1;
    if (
      bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.RORO) ||
      bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.BREAKBULK)
    ) {
      //String measureUnit = bookingWrapper.shipment.listCargo[0].measureUnit;
      for (
        CC_BookingWrapper.FreightDetailWrapper freightWrapper : bookingWrapper.shipment.listCargo[0]
          .listFreightDetailWrapper
      ) {
        bookingCargo = new CC_SoftshipRatingRequest.BookingCargo();
        bookingCargo.type = bookingCargoType;
        bookingCargo.Cargo = getCargoList(freightWrapper, bookingCargoType);
        CC_SoftshipRatingRequest.CargoId CargoId = new CC_SoftshipRatingRequest.CargoId();
        CargoId.CargoItemId = new Map<String, Integer>{
          'ItemRunningNumber' => i
        };
        CargoId.CargoRunningNumber = 1;
        CC_SoftshipRatingRequest.Cargo cargoDetail = (bookingCargo.Cargo)
          .get(index);
        cargoDetail.Id = CargoId;
        (bookingCargo.Cargo).set(index, cargoDetail);
        bookingCargo.OptionalServices = getOptionalServices(
          freightWrapper.freightDetail,
          optionalServiceSettings
        );
        lstBookingCargo.add(bookingCargo);
        i++;
      }
    } else {
      for (
        CC_BookingWrapper.RequirementWrapper requirementWrapper : allRequirementWrappers
      ) {
        Boolean isHazardous = bookingWrapper.shipment.listCargo[0].isHazardous;
        bookingCargo = new CC_SoftshipRatingRequest.BookingCargo();
        bookingCargo.type = bookingCargoType;
        bookingCargo.Cargo = getContainerCargoListContainer(
          requirementWrapper,
          isHazardous
        );
        CC_SoftshipRatingRequest.Cargo cargoDetail = (bookingCargo.Cargo)
          .get(index);
        cargoDetail.Id.CargoItemId = new Map<String, Integer>{
          'ItemRunningNumber' => i
        };
        (bookingCargo.Cargo).set(index, cargoDetail);
        bookingCargo.OptionalServices = getOptionalServices(
          requirementWrapper.requirement,
          optionalServiceSettings
        );
        lstBookingCargo.add(bookingCargo);
        i++;
      }
    }
    return lstBookingCargo;
  }

  //Commented for Rating API Change 16/12/2020 -- START--
  /*private static CC_SoftshipRatingRequest.BookingCargo getBookingCargo(CC_BookingWrapper bookingWrapper) {
        CC_SoftshipRatingRequest.BookingCargo bookingCargo = new CC_SoftshipRatingRequest.BookingCargo();
        String bookingCargoType = bookingWrapper.shipment.listCargo[0].cargoType;
        if(bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.CONTAINER)){
            if(bookingWrapper.shipment.listCargo[0].listFreightDetailWrapper != null 
                && bookingWrapper.shipment.listCargo[0].listFreightDetailWrapper.size() > 0){
                bookingCargoType = CC_SoftshipRatingConstant.MULTICONTAINER_CARGOTYPE;
            }
        }
        if(bookingCargoType.equalsIgnoreCase('AUTO')){
            bookingCargoType=CC_SoftshipRatingConstant.RORO;
        }
        if(bookingCargoType.equalsIgnoreCase('BBULK')){
            bookingCargoType=CC_SoftshipRatingConstant.BREAKBULK;
        }
        bookingCargo.type = bookingCargoType;
        bookingCargo.values = getValuesList(bookingWrapper, bookingCargoType);
        return bookingCargo;
    }*/

  /*private static List<CC_SoftshipRatingRequest.Values> getValuesList(CC_BookingWrapper bookingWrapper, String bookingCargoType){
        List<CC_SoftshipRatingRequest.Values> values = new List<CC_SoftshipRatingRequest.Values>();
        List<CC_BookingWrapper.RequirementWrapper> allRequirementWrappers = new List<CC_BookingWrapper.RequirementWrapper>();
        for(CC_BookingWrapper.FreightDetailWrapper freightWrapper : bookingWrapper.shipment.listCargo[0].listFreightDetailWrapper){
            if(freightWrapper!=null && freightWrapper.listRequirementWrapper!=null){
                allRequirementWrappers.addAll(freightWrapper.listRequirementWrapper);
            }
            
        }
        CC_SoftshipRatingRequest.Values value = new CC_SoftshipRatingRequest.Values();
        Integer i=1;
        List<Optional_Service__c> optionalServiceSettings = CustomSettingDAO.getOptionalService();
        if(bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.RORO) || bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.BREAKBULK)){
            //String measureUnit = bookingWrapper.shipment.listCargo[0].measureUnit;
            for(CC_BookingWrapper.FreightDetailWrapper freightWrapper :  bookingWrapper.shipment.listCargo[0].listFreightDetailWrapper){
                value = new CC_SoftshipRatingRequest.Values();
                value.Cargo = getCargoList(freightWrapper, bookingCargoType);
                value.CargoItemId= new Map<String,Integer>{'ItemRunningNumber'=>i}; 
                value.OptionalServices =getOptionalServices(freightWrapper.freightDetail, optionalServiceSettings);         
                values.add(value);
                i++;
            }
        }else{
            for(CC_BookingWrapper.RequirementWrapper requirementWrapper : allRequirementWrappers){
                Boolean isHazardous = bookingWrapper.shipment.listCargo[0].isHazardous;
                value = new CC_SoftshipRatingRequest.Values();
                value.Cargo = getContainerCargoListContainer(requirementWrapper,isHazardous);
                value.CargoItemId= new Map<String,Integer>{'ItemRunningNumber'=>i};
                value.OptionalServices =getOptionalServices(requirementWrapper.requirement, optionalServiceSettings); 
                values.add(value);
                i++;
            }
        }
        return values;
    }*/
  //Commented for Rating API Change 16/12/2020 -- END--

  private static CC_SoftshipRatingRequest.OptionalServices getOptionalServices(
    sObject objectData,
    List<Optional_Service__c> optionalServiceSettings
  ) {
    Integer chainstrapQuantity = 0;
    String chainStrapConditionValue = CC_SoftshipRatingConstant.STR_NO.toUppercase();
    CC_SoftshipRatingRequest.OptionalServices optionalServices = new CC_SoftshipRatingRequest.OptionalServices();
    List<CC_SoftshipRatingRequest.BookingOptionalServiceModels> bookingOptionalServiceModels = new List<CC_SoftshipRatingRequest.BookingOptionalServiceModels>();
    CC_SoftshipRatingRequest.BookingOptionalServiceModels bookingOptionalServiceModelForChainOrStrap = new CC_SoftshipRatingRequest.BookingOptionalServiceModels();

    for (Optional_Service__c optionalService : optionalServiceSettings) {
      CC_SoftshipRatingRequest.BookingOptionalServiceModels bookingOptionalServiceModel = new CC_SoftshipRatingRequest.BookingOptionalServiceModels();

      CC_SoftshipRatingRequest.OptionalServiceTariffInformation optionalServiceTariffInformation = new CC_SoftshipRatingRequest.OptionalServiceTariffInformation();
      optionalServiceTariffInformation.Level = Integer.valueOf(
        optionalService.Tariff_Code__c
      );
      bookingOptionalServiceModel.OptionalServiceTariffInformation = optionalServiceTariffInformation;

      if (
        String.isNotBlank(optionalService.FieldMapping_Name__c) &&
        optionalService.FieldMapping_Type__c == 'Text'
      ) {
        String strVal = getStringValue(
          objectData,
          optionalService.FieldMapping_Name__c
        );
        CC_SoftshipRatingRequest.OptionalServiceCondition optionalServiceCondition = new CC_SoftshipRatingRequest.OptionalServiceCondition();
        optionalServiceCondition.ConditionValue = strVal;
        bookingOptionalServiceModel.OptionalServiceCondition = optionalServiceCondition;
      } else {
        Boolean bolValue = getBooleanValue(
          objectData,
          optionalService.FieldMapping_Name__c
        );
        CC_SoftshipRatingRequest.OptionalServiceCondition optionalServiceCondition = new CC_SoftshipRatingRequest.OptionalServiceCondition();
        optionalServiceCondition.ConditionValue = (bolValue == false)
          ? CC_SoftshipRatingConstant.STR_NO.toUppercase()
          : CC_SoftshipRatingConstant.STR_YES.toUppercase();
        bookingOptionalServiceModel.OptionalServiceCondition = optionalServiceCondition;
      }
      if (String.isNotBlank(optionalService.Basis_Field_Name__c)) {
        Integer intValue = getIntegerValue(
          objectData,
          optionalService.Basis_Field_Name__c
        );
        CC_SoftshipRatingRequest.CalculationBasis calculationBasis = new CC_SoftshipRatingRequest.CalculationBasis();
        if (
          optionalService.Basis_Field_Name__c == 'Additional_Chains_Qty__c' ||
          optionalService.Basis_Field_Name__c == 'Additional_Straps_Qty__c'
        ) {
          if (
            chainStrapConditionValue ==
            CC_SoftshipRatingConstant.STR_YES.toUppercase() ||
            bookingOptionalServiceModel.OptionalServiceCondition.ConditionValue ==
            CC_SoftshipRatingConstant.STR_YES.toUppercase()
          ) {
            chainStrapConditionValue = CC_SoftshipRatingConstant.STR_YES.toUppercase();
          }
          bookingOptionalServiceModel.OptionalServiceCondition.ConditionValue = chainStrapConditionValue;
          chainstrapQuantity += intValue;
          calculationBasis.Value = chainstrapQuantity;
        } else {
          calculationBasis.Value = intValue;
        }
        CC_SoftshipRatingRequest.OptionalServiceCalculationBasis optionalServiceCalculationBasis = new CC_SoftshipRatingRequest.OptionalServiceCalculationBasis();
        optionalServiceCalculationBasis.CalculationBasis = calculationBasis;
        bookingOptionalServiceModel.OptionalServiceCalculationBasis = optionalServiceCalculationBasis;
        if (
          optionalService.Basis_Field_Name__c == 'Additional_Chains_Qty__c' ||
          optionalService.Basis_Field_Name__c == 'Additional_Straps_Qty__c'
        ) {
          bookingOptionalServiceModelForChainOrStrap = bookingOptionalServiceModel;
        }
      }
      if (
        optionalService.Basis_Field_Name__c != 'Additional_Chains_Qty__c' &&
        optionalService.Basis_Field_Name__c != 'Additional_Straps_Qty__c'
      ) {
        bookingOptionalServiceModels.add(bookingOptionalServiceModel);
      }
    }

    bookingOptionalServiceModels.add(
      bookingOptionalServiceModelForChainOrStrap
    );

    optionalServices.BookingOptionalServiceModels = bookingOptionalServiceModels;
    return optionalServices;
  }

  private static String getStringValue(sObject objectData, String fieldName) {
    String stringValue = (String) ((objectData.get(fieldName) == null)
      ? ''
      : objectData.get(fieldName));
    return stringValue;
  }

  private static Boolean getBooleanValue(sObject objectData, String fieldName) {
    boolean booleanValue = (Boolean) ((objectData.get(fieldName) == null)
      ? false
      : objectData.get(fieldName));
    return booleanValue;
  }

  private static Integer getIntegerValue(sObject objectData, String fieldName) {
    Decimal decimalValue = (objectData.get(fieldName) == null)
      ? 0.00
      : (Decimal) (objectData.get(fieldName));
    return decimalValue.intValue();
  }

  private static List<CC_SoftshipRatingRequest.Cargo> getCargoList(
    CC_BookingWrapper.FreightDetailWrapper freightWrapper,
    String bookingCargoType
  ) {
    List<CC_SoftshipRatingRequest.Cargo> cargoList = new List<CC_SoftshipRatingRequest.Cargo>();
    if (bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.RORO)) {
      cargoList.add(getCargo(freightWrapper, bookingCargoType));
    } else {
      Integer runningNumber = 1;
      while (
        runningNumber <= freightWrapper.freightDetail.Freight_Quantity__c
      ) {
        cargoList.add(getCargo(freightWrapper, bookingCargoType));
        runningNumber++;
      }
    }
    return cargoList;
  }

  private static CC_SoftshipRatingRequest.Cargo getCargo(
    CC_BookingWrapper.FreightDetailWrapper freightDetailWrapper,
    String bookingCargoType
  ) {
    CC_SoftshipRatingRequest.Cargo cargo = new CC_SoftshipRatingRequest.Cargo();
    CC_SoftshipRatingRequest.Commodity commodity = new CC_SoftshipRatingRequest.Commodity();
    commodity.Code = freightDetailWrapper.commodityCode;
    commodity.DescriptionOfGoods = freightDetailWrapper.commodityDesc;
    cargo.Commodity = commodity;
    if (bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.RORO)) {
      cargo.Vin = '';
      cargo.CarModelId = getCarModelId(freightDetailWrapper.freightDetail);
      //cargo.ModelYear = 0;
      if (
        freightDetailWrapper.freightDetail.Year__c == null ||
        freightDetailWrapper.freightDetail.Year__c == ''
      ) {
        cargo.ModelYear = 0;
      } else {
        cargo.ModelYear = Integer.valueOf(
          freightDetailWrapper.freightDetail.Year__c
        );
      }
      // cargo.ModelYear = 0;
    }

    if (
      bookingCargoType.equalsIgnoreCase(CC_SoftshipRatingConstant.BREAKBULK)
    ) {
      //cargo.Area=getArea(freightDetailWrapper);
      //cargo.Measurement=getMeasurement(freightDetailWrapper);
      freightDetailWrapper.freightDetail.Freight_Quantity__c = 1.0;
    }
    //cargo.DescriptionOfGoods = '';
    cargo.KindOfPackage = getKindOfPackage(freightDetailWrapper);
    cargo.LengthCentimeter = getLengthCentimeter(
      freightDetailWrapper.freightDetail,
      freightDetailWrapper.measureUnit
    );
    cargo.WidthCentimeter = getWidthCentimeter(
      freightDetailWrapper.freightDetail,
      freightDetailWrapper.measureUnit
    );
    cargo.HeightCentimeter = getHeightCentimeter(
      freightDetailWrapper.freightDetail,
      freightDetailWrapper.measureUnit
    );
    cargo.WeightKilogram = getWeightKilogram(
      freightDetailWrapper.freightDetail,
      freightDetailWrapper.measureUnit
    );
    //cargo.CargoNetWeight = getNetWeightKilogram(freightDetailWrapper.freightDetail);
    Map<String, Decimal> numberOfPackage = new Map<String, Decimal>();
    numberOfPackage.put(
      'Number',
      freightDetailWrapper.freightDetail.Freight_Quantity__c
    );
    cargo.NumberOfPackage = numberOfPackage;
    cargo.OperationalStatus = getOperationalStatus();
    //cargo.Imdg=getImdg();
    return cargo;
  }

  /*private static CC_SoftshipRatingRequest.UnitAmount getArea(CC_BookingWrapper.FreightDetailWrapper freightDetailWrapper){
        CC_SoftshipRatingRequest.UnitAmount unitAmount = new CC_SoftshipRatingRequest.UnitAmount();
        unitAmount.Unit = 1;
        unitAmount.Amount =0.00;
        return unitAmount;
    }

    private static CC_SoftshipRatingRequest.UnitAmount getMeasurement(CC_BookingWrapper.FreightDetailWrapper freightDetailWrapper){
        CC_SoftshipRatingRequest.UnitAmount unitAmount = new CC_SoftshipRatingRequest.UnitAmount();
        unitAmount.Unit = 1;
        unitAmount.Amount =0.00;
        return unitAmount;
    }*/

  private static CC_SoftshipRatingRequest.KindOfPackage getKindOfPackage(
    CC_BookingWrapper.FreightDetailWrapper freightDetailWrapper
  ) {
    CC_SoftshipRatingRequest.KindOfPackage kindOfPackage = new CC_SoftshipRatingRequest.KindOfPackage();
    kindOfPackage.Code = freightDetailWrapper.typeOfPackage;
    kindOfPackage.Description = freightDetailWrapper.packageDesc;
    return kindOfPackage;
  }

  private static CC_SoftshipRatingRequest.CarModelId getCarModelId(
    FreightDetail__c freightDetail
  ) {
    CC_SoftshipRatingRequest.CarModelId carModelId = new CC_SoftshipRatingRequest.CarModelId();
    carModelId.Manufacturer = freightDetail.Manufacturer__c;
    carModelId.Model = freightDetail.Model__c;
    carModelId.Type = freightDetail.Type__c;
    return carModelId;
  }

  private static CC_SoftshipRatingRequest.LengthCentimeter getLengthCentimeter(
    FreightDetail__c freightDetail,
    String measureUnit
  ) {
    CC_SoftshipRatingRequest.LengthCentimeter lengthCentimeter = new CC_SoftshipRatingRequest.LengthCentimeter();
    lengthCentimeter.Unit = 0;
    lengthCentimeter.Amount = getDistanceValueInCM(
      freightDetail.Length_Major__c,
      freightDetail.Length_Minor__c,
      measureUnit
    );
    return lengthCentimeter;
  }

  private static CC_SoftshipRatingRequest.WidthCentimeter getWidthCentimeter(
    FreightDetail__c freightDetail,
    String measureUnit
  ) {
    CC_SoftshipRatingRequest.WidthCentimeter widthCentimeter = new CC_SoftshipRatingRequest.WidthCentimeter();
    widthCentimeter.Unit = 0;
    widthCentimeter.Amount = getDistanceValueInCM(
      freightDetail.Width_Major__c,
      freightDetail.Width_Minor__c,
      measureUnit
    );
    return widthCentimeter;
  }

  private static CC_SoftshipRatingRequest.HeightCentimeter getHeightCentimeter(
    FreightDetail__c freightDetail,
    String measureUnit
  ) {
    CC_SoftshipRatingRequest.HeightCentimeter heightCentimeter = new CC_SoftshipRatingRequest.HeightCentimeter();
    heightCentimeter.Unit = 0;
    heightCentimeter.Amount = getDistanceValueInCM(
      freightDetail.Height_Major__c,
      freightDetail.Height_Minor__c,
      measureUnit
    );
    return heightCentimeter;
  }

  /*private static Decimal getDistanceValue(Decimal majorValue,Decimal minorValue){
        Decimal value =0;
        if(majorValue!=null && majorValue>0){
            value = majorValue;
            if(minorValue!=null && minorValue>0){
                String valueString = String.valueOf(Integer.valueOf(majorValue)) +'.'+String.valueOf(Integer.valueOf(minorValue));
                value = Decimal.valueOf(valueString);
            }
         }else if(minorValue!=null && minorValue>0){
            value = minorValue; 
        }
        return value;
     }*/

  private static Decimal getDistanceValueInCM(
    Decimal majorValue,
    Decimal minorValue,
    String measureUnit
  ) {
    // 0=cm; 1=m; 2=km; 3=ft; 4=inch
    //0 =Kilogram; 1= ton; 2= lbs
    Decimal value = 0;
    if (String.isNotBlank(measureUnit)) {
      if (measureUnit == 'lb/ft') {
        if (majorValue != null && majorValue > 0) {
          //30.48 unit = 3;
          value = majorValue * 30.48;
          if (minorValue != null && minorValue > 0) {
            //2.54 unit = 4;
            minorValue = minorValue * 2.54;
            value = value + minorValue;
          }
        } else if (minorValue != null && minorValue > 0) {
          //2.54 unit = 4;
          value = minorValue * 2.54;
        }
      } else if (measureUnit == 'kg/m') {
        if (majorValue != null && majorValue > 0) {
          //100 unit = 1;
          value = majorValue * 100;
          if (minorValue != null && minorValue > 0) {
            //unit = 0;
            value = value + minorValue;
          }
        } else if (minorValue != null && minorValue > 0) {
          //unit = 0;
          value = minorValue;
        }
      }
    }

    return value.setScale(2);
  }

  /*private static Integer getDistanceUnit(Decimal majorValue,Decimal minorValue, String measureUnit){
       // 0=cm; 1=m; 2=km; 3=ft; 4=inch
       //0 =Kilogram; 1= ton; 2= lbs
        Integer unit =0;
        if(String.isNotBlank(measureUnit)){
            if(measureUnit=='lb/ft'){
                if(majorValue!=null && majorValue>0){
                    unit = 3;

                }else if(minorValue!=null && minorValue>0){
                    unit = 4;
                }

            }
            else if(measureUnit=='kg/m'){
                if(majorValue!=null && majorValue>0){
                    unit = 1;

                }else if(minorValue!=null && minorValue>0){
                    unit = 0;
                }
            }
        }
        
        return unit;
    }*/

  private static CC_SoftshipRatingRequest.ValueUnit getWeightKilogram(
    FreightDetail__c freightDetail,
    String measureUnit
  ) {
    CC_SoftshipRatingRequest.ValueUnit weightKilogram = new CC_SoftshipRatingRequest.ValueUnit();
    weightKilogram.Value = freightDetail.Declared_Weight_Value__c;
    weightKilogram.Unit = getWeightUnit(measureUnit);
    return weightKilogram;
  }

  private static Integer getWeightUnit(String measureUnit) {
    // 0=cm; 1=m; 2=km; 3=ft; 4=inch
    //0 =Kilogram; 1= ton; 2= lbs
    Integer unit = 0;
    if (String.isNotBlank(measureUnit)) {
      if (measureUnit == 'lb/ft' || measureUnit == 'lb') {
        unit = 2;
      } else if (measureUnit == 'kg/m' || measureUnit == 'kg') {
        unit = 0;
      }
    }

    return unit;
  }

  /*private static CC_SoftshipRatingRequest.ValueUnit getNetWeightKilogram(FreightDetail__c freightDetail){
        CC_SoftshipRatingRequest.ValueUnit valueUnit = new CC_SoftshipRatingRequest.ValueUnit();
        valueUnit.Value = 0.00;
        valueUnit.Unit = 0;
        return valueUnit;
    }*/

  private static List<CC_SoftshipRatingRequest.Cargo> getContainerCargoListContainer(
    CC_BookingWrapper.RequirementWrapper requirementWrapper,
    Boolean isHazardous
  ) {
    System.debug('---->>' + requirementWrapper);
    Integer runningNumber = 1;
    List<CC_SoftshipRatingRequest.Cargo> cargoList = new List<CC_SoftshipRatingRequest.Cargo>();
    while (runningNumber <= requirementWrapper.requirement.Quantity__c) {
      CC_SoftshipRatingRequest.Cargo cargo = new CC_SoftshipRatingRequest.Cargo();

      //Rating API Change 16/12/2020
      CC_SoftshipRatingRequest.CargoId CargoId = new CC_SoftshipRatingRequest.CargoId();
      CargoId.CargoRunningNumber = runningNumber;
      cargo.Id = CargoId;
      //cargo.Id= new Map<String,Integer>{'ContainerRunningNumber'=>runningNumber};
      //Rating API Change 16/12/2020

      CC_SoftshipRatingRequest.KindOfPackage kindOfPackage = new CC_SoftshipRatingRequest.KindOfPackage();
      kindOfPackage.Code = requirementWrapper.containerType;
      cargo.KindOfPackage = kindOfPackage;
      cargo.Commodity = getCommodity(requirementWrapper);
      cargo.ContainerType = getContainerType(requirementWrapper);
      cargo.LoadingType = getLoadingType(requirementWrapper);
      cargo.NumberOfPackage = getNumberOfPackage(requirementWrapper);
      cargo.OperationalStatus = getOperationalStatus();
      cargo.DescriptionOfGoods = '';
      cargo.IsEmpty = requirementWrapper.requirement.Is_Empty__c;
      cargo.IsShippersOwn = requirementWrapper.requirement.IsShippersOwn__c;
      if (cargo.IsShippersOwn) {
        cargo.ContainerNumber = requirementWrapper.requirement.Shipper_Owned_Equipment_Number__c;
      } else {
        cargo.ContainerNumber = '';
      }
      cargo.IsHeavy = requirementWrapper.requirement.IsHeavy__c;
      CC_SoftshipRatingRequest.Reefer reefer = new CC_SoftshipRatingRequest.Reefer();
      reefer.IsNonOperative = requirementWrapper.requirement.IsNonOperativeReefer__c;
      cargo.Reefer = reefer;

      CC_SoftshipRatingRequest.ValueUnit weightKilogram = new CC_SoftshipRatingRequest.ValueUnit();
      weightKilogram.Value = 0.00;
      weightKilogram.Unit = 0;
      cargo.WeightKilogram = weightKilogram;

      CC_SoftshipRatingRequest.ValueUnit grossValueUnit = new CC_SoftshipRatingRequest.ValueUnit();
      if (requirementWrapper.requirement.Weight__c != null) {
        grossValueUnit.Value = requirementWrapper.requirement.Weight__c;
        grossValueUnit.Unit = getWeightUnit(
          requirementWrapper.requirement.Weights_Unit_of_Measure__c
        );
      } else {
        grossValueUnit.Value = 0.00;
        grossValueUnit.Unit = 0;
      }
      cargo.CargoGrossWeight = grossValueUnit;

      CC_SoftshipRatingRequest.ValueUnit netValueUnit = new CC_SoftshipRatingRequest.ValueUnit();
      netValueUnit.Value = 0.00;
      netValueUnit.Unit = 0;
      cargo.CargoNetWeight = netValueUnit;
      if (requirementWrapper.requirement.OutOfGauge__c) {
        cargo.OutOfGauge = getOutOfGauge(requirementWrapper);
      } else {
        cargo.OutOfGauge = null;
      }
      if (isHazardous) {
        cargo.Imdg = getImdg(requirementWrapper);
      }
      //cargo.Imdg=getImdg();
      cargoList.add(cargo);
      runningNumber++;
    }
    return cargoList;
  }

  private static CC_SoftshipRatingRequest.OutOfGauge getOutOfGauge(
    CC_BookingWrapper.RequirementWrapper requirementWrapper
  ) {
    CC_SoftshipRatingRequest.OutOfGauge outOfGauge = new CC_SoftshipRatingRequest.OutOfGauge();
    outOfGauge.RequestNumber = '';
    outOfGauge.LostSlots = 0;
    outOfGauge.Top = getOutOfGaugeUnitValue(0, 0);
    outOfGauge.Left = getOutOfGaugeUnitValue(0, 0);
    outOfGauge.Right = getOutOfGaugeUnitValue(0, 0);
    outOfGauge.Front = getOutOfGaugeUnitValue(0, 0);
    outOfGauge.Door = getOutOfGaugeUnitValue(1, 3);
    return outOfGauge;
  }

  private static CC_SoftshipRatingRequest.ValueUnit getOutOfGaugeUnitValue(
    Decimal value,
    Integer unit
  ) {
    CC_SoftshipRatingRequest.ValueUnit valueUnit = new CC_SoftshipRatingRequest.ValueUnit();
    valueUnit.Value = value;
    valueUnit.Unit = Unit;
    return valueUnit;
  }

  private static CC_SoftshipRatingRequest.Commodity getCommodity(
    CC_BookingWrapper.RequirementWrapper requirementWrapper
  ) {
    CC_SoftshipRatingRequest.Commodity commodity = new CC_SoftshipRatingRequest.Commodity();
    commodity.Code = (requirementWrapper.commodityCode != null &&
      requirementWrapper.commodityCode != '')
      ? requirementWrapper.commodityCode
      : '';
    commodity.DescriptionOfGoods = (requirementWrapper.commodityDesc != null &&
      requirementWrapper.commodityDesc != '')
      ? requirementWrapper.commodityDesc
      : '';
    return commodity;
  }

  private static CC_SoftshipRatingRequest.ContainerType getContainerType(
    CC_BookingWrapper.RequirementWrapper requirementWrapper
  ) {
    CC_SoftshipRatingRequest.ContainerType containerType = new CC_SoftshipRatingRequest.ContainerType();
    containerType.IsReefer = requirementWrapper.requirement.Running_Reefer__c;
    containerType.ContainerTypeCode = getContainerTypeCode(requirementWrapper);
    return containerType;
  }

  private static CC_SoftshipRatingRequest.ContainerTypeCode getContainerTypeCode(
    CC_BookingWrapper.RequirementWrapper requirementWrapper
  ) {
    CC_SoftshipRatingRequest.ContainerTypeCode containerTypeCode = new CC_SoftshipRatingRequest.ContainerTypeCode();
    containerTypeCode.Code = requirementWrapper.containerType;
    containerTypeCode.Description = requirementWrapper.containerDesc;
    return containerTypeCode;
  }

  private static CC_SoftshipRatingRequest.LoadingType getLoadingType(
    CC_BookingWrapper.RequirementWrapper requirementWrapper
  ) {
    CC_SoftshipRatingRequest.LoadingType loadingType = new CC_SoftshipRatingRequest.LoadingType();
    loadingType.Code = requirementWrapper.requirement.Is_Empty__c != null &&
      requirementWrapper.requirement.Is_Empty__c
      ? CC_SoftshipRatingConstant.STR_E
      : CC_SoftshipRatingConstant.STR_F;
    return loadingType;
  }

  private static Map<String, Decimal> getNumberOfPackage(
    CC_BookingWrapper.RequirementWrapper requirementWrapper
  ) {
    Map<String, Decimal> numberOfPackage = new Map<String, Decimal>();
    //numberOfPackage.put('Number', requirementWrapper.requirement.Quantity__c);
    numberOfPackage.put('Number', 1.0);
    return numberOfPackage;
  }

  private static CC_SoftshipRatingRequest.OperationalStatus getOperationalStatus() {
    CC_SoftshipRatingRequest.OperationalStatus operationalStatus = new CC_SoftshipRatingRequest.OperationalStatus();
    operationalStatus.Status = CC_SoftshipRatingConstant.STR_A;
    return operationalStatus;
  }

  private static CC_SoftshipRatingRequest.Imdg getImdg(
    CC_BookingWrapper.RequirementWrapper requirementWrapper
  ) {
    CC_SoftshipRatingRequest.Imdg imdg = new CC_SoftshipRatingRequest.Imdg();
    CC_SoftshipRatingRequest.Code setCode = new CC_SoftshipRatingRequest.Code();
    if (requirementWrapper.requirement.IMDG_Class__c == '') {
      setCode.code = '2.1';
    } else {
      setCode.code = requirementWrapper.requirement.IMDG_Class__c;
    }
    imdg.ClassCode = setCode;
    return imdg;
  }
}
