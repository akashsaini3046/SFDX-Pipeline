/*
 * Name: ADNotesController
 * Purpose: Controller class for note component
 * Author: Nagarro
 * Created Date: 08-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADNotesController {
  @AuraEnabled
  public Integer totalNotesCount { get; set; }
  @AuraEnabled
  public List<ContentNote> notesList { get; set; }
  @AuraEnabled
  Map<Id, String> mapIdAndCsvAsString { get; set; }
  @AuraEnabled
  Map<Id, String> mapNoteIdAndParentObjectName { get; set; } //Map of note id and the parent object name(Account/Opportunity)
  @AuraEnabled
  Map<Id, String> mapNoteIdAndParentRecordName { get; set; } //Map of note id and the parent record name
  @AuraEnabled
  public List<Id> ownerIdList { get; set; }

  /*
   * Method Name: fetchNotes
   * Input Parameters: Id accountId, ADMasterFilterWrapper objMasterFilter
   * Return value: ADNotesController
   * Purpose: 	This method fetches notes related to account hierarchy or opportunities
   */
  @AuraEnabled
  public static ADNotesController fetchNotes(
    Id accountId,
    ADMasterFilterWrapper objMasterFilter
  ) {
    ADNotesController notesControllerObj = new ADNotesController();
    notesControllerObj.mapNoteIdAndParentObjectName = new Map<Id, String>();
    notesControllerObj.mapNoteIdAndParentRecordName = new Map<Id, String>();
    notesControllerObj.ownerIdList = new List<Id>();

    // -----------Fetching Account related notes-----------
    List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(
      ADAccountDashboardUtil.getAllRelatedAccount(accountId),
      objMasterFilter
    );

    //Fetch all the content document links (notes) related to the account ids
    List<Account> accRelatedContentDocLinksList = new List<Account>();
    if (lstFilteredAccounts != null && !lstFilteredAccounts.isEmpty())
      accRelatedContentDocLinksList = [
        SELECT
          Id,
          (
            SELECT
              Id,
              ContentDocumentID,
              LinkedEntityid,
              LinkedEntity.Name,
              ShareType,
              Visibility
            FROM ContentDocumentLinks
          )
        FROM Account
        WHERE id IN :lstFilteredAccounts
      ];

    Set<Id> contentDocumentIdSetRelatedToAcc = new Set<Id>(); // Fetch Ids of the notes related to account. Will be used to fetch the notes details from ContentNote object
    if (
      accRelatedContentDocLinksList != null &&
      !accRelatedContentDocLinksList.isEmpty()
    ) {
      for (Account acc : accRelatedContentDocLinksList) {
        if (
          acc.ContentDocumentLinks != null &&
          !acc.ContentDocumentLinks.isEmpty()
        ) {
          for (ContentDocumentLink c : acc.ContentDocumentLinks) {
            contentDocumentIdSetRelatedToAcc.add(c.ContentDocumentID);
            String accId = acc.Id;
            if (accId.startsWith('001')) {
              notesControllerObj.mapNoteIdAndParentObjectName.put(
                c.ContentDocumentID,
                'Account'
              );
              notesControllerObj.mapNoteIdAndParentRecordName.put(
                c.ContentDocumentID,
                c.LinkedEntity.Name
              );
            }
          }
        }
      }
    }

    //-----------Fetching Opportunity related notes-----------
    //Get related opportunities and apply filter on those
    ADMasterFilterWrapper objMasterFilterTemp = new ADMasterFilterWrapper();
    objMasterFilterTemp.lstSelectedAccounts = objMasterFilter.lstSelectedAccounts;
    objMasterFilterTemp.lstSelectedOwners = objMasterFilter.lstSelectedOwners;
    objMasterFilterTemp.strSelectedTopFilter = objMasterFilter.strSelectedTopFilter;
    objMasterFilterTemp.strSelectedOppSizeFilterOperator = objMasterFilter.strSelectedOppSizeFilterOperator;
    objMasterFilterTemp.strOppSizeVal = objMasterFilter.strOppSizeVal;
    objMasterFilterTemp.strSelectedYear = null;
    List<Opportunity> opportunityList = ADAccountDashboardUtil.applyOpportunityFilter(
      ADAccountDashboardUtil.getAllRelatedOpportunitiesWithoutFilter(
        lstFilteredAccounts
      ),
      objMasterFilterTemp
    );

    //Fetch all the content document links (notes) related to the opportunity ids
    List<Opportunity> oppRelatedContentDocLinksList = new List<Opportunity>();
    if (opportunityList != null && !opportunityList.isEmpty())
      oppRelatedContentDocLinksList = [
        SELECT
          Id,
          (
            SELECT
              Id,
              ContentDocumentID,
              LinkedEntityid,
              LinkedEntity.Name,
              ShareType,
              Visibility
            FROM ContentDocumentLinks
          )
        FROM Opportunity
        WHERE id IN :opportunityList
      ];

    Set<Id> contentDocumentIdSetRelatedToOpp = new Set<Id>(); // Fetch Ids of the notes related to opportunity. Will be used to fetch the notes details from ContentNote object
    if (
      oppRelatedContentDocLinksList != null &&
      !oppRelatedContentDocLinksList.isEmpty()
    ) {
      for (Opportunity opp : oppRelatedContentDocLinksList) {
        for (ContentDocumentLink c : opp.ContentDocumentLinks) {
          contentDocumentIdSetRelatedToOpp.add(c.ContentDocumentID);
          String oppId = opp.Id;
          if (oppId.startsWith('006')) {
            notesControllerObj.mapNoteIdAndParentObjectName.put(
              c.ContentDocumentID,
              'Opportunity'
            );
            notesControllerObj.mapNoteIdAndParentRecordName.put(
              c.ContentDocumentID,
              c.LinkedEntity.Name
            );
          }
        }
      }
    }

    //-----------Fetching notes details related to account or opportunity-----------
    notesControllerObj.notesList = new List<ContentNote>();

    if (objMasterFilter.strSelectedYear == Label.AD_PICKLIST_VAL_ALL_YEAR)
      notesControllerObj.notesList = [
        SELECT Content, Title, CreatedDate, CreatedBy.Name, OwnerId
        FROM ContentNote
        WHERE
          Id IN :contentDocumentIdSetRelatedToAcc
          OR Id IN :contentDocumentIdSetRelatedToOpp
        ORDER BY CreatedDate DESC
      ];
    else
      notesControllerObj.notesList = [
        SELECT Content, Title, CreatedDate, CreatedBy.Name, OwnerId
        FROM ContentNote
        WHERE
          (Id IN :contentDocumentIdSetRelatedToAcc
          OR Id IN :contentDocumentIdSetRelatedToOpp)
          AND CALENDAR_YEAR(CreatedDate) = :Integer.valueOf(
            objMasterFilter.strSelectedYear
          )
        ORDER BY CreatedDate DESC
      ];
    notesControllerObj.totalNotesCount = notesControllerObj.notesList.size();
    Blob csvFileBody;
    String csvAsString = '';
    notesControllerObj.mapIdAndCsvAsString = new Map<Id, String>();

    if (
      notesControllerObj.notesList != null &&
      !notesControllerObj.notesList.isEmpty()
    ) {
      for (ContentNote cn : notesControllerObj.notesList) {
        csvFileBody = cn.Content;
        csvAsString = csvFileBody.toString();
        notesControllerObj.mapIdAndCsvAsString.put(cn.Id, csvAsString);
        notesControllerObj.ownerIdList.add(cn.OwnerId);
      }
    }

    return notesControllerObj;
  }

  /*
* Method Name: applyFilter
* Input Parameters: Id accountId, Date startDate, Date endDate, List<sObject> selectedOwners, List<ContentNote> notesList
* Id accountId: This holds parent/current account Id.
* Date startDate: This holds the start date.
* Date endDate: This holds the end date.
* List<sObject> selectedOwners: This holds the list of owners selected in the multi select lookup component on the AllNotes component.
* List<ContentNote> notesList: List of notes related to account hierarchy or opportunities.
* Return value: List<ContentNote>
* Purpose: 	There are 2 filter options on the component: Assigned To and Created Date.
This method is called when Apply button is clicked on the component. Based on the users or created date selected, filtered notes list is returned.
*/
  //Called when Apply button is clicked on the component. Based on the date filter and users selected notes list is returned.
  @AuraEnabled
  public static List<ContentNote> applyFilter(
    Id accountId,
    Date startDate,
    Date endDate,
    List<sObject> selectedOwners,
    List<ContentNote> notesList
  ) {
    Set<Id> selectedOwnerIds = new Set<Id>();
    if (selectedOwners != null && !selectedOwners.isEmpty()) {
      for (sObject s : selectedOwners) {
        selectedOwnerIds.add(s.Id);
      }
    }

    Set<Id> notesIdSet = new Set<Id>();
    if (notesList != null && !notesList.isEmpty()) {
      for (ContentNote t : notesList) {
        notesIdSet.add(t.Id);
      }
    }

    if (notesIdSet != null && !notesIdSet.isEmpty()) {
      notesList = [
        SELECT Content, Title, CreatedDate, CreatedBy.Name
        FROM ContentNote
        WHERE
          Id IN :notesIdSet
          AND DAY_ONLY(CreatedDate) >= :startDate
          AND DAY_ONLY(CreatedDate) <= :endDate
        ORDER BY createdDate DESC
      ];
      if (selectedOwnerIds != null && !selectedOwnerIds.isEmpty()) {
        notesList = [
          SELECT Content, Title, CreatedDate, CreatedBy.Name
          FROM ContentNote
          WHERE
            Id IN :notesIdSet
            AND DAY_ONLY(CreatedDate) >= :startDate
            AND DAY_ONLY(CreatedDate) <= :endDate
            AND CreatedById IN :selectedOwnerIds
          ORDER BY createdDate DESC
        ];
      } else if (selectedOwnerIds != null && !selectedOwnerIds.isEmpty()) {
        notesList = [
          SELECT Content, Title, CreatedDate, CreatedBy.Name
          FROM ContentNote
          WHERE Id IN :notesIdSet AND CreatedById IN :selectedOwnerIds
          ORDER BY createdDate DESC
        ];
      }
    }
    return notesList;
  }

  /*
* Method Name: applySorting
* Input Parameters:
* String sortedDateOptionSelected: This holds the sorting option selected.
* List<ContentNote> notesList: This holds the list of notes currently displayed on the component.
* Return value: List<ContentNote>
* Purpose: 	There is 1 sorting link on the component: Sort by Created Date.
This method is called when the sorting link is clicked on the component and then the sorted notes list is returned.	
*/
  @AuraEnabled
  public static List<ContentNote> applySorting(
    List<ContentNote> notesList,
    String sortedDateOptionSelected
  ) {
    Set<Id> notesIdSet = new Set<Id>();
    if (notesList != null && !notesList.isEmpty()) {
      for (ContentNote cn : notesList) {
        notesIdSet.add(cn.Id);
      }
    }
    List<ContentNote> sortedNotesList = new List<ContentNote>();

    if (sortedDateOptionSelected == ConstantClass.SORTING_CREATED_DATE_ASC)
      sortedNotesList = [
        SELECT Content, Title, CreatedDate, CreatedBy.Name
        FROM ContentNote
        WHERE Id IN :notesIdSet
        ORDER BY createdDate ASC
      ];
    else if (
      sortedDateOptionSelected == ConstantClass.SORTING_CREATED_DATE_DESC
    )
      sortedNotesList = [
        SELECT Content, Title, CreatedDate, CreatedBy.Name
        FROM ContentNote
        WHERE Id IN :notesIdSet
        ORDER BY createdDate DESC
      ];

    return sortedNotesList;
  }
}
