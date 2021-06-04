global class GetTaskAttachemnt {
  @AuraEnabled
  public static Case getHaciendaChecked(string caseId) {
    system.debug(caseId);
    case ca = [
      SELECT
        Id,
        Ha__c,
        Hacienda_Mail_Sent__c,
        Destination_Approval__c,
        Case_Thread_Id__c,
        Summary_BR__c,
        System_Filed_In__c,
        Effective_Date__c,
        Contract_Number__c,
        RecordType.Name,
        ContactId,
        Contact.Name,
        AccountId,
        Account.Name,
        CaseNumber,
        Consignee_Name__c,
        Consignee_Name__r.Name,
        Shipper_Name__c,
        Shipper_Name__r.Name,
        CreatedById,
        CreatedBy.Email
      FROM case
      WHERE Id = :caseId
      LIMIT 1
    ];
    system.debug(ca);
    return ca;
  }

  @AuraEnabled
  public static string getTaskAttachmentList(Id caseId) {
    //get all attachment list of tasks
    system.debug(caseId);
    List<Case> caseAttachmentList = [
      SELECT
        Id,
        (SELECT Id FROM EmailMessages),
        (
          SELECT Id, ContentDocumentId, ContentDocument.Title
          FROM AttachedContentDocuments
        ),
        (SELECT Id, Name FROM Attachments)
      FROM Case
      WHERE Id = :caseId
    ];
    list<attachmentList> li = new List<attachmentList>();
    list<string> emailMessageId = new List<string>();
    for (Case c : caseAttachmentList) {
      for (EmailMessage e : c.EmailMessages) {
        emailMessageId.add(e.Id);
      }
    }
    list<EmailMessage> EmailMessageAttachments = [
      SELECT
        Id,
        (
          SELECT Id, ContentDocumentId, ContentDocument.Title
          FROM AttachedContentDocuments
        )
      FROM EmailMessage
      WHERE Id IN :emailMessageId
    ];
    for (Case c : caseAttachmentList) {
      System.debug('attachment -> ' + c);
      for (AttachedContentDocument a : c.AttachedContentDocuments) {
        li.add(
          new attachmentList(a.ContentDocumentId, a.ContentDocument.Title)
        ); //t.Id,
      }
      for (Attachment a : c.Attachments) {
        li.add(new attachmentList(a.Id, a.Name));
      }
    }
    for (EmailMessage e : EmailMessageAttachments) {
      for (AttachedContentDocument a : e.AttachedContentDocuments) {
        li.add(
          new attachmentList(a.ContentDocumentId, a.ContentDocument.Title)
        ); //t.Id,
      }
    }
    system.debug(caseAttachmentList);
    system.debug(li);
    return JSON.serialize(li);
  }
  public static map<string, string> mergeFields(Case caseRec) {
    map<string, string> mergeFieldMapping = new Map<string, string>();
    mergeFieldMapping.put(
      '{!Case.Summary_BR__c}',
      (caseRec.Summary_BR__c != null ? caseRec.Summary_BR__c : '')
    );
    mergeFieldMapping.put('{!Case.Thread_Id}', '');
    mergeFieldMapping.put('{!Case.Case_Thread_Id__c}', '');
    mergeFieldMapping.put(
      '{!Case.CaseNumber}',
      (caseRec.CaseNumber != null ? caseRec.CaseNumber : '')
    );
    mergeFieldMapping.put(
      '{!Case.Contact}',
      (caseRec.Contact.Name != null ? caseRec.Contact.Name : '')
    );
    mergeFieldMapping.put(
      '{!Case.BOL_Number__c}',
      (caseRec.BOL_Number__c != null
        ? caseRec.BOL_Number__c.subString(0, 12)
        : '')
    );
    mergeFieldMapping.put(
      '{!Case.Booking__c}',
      (caseRec.Booking__c != null ? caseRec.Booking__c : '')
    );
    mergeFieldMapping.put(
      '{!Case.Consignee_Name__c}',
      (caseRec.Consignee_Name__r.Name != null
        ? caseRec.Consignee_Name__r.Name
        : '')
    );
    mergeFieldMapping.put(
      '{!Case.Shipper_Name__c}',
      (caseRec.Shipper_Name__r.Name != null ? caseRec.Shipper_Name__r.Name : '')
    );
    /*mergeFieldMapping.put('{!Case.Account}',(caseRec.Account.Name!=null?caseRec.Account.Name:''));
        mergeFieldMapping.put('{!Case.RecordType}',(caseRec.RecordType.Name!=null?caseRec.RecordType.Name:''));
        mergeFieldMapping.put('{!Case.Subject}',(caseRec.Subject!=null?caseRec.Subject:''));
        mergeFieldMapping.put('{!Case.Description}',(caseRec.Description!=null?caseRec.Description:''));
        mergeFieldMapping.put('{!Case.SuppliedEmail}',(caseRec.SuppliedEmail!=null?caseRec.SuppliedEmail:''));
        mergeFieldMapping.put('{!Case.Additional_Comments_details_instructions__c}',(caseRec.Additional_Comments_details_instructions__c!=null?caseRec.Additional_Comments_details_instructions__c:''));
        mergeFieldMapping.put('{!Case.Bill_to_Party__c}}',(caseRec.Bill_to_Party__r.Name!=null?caseRec.Bill_to_Party__r.Name:''));
        mergeFieldMapping.put('{!Case.Booked_Temperature__c}',(caseRec.Booked_Temperature__c!=null?String.valueOf(caseRec.Booked_Temperature__c):''));
        mergeFieldMapping.put('{!Case.Booking_Number__c}',(caseRec.Booking_Number__c!=null?caseRec.Booking_Number__c:''));
        mergeFieldMapping.put('{!Case.Cargo_Available_Date__c}',(caseRec.Cargo_Available_Date__c!=null?String.valueOf(caseRec.Cargo_Available_Date__c):''));
        mergeFieldMapping.put('{!Case.Comments__c}',(caseRec.Comments__c!=null?caseRec.Comments__c:''));
        mergeFieldMapping.put('{!Case.Frequency_Comments__c}',(caseRec.Frequency_Comments__c!=null?caseRec.Frequency_Comments__c:''));
        mergeFieldMapping.put('{!Case.Comments_on_Pricing_Rating_Issue__c}',(caseRec.Comments_on_Pricing_Rating_Issue__c!=null?caseRec.Comments_on_Pricing_Rating_Issue__c:''));
        mergeFieldMapping.put('{!Case.Container_Number__c}',(caseRec.Container_Number__c!=null?caseRec.Container_Number__c:''));
        mergeFieldMapping.put('{!Case.Container_Status__c}',(caseRec.Container_Status__c!=null?caseRec.Container_Status__c:''));
        mergeFieldMapping.put('{!Case.Container_Type__c}',(caseRec.Container_Type__c!=null?caseRec.Container_Type__c:''));
        mergeFieldMapping.put('{!Case.Contract_Number__c}',(caseRec.Contract_Number__c!=null?caseRec.Contract_Number__c:''));
        mergeFieldMapping.put('{!Case.Correct_Date_to_Use__c}',(caseRec.Correct_Date_to_Use__c!=null?String.valueOf(caseRec.Correct_Date_to_Use__c):''));
        mergeFieldMapping.put('{!Case.Corrected_Contract_Number__c}',(caseRec.Corrected_Contract_Number__c!=null?caseRec.Corrected_Contract_Number__c:''));
        mergeFieldMapping.put('{!Case.Correct_temperature__c}',(caseRec.Correct_temperature__c!=null?caseRec.Correct_temperature__c:''));
        mergeFieldMapping.put('{!Case.Correct_TLI_to_Use__c}',(caseRec.Correct_TLI_to_Use__c!=null?String.Valueof(caseRec.Correct_TLI_to_Use__c):''));
        mergeFieldMapping.put('{!Case.Customer_Email__c}',(caseRec.Customer_Email__c!=null?caseRec.Customer_Email__c:''));
        mergeFieldMapping.put('{!Case.Booking_Destination__c}',(caseRec.Booking_Destination__c!=null?caseRec.Booking_Destination__c:''));
        mergeFieldMapping.put('{!Case.Destination_City__c}',(caseRec.Destination_City__c!=null?caseRec.Destination_City__c:''));
        mergeFieldMapping.put('{!Case.Destination_Zipcode__c}',(caseRec.Destination_Zipcode__c!=null?caseRec.Destination_Zipcode__c:''));
        mergeFieldMapping.put('{!Case.Effective_Date__c}',(caseRec.Effective_Date__c!=null?String.Valueof(caseRec.Effective_Date__c):''));
        mergeFieldMapping.put('{!Case.Equipment_Type_Size__c}',(caseRec.Equipment_Type_Size__c!=null?caseRec.Equipment_Type_Size__c:''));
        mergeFieldMapping.put('{!Case.Estimated_arrival_date__c}',(caseRec.Estimated_arrival_date__c!=null?String.Valueof(caseRec.Estimated_arrival_date__c):''));
        mergeFieldMapping.put('{!Case.Estimated_sailing_date__c}',(caseRec.Estimated_sailing_date__c!=null?String.Valueof(caseRec.Estimated_sailing_date__c):''));
        mergeFieldMapping.put('{!Case.External_Customer_Lane_ID__c}',(caseRec.External_Customer_Lane_ID__c!=null?caseRec.External_Customer_Lane_ID__c:''));
        mergeFieldMapping.put('{!Case.FCN_Number__c}',(caseRec.FCN_Number__c!=null?caseRec.FCN_Number__c:''));
        mergeFieldMapping.put('{!Case.Filed_Date__c}',(caseRec.Filed_Date__c!=null?String.Valueof(caseRec.Filed_Date__c):''));
        mergeFieldMapping.put('{!Case.Filed_In_External_System__c}',(caseRec.Filed_In_External_System__c!=null?caseRec.Filed_In_External_System__c:''));*/
    //mergeFieldMapping.put('{!Case.Line_Item_s__c}',(caseRec.Line_Item_s__c!=null?caseRec.Line_Item_s__c:''));
    //mergeFieldMapping.put('{!Case.Market_Segment__c}',(caseRec.Market_Segment__c!=null?caseRec.Market_Segment__c:''));
    //mergeFieldMapping.put('{!Case.New_BOL__c}',(caseRec.New_BOL__c!=null?caseRec.New_BOL__c:''));
    //mergeFieldMapping.put('{!Case.Non_Containerized_Comments__c}',(caseRec.Non_Containerized_Comments__c!=null?caseRec.Non_Containerized_Comments__c:''));
    /*mergeFieldMapping.put('{!Case.Booking_Origin__c}',(caseRec.Booking_Origin__c!=null?caseRec.Booking_Origin__c:''));
        mergeFieldMapping.put('{!Case.Origin_City__c}',(caseRec.Origin_City__c!=null?caseRec.Origin_City__c:''));
        mergeFieldMapping.put('{!Case.Origin_Zipcode__c}',(caseRec.Origin_Zipcode__c!=null?caseRec.Origin_Zipcode__c:''));
        mergeFieldMapping.put('{!Case.Previous_Booking_Number__c}',(caseRec.Previous_Booking_Number__c!=null?caseRec.Previous_Booking_Number__c:''));
        mergeFieldMapping.put('{!Case.Publishing_Owner__c}',(caseRec.Publishing_Owner__c!=null?caseRec.Publishing_Owner__c:''));
        mergeFieldMapping.put('{!Case.Reason_for_hold__c}',(caseRec.Reason_for_hold__c!=null?caseRec.Reason_for_hold__c:''));
        mergeFieldMapping.put('{!Case.Reason_For_Incomplete_Request__c}',(caseRec.Reason_For_Incomplete_Request__c!=null?caseRec.Reason_For_Incomplete_Request__c:''));
        mergeFieldMapping.put('{!Case.Reefer_Temperature__c}',(caseRec.Reefer_Temperature__c!=null?caseRec.Reefer_Temperature__c:''));     
        mergeFieldMapping.put('{!Case.Service__c}',(caseRec.Service__c!=null?caseRec.Service__c:''));*/
    //mergeFieldMapping.put('{!Case.Service_Comments__c}',(caseRec.Service_Comments__c!=null?caseRec.Service_Comments__c:''));
    /*mergeFieldMapping.put('{!Case.Supply_Chain_Services__c}}',(caseRec.Supply_Chain_Services__c!=null?caseRec.Supply_Chain_Services__c:''));
        mergeFieldMapping.put('{!Case.Temperature__c}',(caseRec.Temperature__c!=null?caseRec.Temperature__c:''));
        mergeFieldMapping.put('{!Case.Voyage__c}',(caseRec.Voyage__c!=null?caseRec.Voyage__c:''));*/
    //mergeFieldMapping.put('{!Case.User_Responsible_for_Error__c}',(caseRec.User_Responsible_for_Error__c!=null?caseRec.User_Responsible_for_Error__c:''));
    Schema.DescribeFieldResult fieldResult = Case.Destination_Country__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry p : ple) {
      if (
        caseRec.Destination_Country__c != null &&
        p.getValue() == caseRec.Destination_Country__c
      ) {
        mergeFieldMapping.put('{!Case.Destination_Country__c}', p.getLabel());
      }
    }
    /*Schema.DescribeFieldResult fieldResult1 = Case.System_Filed_In__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple1){
            if(caseRec.System_Filed_In__c!=null && p.getValue()==caseRec.System_Filed_In__c){
                mergeFieldMapping.put('{!Case.System_Filed_In__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult2 = Case.Shipment_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple2){
            if(caseRec.Shipment_Type__c!=null && p.getValue()==caseRec.Shipment_Type__c){
                mergeFieldMapping.put('{!Case.Shipment_Type__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult3 = Case.Service_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple3 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple3){
            if(caseRec.Service_Type__c!=null && p.getValue()==caseRec.Service_Type__c){
                mergeFieldMapping.put('{!Case.Service_Type__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult4 = Case.Assignee_Pricing_Location__c.getDescribe();
        List<Schema.PicklistEntry> ple4 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple4){
            if(caseRec.Assignee_Pricing_Location__c!=null && p.getValue()==caseRec.Assignee_Pricing_Location__c){
                mergeFieldMapping.put('{!Case.Assignee_Pricing_Location__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult5 = Case.BL_Resolution_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple5 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple5){
            if(caseRec.BL_Resolution_Category__c!=null && p.getValue()==caseRec.BL_Resolution_Category__c){
                mergeFieldMapping.put('{!Case.BL_Resolution_Category__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult6 = Case.Customer_Inquiry_Resolution__c.getDescribe();
        List<Schema.PicklistEntry> ple6 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple6){
            if(caseRec.Customer_Inquiry_Resolution__c!=null && p.getValue()==caseRec.Customer_Inquiry_Resolution__c){
                mergeFieldMapping.put('{!Case.Customer_Inquiry_Resolution__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult7 = Case.Resolution_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple7 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple7){
            if(caseRec.Resolution_Category__c!=null && p.getValue()==caseRec.Resolution_Category__c){
                mergeFieldMapping.put('{!Case.Resolution_Category__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult8 = Case.Request_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple8 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple8){
            if(caseRec.Request_Type__c!=null && p.getValue()==caseRec.Request_Type__c){
                mergeFieldMapping.put('{!Case.Request_Type__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult9 = Case.Requested_Offered__c.getDescribe();
        List<Schema.PicklistEntry> ple9 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple9){
            if(caseRec.Requested_Offered__c!=null && p.getValue()==caseRec.Requested_Offered__c){
                mergeFieldMapping.put('{!Case.Requested_Offered__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult10 = Case.Request_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple10 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple10){
            if(caseRec.Request_Category__c!=null && p.getValue()==caseRec.Request_Category__c){
                mergeFieldMapping.put('{!Case.Request_Category__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult11 = Case.Reason_to_Refer_to_Pricing__c.getDescribe();
        List<Schema.PicklistEntry> ple11 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple11){
            if(caseRec.Reason_to_Refer_to_Pricing__c!=null && p.getValue()==caseRec.Reason_to_Refer_to_Pricing__c){
                mergeFieldMapping.put('{!Case.Reason_to_Refer_to_Pricing__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult12 = Case.Origin_type_of_move__c.getDescribe();
        List<Schema.PicklistEntry> ple12 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple12){
            if(caseRec.Origin_type_of_move__c!=null && p.getValue()==caseRec.Origin_type_of_move__c){
                mergeFieldMapping.put('{!Case.Origin_type_of_move__c}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult13 = Case.Origin_State__c.getDescribe();
        List<Schema.PicklistEntry> ple13 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple13){
            if(caseRec.Origin_State__c!=null && p.getValue()==caseRec.Origin_State__c){
                mergeFieldMapping.put('{!Case.Origin_State__c}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult14 = Case.Origin_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple14 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple14){
            if(caseRec.Origin_Country__c!=null && p.getValue()==caseRec.Origin_Country__c){
                mergeFieldMapping.put('{!Case.Origin_Country__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult15 = Case.Move_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple15 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple15){
            if(caseRec.Move_Type__c!=null && p.getValue()==caseRec.Move_Type__c){
                mergeFieldMapping.put('{!Case.Move_Type__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult16 = Case.Load_Port__c.getDescribe();
        List<Schema.PicklistEntry> ple16 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple16){
            if(caseRec.Load_Port__c!=null && p.getValue()==caseRec.Load_Port__c){
                mergeFieldMapping.put('{!Case.Load_Port__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult17 = Case.Issue_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple17 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple17){
            if(caseRec.Issue_Type__c!=null && p.getValue()==caseRec.Issue_Type__c){
                mergeFieldMapping.put('{!Case.Issue_Type__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult18 = Case.Freight_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple18 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple18){
            if(caseRec.Freight_Type__c!=null && p.getValue()==caseRec.Freight_Type__c){
                mergeFieldMapping.put('{!Case.Freight_Type__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult19 = Case.Final_Discharge_Port__c.getDescribe();
        List<Schema.PicklistEntry> ple19 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple19){
            if(caseRec.Final_Discharge_Port__c!=null && p.getValue()==caseRec.Final_Discharge_Port__c){
                mergeFieldMapping.put('{!Case.Final_Discharge_Port__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult20 = Case.Destination_type_of_move__c.getDescribe();
        List<Schema.PicklistEntry> ple20 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple20){
            if(caseRec.Destination_type_of_move__c!=null && p.getValue()==caseRec.Destination_type_of_move__c){
                mergeFieldMapping.put('{!Case.Destination_type_of_move__c}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult21 = Case.Destination_State__c.getDescribe();
        List<Schema.PicklistEntry> ple21 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple21){
            if(caseRec.Destination_State__c!=null && p.getValue()==caseRec.Destination_State__c){
                mergeFieldMapping.put('{!Case.Destination_State__c}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult22 = Case.Destination_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple22 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple22){
            if(caseRec.Destination_Country__c!=null && p.getValue()==caseRec.Destination_Country__c){
                mergeFieldMapping.put('{!Case.Destination_Country__c}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult23 = Case.Destination__c.getDescribe();
        List<Schema.PicklistEntry> ple23 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple23){
            if(caseRec.Destination__c!=null && p.getValue()==caseRec.Destination__c){
                mergeFieldMapping.put('{!Case.Destination__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult24 = Case.Origin__c.getDescribe();
        List<Schema.PicklistEntry> ple24 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple24){
            if(caseRec.Origin__c!=null && p.getValue()==caseRec.Origin__c){
                mergeFieldMapping.put('{!Case.Origin__c}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult25 = Case.Origin.getDescribe();
        List<Schema.PicklistEntry> ple25 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple25){
            if(caseRec.Origin!=null && p.getValue()==caseRec.Origin){
                mergeFieldMapping.put('{!Case.Origin}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult26 = Case.Department_Responsible_for_Resolution__c.getDescribe();
        List<Schema.PicklistEntry> ple26 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple26){
            if(caseRec.Department_Responsible_for_Resolution__c!=null && p.getValue()==caseRec.Department_Responsible_for_Resolution__c){
                mergeFieldMapping.put('{!Case.Department_Responsible_for_Resolution__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult27 = Case.Department_Responsible_for_Error__c.getDescribe();
        List<Schema.PicklistEntry> ple27 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple27){
            if(caseRec.Department_Responsible_for_Error__c!=null && p.getValue()==caseRec.Department_Responsible_for_Error__c){
                mergeFieldMapping.put('{!Case.Department_Responsible_for_Error__c}',p.getLabel());                
            }
        }*/
    /*Schema.DescribeFieldResult fieldResult28 = Case.Customers_Approval__c.getDescribe();
        List<Schema.PicklistEntry> ple28 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple28){
            if(caseRec.Customers_Approval__c!=null && p.getValue()==caseRec.Customers_Approval__c){
                mergeFieldMapping.put('{!Case.Customers_Approval__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult29 = Case.Bill_change_fee_applicable__c.getDescribe();
        List<Schema.PicklistEntry> ple29 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple29){
            if(caseRec.Bill_change_fee_applicable__c!=null && p.getValue()==caseRec.Bill_change_fee_applicable__c){
                mergeFieldMapping.put('{!Case.Bill_change_fee_applicable__c}',p.getLabel());                
            }
        }
        Schema.DescribeFieldResult fieldResult30 = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple30 = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple30){
            if(caseRec.Status!=null && p.getValue()==caseRec.Status){
                mergeFieldMapping.put('{!Case.Status}',p.getLabel());                
            }
        }*/
    return mergeFieldMapping;
  }
  @AuraEnabled
  public static string getTemplates(string queryTerm, Case caseRec) {
    caseRec = [
      SELECT
        Id,
        Ha__c,
        Hacienda_Mail_Sent__c,
        Case_Thread_Id__c,
        Summary_BR__c,
        Destination_Approval__c,
        ContactId,
        Contact.Name,
        CaseNumber,
        Booking__c,
        BOL_Number__c,
        Consignee_Name__c,
        Consignee_Name__r.Name,
        Shipper_Name__c,
        Shipper_Name__r.Name,
        Destination_Country__c
      FROM case
      WHERE Id = :caseRec.Id
      LIMIT 1
    ];
    //caseRec = [SELECT Id,Ha__c,Hacienda_Mail_Sent__c,Case_Thread_Id__c,New_BOL__c,Estimated_arrival_date__c,Estimated_sailing_date__c,External_Customer_Lane_ID__c,FCN_Number__c,Filed_Date__c,Filed_In_External_System__c,Equipment_Type_Size__c,Summary_BR__c,System_Filed_In__c,Effective_Date__c,Destination_City__c,Destination_Zipcode__c,Destination_Approval__c,Booking_Destination__c,Customer_Email__c,Correct_TLI_to_Use__c,Correct_temperature__c,Corrected_Contract_Number__c,Correct_Date_to_Use__c,Contract_Number__c,Container_Type__c,Container_Status__c,Container_Number__c,Comments_on_Pricing_Rating_Issue__c,Frequency_Comments__c,Comments__c,Cargo_Available_Date__c,Booking_Number__c,Bill_to_Party__c,Booked_Temperature__c,Bill_to_Party__r.Name,Additional_Comments_details_instructions__c,RecordType.Name,ContactId,Contact.Name,AccountId,Account.Name,CaseNumber,BOL_Number__c,Subject,Description,SuppliedEmail,Booking__c,Consignee_Name__c,Consignee_Name__r.Name,Shipper_Name__c,Shipper_Name__r.Name,CreatedById,CreatedBy.Email,Destination_Country__c,Booking_Origin__c,Origin_City__c,Origin_Zipcode__c,Previous_Booking_Number__c,Publishing_Owner__c,Reason_for_hold__c,Reason_For_Incomplete_Request__c,Reefer_Temperature__c,Service__c,Supply_Chain_Services__c,Temperature__c,Voyage__c,User_Responsible_for_Error__c,Shipment_Type__c,Service_Type__c,Assignee_Pricing_Location__c,BL_Resolution_Category__c,Customer_Inquiry_Resolution__c,Resolution_Category__c,Request_Type__c,Requested_Offered__c,Request_Category__c,Reason_to_Refer_to_Pricing__c,Origin_type_of_move__c,Origin_Country__c,Move_Type__c,Load_Port__c,Issue_Type__c,Final_Discharge_Port__c,Freight_Type__c,Destination_type_of_move__c,Origin,Customers_Approval__c,Bill_change_fee_applicable__c,Status from case where Id=:caseRec.Id limit 1];
    List<EmailTemplate> li = [
      SELECT Id, Name, Body, HTMLValue
      FROM EmailTemplate
      WHERE IsActive = TRUE AND Name LIKE :'%' + queryTerm + '%'
    ];
    list<queryTemplates> qt = new List<queryTemplates>();
    map<string, string> mergeFieldMapping = mergeFields(caseRec);
    //map<string, string> mergeFieldMapping = new map<string,string>();
    system.debug(caseRec);
    system.debug(mergeFieldMapping);
    for (emailTemplate e : li) {
      string mergeFields = e.HtmlValue; //e.body;
      for (string s : mergeFieldMapping.keySet()) {
        if (mergeFields != null) {
          if (
            mergeFieldMapping.get(s) != null &&
            mergeFieldMapping.get(s) != ''
          ) {
            if (
              mergeFields.indexOf(s) != -1 &&
              mergeFields.indexOf(s) != null
            ) {
              mergeFields = mergeFields.replace(s, mergeFieldMapping.get(s));
            } else {
              mergeFields = mergeFields.replace(s, '');
            }
          } else {
            mergeFields = mergeFields.replace(s, '');
          }
        }
        system.debug(mergeFields);
      }
      if (mergeFields != null) {
        qt.add(new queryTemplates(e.Id, e.Name, mergeFields));
      }
    }
    system.debug('queryTemplate -> ' + qt);

    return json.serialize(qt);
  }
  private class queryTemplates {
    string templateId;
    string templateName;
    string templateBody;
    queryTemplates(string i, string n, string b) {
      templateId = i;
      templateName = n;
      templateBody = b;
    }
  }

  @AuraEnabled
  public static string destinationEmailList() {
    list<Destination_Team_Email__c> li = Destination_Team_Email__c.getall()
      .values();
    map<string, list<Destination_Team_Email__c>> emailmapping = new Map<string, list<Destination_Team_Email__c>>();
    map<string, map<string, list<Destination_Team_Email__c>>> mp = new Map<string, map<string, list<Destination_Team_Email__c>>>();
    for (Destination_Team_Email__c d : li) {
      if (emailmapping.containsKey(d.Country__c)) {
        list<Destination_Team_Email__c> con = emailmapping.get(d.Country__c);
        con.add(d);
        emailmapping.put(d.Country__c, con);
      } else {
        list<Destination_Team_Email__c> con = new List<Destination_Team_Email__c>();
        con.add(d);
        emailmapping.put(d.Country__c, con);
        if (mp.containsKey(d.Region__c)) {
          map<string, list<Destination_Team_Email__c>> reg = mp.get(
            d.Region__c
          );
          mp.put(d.Region__c, reg);
        } else {
          map<string, list<Destination_Team_Email__c>> reg = new Map<string, list<Destination_Team_Email__c>>();
          mp.put(d.Region__c, reg);
        }
      }
    }
    for (string s : mp.keySet()) {
      for (Destination_Team_Email__c d : li) {
        if (d.Region__c == s) {
          if (
            mp.get(d.Region__c) ==
            new Map<string, list<Destination_Team_Email__c>>()
          ) {
            map<string, list<Destination_Team_Email__c>> em = new Map<string, list<Destination_Team_Email__c>>();
            em.put(d.Country__c, emailmapping.get(d.Country__c));
            mp.put(d.Region__c, em);
          } else {
            map<string, list<Destination_Team_Email__c>> em = mp.get(
              d.Region__c
            );
            em.put(d.Country__c, emailmapping.get(d.Country__c));
            mp.put(d.Region__c, em);
          }
        }
      }
    }
    return JSON.serialize(mp);
  }
  @AuraEnabled
  public static string sendAttachments(
    list<string> attachIds,
    list<string> emails,
    Case caseRec,
    string ccemails,
    string bccemails,
    string subject,
    string description
  ) {
    //Case ref = [SELECT Id,(SELECT Id,ContentDocumentId,ContentDocument.Title FROM AttachedContentDocuments where ContentDocumentId in : attachIds) FROM Case where Id=:caseId limit 1];
    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
    /*list<string> li = new list<string>();        
        for (AttachedContentDocument a : ref.AttachedContentDocuments){
        li.add(a.ContentDocumentId);
        }*/
    list<string> contentDocIds = new List<string>();
    list<string> attachmentIds = new List<string>();
    for (string s : attachIds) {
      string str = s.substring(0, 3);
      if (str == '069') {
        contentDocIds.add(s);
      } else if (str == '00P') {
        attachmentIds.add(s);
      }
    }
    list<contentversion> cvLi = [
      SELECT title, PathOnClient, FileType, versiondata
      FROM contentversion
      WHERE ContentDocumentId IN :contentDocIds
    ];
    for (ContentVersion cv : cvLi) {
      blob WOCFbody = cv.versiondata;
      Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
      efa.setBody(WOCFbody);
      system.debug(cv.FileType);
      if (cv.FileType == 'EXCEL_X') {
        efa.setFileName(cv.title + '.xlsx');
      } else if (cv.FileType == 'PDF') {
        efa.setFileName(cv.title + '.pdf');
      } else if (cv.FileType == 'WORD_X') {
        efa.setFileName(cv.title + '.docx');
      } else {
        efa.setFileName(cv.title);
      }
      fileAttachments.add(efa);
    }
    list<string> em = new List<string>();
    //em.add('aakanksha.singh@nagarro.com');
    system.debug(emails);
    em.addAll(emails);
    list<string> ccem = new List<string>();
    list<string> bccem = new List<string>();

    //Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, caseRec.ContactId, caseRec.Id);
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    System.debug('setTargetObjectId -> ' + caseRec.ContactId);
    //email.setTargetObjectId(caseRec.ContactId);
    email.setWhatId(caseRec.Id);
    email.setOrgWideEmailAddressId(System.Label.Orgwide_Email_Address_Id);
    if (ccemails != null) {
      ccemails = ccemails.replace(' ', '');
      ccem = ccemails.split(';');
      email.setCcAddresses(ccem);
    }
    system.debug('bccemails: ' + bccemails);
    if (bccemails != null && bccemails != '') {
      bccemails = bccemails.replace(' ', '');
      bccem = bccemails.split(';');
      email.setBccAddresses(bccem);
    }
    email.setToAddresses(em);
    email.setSubject(subject + '(' + caseRec.Case_Thread_Id__c + ')');
    email.setWhatId(caseRec.Id);
    if (description != null) {
      email.setHtmlBody(description); // + '<br/><br/>('+caseRec.Case_Thread_Id__c+')'
    } else {
      email.setHtmlBody('');
    }

    /*if(caseRec.Ha__c){
            //email.setTemplateId('00XM0000000S3AOMA0');
            //email.setHtmlBody( 'Good day team,<br/><br/>Please find enclosed Crowley letter, customer letter, BOLs and Commercial Invoice.<br/>Confirm once hacienda accepts the correction.<br/><br/>Thanks in Advance!' );
			email.setHtmlBody(description);
        }else if(caseRec.Destination_Approval__c){
	        email.setHtmlBody( 'Good day team,<br/><br/>Please find enclosed Crowley letter, customer letter, BOLs and Commercial Invoice.<br/>Confirm once Destination team approves the correction.<br/><br/>Thanks in Advance!' );
			//email.setTemplateId('00XM0000000S3AJMA0');
        }*/

    email.setFileAttachments(fileAttachments);

    // Sends the email
    try {
      if (!Test.isRunningTest()) {
        Messaging.SendEmailResult[] r = Messaging.sendEmail(
          new List<Messaging.SingleEmailMessage>{ email }
        );
        system.debug('Email' + r);
      }
      Case ca = new Case(Id = caseRec.Id, Hacienda_Mail_Sent__c = true);
      update ca;
      return 'success';
    } catch (exception e) {
      system.debug(e);
      return 'error';
    }
  }
  public class attachmentList {
    //string taskId;
    @TestVisible
    string attachId;
    @TestVisible
    string attName;
    public attachmentList(string ai, string an) {
      //string t,
      //taskId = t;
      attachId = ai;
      attName = an;
    }
  }
}
