public without sharing class CC_BOLUtil {
  public static Bill_Of_Lading__c setLocationPointOfOrigin(
    Bill_Of_Lading__c billOfLadding,
    Booking__c booking,
    Shipment__c shipment
  ) {
    //Setting location -
    if (
      String.isNotBlank(booking.Description__c) &&
      (booking.Description__c.startsWith('D') ||
      booking.Description__c.startsWith('R'))
    ) {
      billOfLadding.Point_Of_Origin_Country__c = booking.Customer_Origin_Country__c;
      billOfLadding.Point_Of_Origin_State__c = booking.Customer_Origin_State__c;
    } else if (
      String.isNotBlank(booking.Description__c) &&
      booking.Description__c.startsWith('P')
    ) {
      billOfLadding.Point_Of_Origin_Country__c = shipment.Origin_Country__c;
      billOfLadding.Point_Of_Origin_State__c = shipment.Origin_State__c;
      billOfLadding.Point_Of_Origin_Description__c = shipment.Origin_Code__c;
    }
    return billOfLadding;
  }

  public static String getLocationType(String strToken) {
    String locationType = '';
    if (strToken == 'D') {
      locationType = 'DOOR';
    } else if (strToken == 'R') {
      locationType = 'RAIL RAMP';
    } else if (strToken == 'P') {
      locationType = 'PORT';
    }
    return locationType;
  }

  public static Bill_Of_Lading__c setLocationPlaceOfReceipt(
    Bill_Of_Lading__c billOfLadding,
    Booking__c booking,
    Shipment__c shipment
  ) {
    //Setting location -
    if (
      String.isNotBlank(booking.Description__c) &&
      (booking.Description__c.startsWith('R'))
    ) {
      billOfLadding.Place_Of_Receipt__c = booking.Customer_Origin_Code__c;
      billOfLadding.Place_Of_Receipt_Country__c = booking.Customer_Origin_Country__c;
      billOfLadding.Place_Of_Receipt_State__c = booking.Customer_Origin_State__c;
      billOfLadding.Place_of_Receipt_Location_Type__c = getLocationType(
        booking.Description__c.subString(0, 1)
      );
    } else if (
      String.isNotBlank(booking.Description__c) &&
      booking.Description__c.startsWith('D')
    ) {
      if (String.isNotBlank(booking.Customer_Origin_Code__c)) {
        String locType = CC_BOLUtil.getLocationType('D');
        for (Location__c objLocation : [
          SELECT Id, Location_Name__c, Name, Location_Type__c
          FROM Location__c
          WHERE
            (Name = :booking.Customer_Origin_Code__c
            OR LcCode__c = :booking.Customer_Origin_Code__c)
            AND Location_Type__c = :locType
        ]) {
          billOfLadding.Place_Of_Receipt__c = objLocation.Name;
          billOfLadding.Place_Of_Receipt_Country__c = booking.Customer_Origin_Country__c;
          billOfLadding.Place_Of_Receipt_State__c = booking.Customer_Origin_State__c;
          billOfLadding.Place_of_Receipt_Location_Type__c = getLocationType(
            booking.Description__c.subString(0, 1)
          );
        }
      }
    } else if (
      String.isNotBlank(booking.Description__c) &&
      booking.Description__c.startsWith('P')
    ) {
      billOfLadding.Place_Of_Receipt__c = shipment.Origin_Code__c;
      billOfLadding.Place_Of_Receipt_Country__c = shipment.Origin_Country__c;
      billOfLadding.Place_Of_Receipt_State__c = shipment.Origin_State__c;
      billOfLadding.Place_of_Receipt_Location_Type__c = 'PORT';
    }

    return billOfLadding;
  }

  public static Bill_Of_Lading__c setPlaceOfDelivery(
    Bill_Of_Lading__c billOfLadding,
    Booking__c booking,
    Shipment__c shipment
  ) {
    billOfLadding.Place_of_Delivery_1__c = '';
    if (
      String.isNotBlank(booking.Description__c) &&
      booking.Description__c.endsWith('R')
    ) {
      if (String.isNotBlank(booking.Customer_Destination_Code__c)) {
        String locType = CC_BOLUtil.getLocationType('R');
        for (Location__c objLocation : [
          SELECT Id, Location_Name__c, Name, Location_Type__c
          FROM Location__c
          WHERE
            Name = :booking.Customer_Destination_Code__c
            AND Location_Type__c = :locType
        ]) {
          billOfLadding.Place_of_Delivery_1__c =
            objLocation.Location_Type__c +
            ' - ' +
            objLocation.Location_Name__c +
            ' (' +
            objLocation.Name +
            ')';
        }
      }
    } else if (
      String.isNotBlank(booking.Description__c) &&
      booking.Description__c.endsWith('D')
    ) {
      if (String.isNotBlank(booking.Customer_Destination_Code__c)) {
        String locType = CC_BOLUtil.getLocationType('D');
        for (Location__c objLocation : [
          SELECT Id, Location_Name__c, Name, Location_Type__c
          FROM Location__c
          WHERE
            (Name = :booking.Customer_Destination_Code__c
            OR LcCode__c = :booking.Customer_Destination_Code__c)
            AND Location_Type__c = :locType
        ]) {
          billOfLadding.Place_of_Delivery_1__c =
            objLocation.Location_Type__c +
            ' - ' +
            objLocation.Location_Name__c +
            ' (' +
            objLocation.Name +
            ')';
        }
      }
    } else if (
      String.isNotBlank(booking.Description__c) &&
      booking.Description__c.endsWith('P')
    ) {
      for (
        Location__c objLocation : CC_BOLDAO.getLocation(
          new Map<String, String>{
            'Name' => shipment.Destination_Code__c,
            'Location_Type__c' => 'PORT'
          }
        )
      ) {
        billOfLadding.Place_of_Delivery_1__c =
          objLocation.Location_Type__c +
          ' - ' +
          objLocation.Location_Name__c +
          ' (' +
          objLocation.Name +
          ')';
      }
    }
    return billOfLadding;
  }
}
