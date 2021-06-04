/*
 * @company        : Nagarro Inc.
 * @date           : 25-04-2020
 * @author         : Nagarro
 * @description    : To get booking and related objects records
 * @history        : Version 1.0
 * @test class     : CrowleyBookRecDetCtrlTest
 */
public without sharing class CrowleyBookRecDetCtrl {
  /*
   * @purpose      : Method to get section wise booking data(booking sub sections and child objects)
   * @parameter    : bookingId - Id of the booking records
   * @return       : Map of section name --> (list of (map of field label --> field value))
   */

  @AuraEnabled
  public static Map<String, List<Map<String, String>>> getBookingDetail(
    Id bookingId,
    String selectedMenu
  ) {
    try {
      Map<String, List<Map<String, String>>> sectionNameVsFieldLabelValue = new Map<String, List<Map<String, String>>>();
      Map<String, Map<String, String>> sectionNameVsFieldsList = getFieldsDefinition();
      Map<List<Id>, List<Map<String, String>>> shipmentIdsDataMap = new Map<List<Id>, List<Map<String, String>>>();
      Map<List<Id>, List<Map<String, String>>> freightDetailIdsDataMap = new Map<List<Id>, List<Map<String, String>>>();
      Map<List<Id>, List<Map<String, String>>> requirementIdsDataMap = new Map<List<Id>, List<Map<String, String>>>();
      Map<List<Id>, List<Map<String, String>>> transportIdsDataMap = new Map<List<Id>, List<Map<String, String>>>();
      List<Id> bookingIds = new List<Id>();
      List<Id> shippingIds = new List<Id>();
      List<Id> freightDetailIds = new List<Id>();
      List<Id> requirementIds = new List<Id>();
      List<Id> transportIds = new List<Id>();

      bookingIds.add(bookingId);
      if (selectedMenu.equalsIgnoreCase('details')) {
        sectionNameVsFieldLabelValue.put(
          'Booking',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFields',
              'Booking_Detail_Internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingServiceType',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsServiceType',
              'Service_Type_Detail_Internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingIMType',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsIMType',
              'IM_Type_Detail_Internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingTMSType',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsTMSType',
              'TMS_Type_Detail_Internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingCustomerOrigin',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsCustomerOrigin',
              'Customer_Origin_Detail_Internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingCustomerDestination',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsCustomerDestination',
              'Customer_Destination_Detail_Internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingConnectingCarrier',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsConnectingCarrier',
              'Connecting_Carrier_Detail_Internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingConnectAtLoc',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsConnectAtLoc',
              'Connect_At_Loc_Detail_internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
        sectionNameVsFieldLabelValue.put(
          'BookingConnectToLoc',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingFieldsConnectToLoc',
              'Connect_To_Loc_Detail_internal',
              'Booking__c',
              bookingIds,
              'NA'
            ))
            .values())[0]
        );
      }
      if (selectedMenu.equalsIgnoreCase('parties')) {
        sectionNameVsFieldLabelValue.put(
          'Party',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'partyFields',
              'Party_Detail_Internal',
              'Party__c',
              bookingIds,
              'Booking__c'
            ))
            .values())[0]
        );
      }
      if (selectedMenu.equalsIgnoreCase('bookingRemarks')) {
        sectionNameVsFieldLabelValue.put(
          'BookingRemark',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'bookingRemarkFields',
              'Booking_Remarks_Detail_Internal',
              'Booking_Remark__c',
              bookingIds,
              'Booking__c'
            ))
            .values())[0]
        );
      }
      if (
        selectedMenu.equalsIgnoreCase('shipment') ||
        selectedMenu.equalsIgnoreCase('customerNotifications') ||
        selectedMenu.equalsIgnoreCase('voyages') ||
        selectedMenu.equalsIgnoreCase('dockReceipts') ||
        selectedMenu.equalsIgnoreCase('freightDetails') ||
        selectedMenu.equalsIgnoreCase('commodities') ||
        selectedMenu.equalsIgnoreCase('equipments') ||
        selectedMenu.equalsIgnoreCase('requirements')
      ) {
        shipmentIdsDataMap = getSectionWiseData(
          sectionNameVsFieldsList,
          'shipmentFields',
          'Shipment_Detail_Internal',
          'Shipment__c',
          bookingIds,
          'Booking__c'
        );
        sectionNameVsFieldLabelValue.put(
          'Shipment',
          (shipmentIdsDataMap.values())[0]
        );
        for (List<id> ids : shipmentIdsDataMap.keySet()) {
          shippingIds.addAll(ids);
        }
      }
      if (selectedMenu.equalsIgnoreCase('customerNotifications')) {
        sectionNameVsFieldLabelValue.put(
          'CustomerNotification',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'customerNotificationFields',
              'Customer_Notification_Detail_Internal',
              'Customer_Notification__c',
              shippingIds,
              'Shipment__c'
            ))
            .values())[0]
        );
      }
      if (selectedMenu.equalsIgnoreCase('voyages')) {
        sectionNameVsFieldLabelValue.put(
          'Voyage',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'voyageFields',
              'Voyage_Detail_Internal',
              'Voyage__c',
              shippingIds,
              'Shipment__c'
            ))
            .values())[0]
        );
      }
      if (selectedMenu.equalsIgnoreCase('dockReceipts')) {
        sectionNameVsFieldLabelValue.put(
          'DockReceipt',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'dockReceiptFields',
              'Dock_Receipt_Detail_Internal',
              'Dock_Receipt__c',
              shippingIds,
              'Shipment__c'
            ))
            .values())[0]
        );
      }
      if (
        selectedMenu.equalsIgnoreCase('freightDetails') ||
        selectedMenu.equalsIgnoreCase('commodities') ||
        selectedMenu.equalsIgnoreCase('requirements') ||
        selectedMenu.equalsIgnoreCase('equipments')
      ) {
        freightDetailIdsDataMap = getSectionWiseData(
          sectionNameVsFieldsList,
          'freightDetailFields',
          'Freight_Detail_Internal',
          'FreightDetail__c',
          shippingIds,
          'Shipment__c'
        );
        sectionNameVsFieldLabelValue.put(
          'FreightDetail',
          (freightDetailIdsDataMap.values())[0]
        );
        for (List<id> ids : freightDetailIdsDataMap.keySet()) {
          freightDetailIds.addAll(ids);
        }
      }
      if (selectedMenu.equalsIgnoreCase('commodities')) {
        sectionNameVsFieldLabelValue.put(
          'Commodity',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'commodityFields',
              'Commodity_Detail_Internal',
              'Commodity__c',
              freightDetailIds,
              'Freight__c'
            ))
            .values())[0]
        );
      }
      if (
        selectedMenu.equalsIgnoreCase('requirements') ||
        selectedMenu.equalsIgnoreCase('equipments')
      ) {
        requirementIdsDataMap = getSectionWiseData(
          sectionNameVsFieldsList,
          'requirementFields',
          'Requirement_Detail_Internal',
          'Requirement__c',
          freightDetailIds,
          'Freight__c'
        );
        sectionNameVsFieldLabelValue.put(
          'Requirement',
          (requirementIdsDataMap.values())[0]
        );
        for (List<id> ids : requirementIdsDataMap.keySet()) {
          requirementIds.addAll(ids);
        }
      }
      if (selectedMenu.equalsIgnoreCase('equipments')) {
        sectionNameVsFieldLabelValue.put(
          'Equipment',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'equipmentFields',
              'Equipment_Detail_Internal',
              'Equipment__c',
              requirementIds,
              'Requirement__c'
            ))
            .values())[0]
        );
      }
      if (
        selectedMenu.equalsIgnoreCase('transports') ||
        selectedMenu.equalsIgnoreCase('stops')
      ) {
        transportIdsDataMap = getSectionWiseData(
          sectionNameVsFieldsList,
          'transportFields',
          'Transport_Detail_Internal',
          'Transport__c',
          bookingIds,
          'Booking__c'
        );
        sectionNameVsFieldLabelValue.put(
          'Transport',
          (transportIdsDataMap.values())[0]
        );

        for (List<id> ids : transportIdsDataMap.keySet()) {
          transportIds.addAll(ids);
        }
      }
      if (selectedMenu.equalsIgnoreCase('stops')) {
        sectionNameVsFieldLabelValue.put(
          'Stop',
          ((getSectionWiseData(
              sectionNameVsFieldsList,
              'stopFields',
              'Stop_Detail_Internal',
              'Stop__c',
              transportIds,
              'Transport__c'
            ))
            .values())[0]
        );
      }
      return sectionNameVsFieldLabelValue;
    } catch (Exception ex) {
      return null;
    }
  }

  /*
   * @purpose      : Method to get query in string format containing fields in the fieldset
   * @parameter    : fieldMemberList - List of fields(with description) in the fieldset
   * @parameter    : objectAPIName - API name of the object containing the fieldset
   * @return       : Query in string format
   */

  private static String getStringQuery(
    List<Schema.FieldSetMember> fieldMemberList,
    String objectAPIName
  ) {
    String strQuery = 'select id ,';
    for (Schema.FieldSetMember fieldMember : fieldMemberList) {
      if (fieldMember.getType() == Schema.DisplayType.Picklist) {
        strQuery += 'toLabel(' + fieldMember.getFieldPath() + '),';
      } else {
        strQuery += fieldMember.getFieldPath() + ',';
      }
    }
    strQuery = strQuery.substring(0, strQuery.length() - 1);
    strQuery += ' from ' + objectAPIName;
    return strQuery;
  }

  /*
   * @purpose      : Method to get fields in the fieldset
   * @parameter    : fieldSetName - Name of the fieldsSet
   * @parameter    : ObjectName - Name of the object containing the fieldset
   * @return       : List of fields(with description) in the fieldset
   */

  private static List<Schema.FieldSetMember> readFieldSet(
    String fieldSetName,
    String ObjectName
  ) {
    Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe()
      .get(ObjectName)
      .getDescribe();
    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap()
      .get(fieldSetName);
    return fieldSetObj.getFields();
  }

  /*
   * @purpose      : Method to get data section wise from grand child objects of Booking object
   * @parameter    : sectionNameVsFieldsList - Map of (sectionName)-->(Map of(FieldAPIName --> Field Label))
   * @parameter    : sectionName - Name of the section(grand child of booking obj)
   * @parameter    : fieldSetName - Name of the fieldset
   * @parameter    : objectAPIName - API name of the object
   * @parameter    : parentIdsList - List of ids of the parent records
   * @parameter    : parentObjectRelationName - Relationship API name  (NA in case of booking object)
   * @return       : List of Map of(field label and field value)
   */

  private static Map<List<Id>, List<Map<String, String>>> getSectionWiseData(
    Map<String, Map<String, String>> sectionNameVsFieldsList,
    String sectionName,
    String fieldSetName,
    String objectAPIName,
    List<Id> parentIdsList,
    String parentObjectRelationName
  ) {
    try {
      Map<List<Id>, List<Map<String, String>>> idListRecordDataMap = new Map<List<Id>, List<Map<String, String>>>();
      Map<String, String> fieldNameVsFieldValue = new Map<String, String>();
      List<Map<String, String>> objectRecordsLabelValueList = new List<Map<String, String>>();
      List<Id> sectionIds = new List<Id>();
      String queryString;
      if (parentObjectRelationName == 'NA')
        queryString =
          getStringQuery(
            readFieldSet(fieldSetName, objectAPIName),
            objectAPIName
          ) + ' where id IN : parentIdsList';
      else
        queryString =
          getStringQuery(
            readFieldSet(fieldSetName, objectAPIName),
            objectAPIName
          ) +
          ' where ' +
          parentObjectRelationName +
          ' IN  : parentIdsList';
      List<sObject> queryResult = (Database.query(queryString));
      Map<String, Schema.SObjectField> mFields = Schema.getGlobalDescribe()
        .get(objectAPIName)
        .getDescribe()
        .fields.getMap();
      for (sObject objRec : queryResult) {
        sectionIds.add(objRec.id);
        fieldNameVsFieldValue = new Map<String, String>();
        for (String field : sectionNameVsFieldsList.get(sectionName).keySet()) {
          Object value = objRec.get(field);
          if (value != null)
            fieldNameVsFieldValue.put(
              sectionNameVsFieldsList.get(sectionName).get(field),
              getDisplayValue(value, mFields, field)
            );
          if (value == null)
            fieldNameVsFieldValue.put(
              sectionNameVsFieldsList.get(sectionName).get(field),
              ''
            );
        }
        objectRecordsLabelValueList.add(fieldNameVsFieldValue);
      }
      idListRecordDataMap.put(sectionIds, objectRecordsLabelValueList);
      return idListRecordDataMap;
    } catch (Exception e) {
      return null;
    }
  }

  /*
   * @purpose      : Method to format the value of the field
   * @parameter    : value - Value of the field
   * @parameter    : objectAPIName - Name of the object
   * @parameter    : field - Name of the field
   * @return       : Formatted value in String form
   */
  private static String getDisplayValue(
    Object value,
    Map<String, Schema.SObjectField> mFields,
    String field
  ) {
    if (String.valueOf(value) == 'false')
      return 'No';
    else if (String.valueOf(value) == 'true')
      return 'Yes';
    Schema.SObjectField fieldDesc = mFields.get(field);
    if (fieldDesc.getDescribe().getType() == Schema.DisplayType.Date) {
      System.debug('Inside date criteria');
      Date dt = Date.valueOf(value);
      String sDt = dt.day() + '/' + dt.month() + '/' + dt.year();
      return sDt;
    } else {
      return String.valueOf(value);
    }
  }

  /*
   * @purpose      : Method to get field label for the corresponding field API Name for all the sections
   * @return       : Map of (Section Name --> (Map of(fieldAPIName --> fieldLabel)))
   */
  private static Map<String, Map<String, String>> getFieldsDefinition() {
    try {
      Map<String, Map<String, String>> sectionNameVsFieldsList = new Map<String, Map<String, String>>();
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Booking_Detail_Internal',
          'Booking__c',
          'bookingFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Service_Type_Detail_Internal',
          'Booking__c',
          'bookingFieldsServiceType'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'IM_Type_Detail_Internal',
          'Booking__c',
          'bookingFieldsIMType'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'TMS_Type_Detail_Internal',
          'Booking__c',
          'bookingFieldsTMSType'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Customer_Origin_Detail_Internal',
          'Booking__c',
          'bookingFieldsCustomerOrigin'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Customer_Destination_Detail_Internal',
          'Booking__c',
          'bookingFieldsCustomerDestination'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Connecting_Carrier_Detail_Internal',
          'Booking__c',
          'bookingFieldsConnectingCarrier'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Connect_At_Loc_Detail_internal',
          'Booking__c',
          'bookingFieldsConnectAtLoc'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Connect_To_Loc_Detail_internal',
          'Booking__c',
          'bookingFieldsConnectToLoc'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel('Party_Detail_Internal', 'Party__c', 'partyFields')
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Transport_Detail_Internal',
          'Transport__c',
          'transportFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Booking_Remarks_Detail_Internal',
          'Booking_Remark__c',
          'bookingRemarkFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Shipment_Detail_Internal',
          'Shipment__c',
          'shipmentFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Dock_Receipt_Detail_Internal',
          'Dock_Receipt__c',
          'dockReceiptFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Customer_Notification_Detail_Internal',
          'Customer_Notification__c',
          'customerNotificationFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel('Voyage_Detail_Internal', 'Voyage__c', 'voyageFields')
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Freight_Detail_Internal',
          'FreightDetail__c',
          'freightDetailFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Commodity_Detail_Internal',
          'Commodity__c',
          'commodityFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Requirement_Detail_Internal',
          'Requirement__c',
          'requirementFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel(
          'Equipment_Detail_Internal',
          'Equipment__c',
          'equipmentFields'
        )
      );
      sectionNameVsFieldsList.putAll(
        getFieldNameLabel('Stop_Detail_Internal', 'Stop__c', 'stopFields')
      );
      return sectionNameVsFieldsList;
    } catch (Exception ex) {
      return null;
    }
  }
  /*
   * @purpose      : Method to get field label for the corresponding field API Names present in the fieldset of the object
   * @parameter    : fieldSetName - Name of the fieldset
   * @parameter    : ObjectName - Name of the object
   * @parameter    : sectionName - Name of the booking subsection or child object section.
   * @return       : Map of (Section Name --> (Map of(fieldAPIName --> fieldLabel)))
   */
  private static Map<String, Map<String, String>> getFieldNameLabel(
    String fieldSetName,
    String ObjectName,
    String sectionName
  ) {
    Map<String, Map<String, String>> secNameVsField = new Map<String, Map<String, String>>();
    List<Schema.FieldSetMember> fieldMemberList = readFieldSet(
      fieldSetName,
      ObjectName
    );
    Map<String, String> fieldNameLabelMap = new Map<String, String>();
    for (Schema.FieldSetMember fieldMember : fieldMemberList) {
      fieldNameLabelMap.put(fieldMember.getFieldPath(), fieldMember.getLabel());
    }
    if (fieldNameLabelMap != null && !fieldNameLabelMap.isEmpty()) {
      secNameVsField.put(sectionName, fieldNameLabelMap);
    }
    return secNameVsField;
  }
}
