/**
 * Handler on cases with system level access
 * @author Vikash Singh
 */
public without sharing class AllCaseHandler {
  /**
   * Update parent case case status
   * - if the case being created is a child case
   * - if the case being closed is a child case
   *
   * @param newCaseList list of cases with new values
   * @param oldCaseMap list of cases with new values
   */
  public static void updateParentCaseStatus(
    List<Case> newCaseList,
    Map<Id, Case> oldCaseMap
  ) {
    if (newCaseList != null && !newCaseList.isEmpty()) {
      Set<Id> parentCaseIds = new Set<Id>();
      Set<Id> newClosedCasesIds = new Set<Id>();
      //List<String> closedStatsues = new List<String>{'Closed - Rate Not Feasible', 'Closed Resolved', 'Closed Unresolved', 'Closed'};

      for (Case caseRec : newCaseList) {
        if (caseRec.ParentId != null) {
          // collect parent case ids
          parentCaseIds.add(caseRec.ParentId);
        }
      }

      if (parentCaseIds != null && !parentCaseIds.isEmpty()) {
        Integer remainingRows =
          Limits.getLimitQueryRows() - Limits.getQueryRows();
        Integer upperBound = Math.min(remainingRows, 10000);

        Map<Id, Case> parentCaseMap = new Map<Id, Case>(
          [
            SELECT
              Id,
              CaseNumber,
              RecordTypeId,
              RecordType.Name,
              Status,
              Request_Type__c,
              Reason_For_Incomplete_Request__c,
              Additional_Comments_details_instructions__c,
              OwnerId
            FROM Case
            WHERE Id IN :parentCaseIds
            LIMIT :upperBound
          ]
        );
        if (parentCaseMap != null && !parentCaseMap.keySet().isEmpty()) {
          List<Case> parentCaseToUpdate = new List<Case>();
          Map<Id, Case> parentCaseToUpdateMap = new Map<Id, Case>();
          Set<Id> readyForReviewParentCaseIds = new Set<Id>();
          //Set<String> requestTypesForCustomerEnquirySubCase = new Set<String>{'Bill Copy','Payment','Track And Trace','Vehicle Shipping','Open Tariff Quotes'};

          for (Case caseRec : newCaseList) {
            if (caseRec.ParentId != null) {
              Case pcs = parentCaseMap.get(caseRec.ParentId);

              String recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById()
                .get(caseRec.recordTypeId)
                .getName();

              if (
                parentCaseMap.containsKey(caseRec.ParentId) &&
                parentCaseMap.get(caseRec.ParentId).recordTypeId ==
                System.Label.B_L_Revision_record_type
              ) {
                if (recordTypeName.contains('Pricing Rate Issue')) {
                  Case parent = new Case();
                  parent = parentCaseMap.get(caseRec.ParentId);

                  // if case is being created or case status was changed to Reopened
                  if (
                    (oldCaseMap == null && caseRec.Status == 'Open') ||
                    (oldCaseMap != null &&
                    caseRec.Status == 'Reopened' &&
                    caseRec.Status != oldCaseMap.get(caseRec.Id).Status)
                  ) {
                    Case caseRecordToUpdate = parentCaseToUpdateMap.containsKey(
                        caseRec.ParentId
                      )
                      ? parentCaseToUpdateMap.get(caseRec.ParentId)
                      : new Case();
                    caseRecordToUpdate.Id = caseRec.ParentId;
                    caseRecordToUpdate.Status = 'Awaiting more information';
                    caseRecordToUpdate.Reason_for_hold__c = 'Pricing';
                    caseRecordToUpdate.OwnerId = parent.OwnerId;
                    parentCaseToUpdate.add(caseRecordToUpdate);
                    parentCaseToUpdateMap.put(
                      caseRec.ParentId,
                      caseRecordToUpdate
                    );
                  } else if (
                    oldCaseMap != null &&
                    (caseRec.Status.contains('Closed')) &&
                    caseRec.Status != oldCaseMap.get(caseRec.Id).Status
                  ) {
                    // if case status was updated to Quote Filed or was Closed
                    Case caseRecordToUpdate = parentCaseToUpdateMap.containsKey(
                        caseRec.ParentId
                      )
                      ? parentCaseToUpdateMap.get(caseRec.ParentId)
                      : new Case();
                    caseRecordToUpdate.Id = caseRec.ParentId;
                    caseRecordToUpdate.Status = 'Ready for Review';
                    caseRecordToUpdate.OwnerId = parent.OwnerId;
                    parentCaseToUpdate.add(caseRecordToUpdate);
                    parentCaseToUpdateMap.put(
                      caseRec.ParentId,
                      caseRecordToUpdate
                    );
                  }
                }
                /*else if(recordTypeName == 'Rate Proposal'){
                                        if(pcs.RecordType.Name == 'Booking Request'){

                                            // cannot create a child Rate Proposal case without filling key information on parent
                                            if(oldCaseMap==null && String.isBlank(pcs.Additional_Comments_details_instructions__c)){
                                                caseRec.adderror('Please fill "Additional Comments details instructions" on Parent Case');
                                            }
                                            if(oldCaseMap!= null && caseRec.Status!=oldCaseMap.get(caseRec.Id).Status 
                                                && (caseRec.Status == 'Reopened' || caseRec.Status == 'Quote Requested' || caseRec.Status == 'Quote In Progress')){
                                                Case caseRecordToUpdate = parentCaseToUpdateMap.containsKey(caseRec.ParentId) ? parentCaseToUpdateMap.get(caseRec.ParentId) : new Case();
                                                caseRecordToUpdate.Id = caseRec.ParentId;
                                                caseRecordToUpdate.Status = 'Awaiting more information';
                                                parentCaseToUpdate.add(caseRecordToUpdate);
                                                parentCaseToUpdateMap.put(caseRec.ParentId, caseRecordToUpdate);
                                            }
                                            if( oldCaseMap !=null
                                               && parentCaseMap.get(caseRec.ParentId).RecordType.Name.contains('Booking Request')
                                               && parentCaseMap.get(caseRec.ParentId).Status == 'Awaiting more information'
                                               && caseRec.Status != oldCaseMap.get(caseRec.Id).Status && closedStatsues.contains(caseRec.Status))
                                            {
                                                readyForReviewParentCaseIds.add(caseRec.ParentId);
                                                newClosedCasesIds.add(caseRec.Id);
                                            }
                                        }
                                    }*/

                // If parent case has specific Customer Inquiry related Request Types and in 'Awaiting more information' status,
                // and this case is being closed then, update parent case status to Ready for review

                /*if(
                                        oldCaseMap !=null
                                        && parentCaseMap.get(caseRec.ParentId).RecordType.Name.contains('Customer Inquiry')
                                        && parentCaseMap.get(caseRec.ParentId).Status == 'Awaiting more information'
                                        && caseRec.Status != oldCaseMap.get(caseRec.Id).Status && caseRec.Status.containsIgnoreCase('Closed')
                                    ){
                                        readyForReviewParentCaseIds.add(caseRec.ParentId);
                                        newClosedCasesIds.add(caseRec.Id);
                                    }*/

                // If case is being created, and its parent does not have "Awaiting more information" status with
                // some specific request types then update parent status to "Awaiting more information"

                /*if(
                                        caseRec.Id == null
                                        && !caseRec.Status.containsIgnoreCase('Closed')
                                        && parentCaseMap.get(caseRec.ParentId).RecordType.Name.contains('Customer Inquiry')
                                        && parentCaseMap.get(caseRec.ParentId).Status != 'Awaiting more information'
                                        && parentCaseMap.get(caseRec.ParentId).Request_Type__c!=null 
                                        && requestTypesForCustomerEnquirySubCase.contains(parentCaseMap.get(caseRec.ParentId).Request_Type__c)
                                    ){
                                        Case caseRecordToUpdate = parentCaseToUpdateMap.containsKey(caseRec.ParentId) ? parentCaseToUpdateMap.get(caseRec.ParentId) : new Case();
                                        caseRecordToUpdate.Id = caseRec.ParentId;
                                        caseRecordToUpdate.Status = 'Awaiting more information';
                                        parentCaseToUpdate.add(caseRecordToUpdate);
                                        parentCaseToUpdateMap.put(caseRec.ParentId, caseRecordToUpdate);
                                    }*/
              }
            }
          }
          if (!parentCaseToUpdateMap.keyset().isEmpty()) {
            if (
              Schema.sObjectType.Case.isAccessible() &&
              Schema.sObjectType.Case.isUpdateable()
            ) {
              update parentCaseToUpdateMap.values();
            }
          }
        }
      }
    }
  }
}
