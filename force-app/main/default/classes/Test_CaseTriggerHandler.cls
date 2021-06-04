@isTest
public class Test_CaseTriggerHandler {
  @testSetup
  static void setUp() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> accounts = TestDataUtility.createAccount(
      'ABC Company',
      null,
      'IT',
      null,
      false,
      1
    );
    insert accounts;
    AccountTriggerHandler.clearRecursionVar();

    List<Account> parentAccs = TestDataUtility.createAccount(
      'Parent Account',
      null,
      'E-commerce',
      null,
      false,
      2
    );
    parentAccs[0].Account_Tier__c = 'Tier 1';
    parentAccs[1].Account_Tier__c = 'Tier 2';
    insert parentAccs;
    AccountTriggerHandler.clearRecursionVar();

    List<Entitlement> entitlements = new List<Entitlement>();

    /*for(Account acc: accounts){
            entitlements = TestDataUtility.createEntitlement('BL Revision',acc.Id, 1);
        }
        insert entitlements;
        */
    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();
    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      accounts,
      'BL11',
      'City11',
      'NY',
      '1134111',
      '86788888888',
      'US',
      1
    );
    insert businessLocationObj;
    List<Contact> con1 = TestDataUtility.createContact(
      recordTypeId,
      accounts,
      businessLocationObj,
      'Test',
      ' Contact 1',
      'contact@email.com',
      '9999888899',
      false,
      UserInfo.getUserId(),
      1
    );
    insert con1;

    List<Case> listcases = new List<Case>();
    List<Case> blrevcs = TestDataUtility.createBLRevisionCase(
      accounts,
      con1,
      null,
      'BL Rev Case 1',
      'Description 1',
      'Web',
      UserInfo.getUserId(),
      'Open',
      1
    );
    listcases.addAll(blrevcs);
    System.debug('blrevcs -> ' + blrevcs);
    CaseTriggerHandler.reset();

    List<Case> parentBLRevCase = TestDataUtility.createBLRevisionCase(
      accounts,
      con1,
      null,
      'Parent BL Rev Case 1',
      'Description 1',
      'Web',
      UserInfo.getUserId(),
      'Open',
      2
    );
    parentBLRevCase[1].Internal_Contact__c = true;
    insert parentBLRevCase;
    Id ParentId = parentBLRevCase[0].Id;
    System.debug('parentBLRevCase -> ' + parentBLRevCase);
    CaseTriggerHandler.reset();

    List<Case> ciCase = TestDataUtility.createCustomerInquiryCase(
      accounts,
      con1,
      null,
      'Customer Inquiry Case 1',
      'Description 1',
      'Email',
      UserInfo.getUserId(),
      'Open',
      1
    );
    listcases.addAll(ciCase);
    System.debug('ciCase -> ' + ciCase);
    CaseTriggerHandler.reset();

    List<Case> BKCases = TestDataUtility.createBookingRequestCase(
      accounts,
      con1,
      null,
      'Booking Request Case 1',
      'Description 1',
      'Email',
      UserInfo.getUserId(),
      'Open',
      1
    );
    listcases.addAll(BKCases);
    System.debug('BKCases -> ' + BKCases);
    CaseTriggerHandler.reset();

    List<Case> parentBKCases = TestDataUtility.createBookingRequestCase(
      parentAccs,
      con1,
      null,
      'RE:Booking Request Case 1',
      'Description 1',
      'Email',
      UserInfo.getUserId(),
      'Open',
      1
    );
    listcases.addAll(parentBKCases);
    System.debug('parentBKCases -> ' + parentBKCases);
    CaseTriggerHandler.reset();

    List<Case> pricingCases = TestDataUtility.createPricingRateIssueCase(
      accounts,
      null,
      parentBLRevCase,
      'Child Pricing Rate Issue Case 1',
      'Description 1',
      'Web',
      UserInfo.getUserId(),
      'Open',
      1
    );
    for (Case cs : pricingCases) {
      cs.ParentId = ParentId;
    }
    listcases.addAll(pricingCases);
    System.debug('pricingCases -> ' + pricingCases);
    insert listcases;
    CaseTriggerHandler.reset();
  }

  static testMethod void test_updateEntitlement() {
    Case cs = [
      SELECT Id, EntitlementId, Subject, RecordType.Name
      FROM Case
      WHERE Subject = 'BL Rev Case 1'
      LIMIT 1
    ];
    System.debug('entitlement cs -> ' + cs);
    //System.assert(cs.EntitlementId!=null);
  }

  static testMethod void test_parentCaseClosed() {
    try {
      Case pcs = [
        SELECT
          Id,
          ParentId,
          Status,
          Subject,
          Resolution__c,
          BL_Resolution_Category__c,
          Resolution_Sub_Category__c,
          Final_Resolution_Comments__c,
          Department_Responsible_For_Error__c
        FROM Case
        WHERE Subject = 'Parent BL Rev Case 1'
        LIMIT 1
      ];
      pcs.Status = 'Closed Resolved';
      pcs.Resolution__c = 'No correction needed';
      pcs.BL_Resolution_Category__c = 'Duplicate Issue';
      pcs.Resolution_Sub_category__c = 'No correction needed';
      pcs.Final_Resolution_Comments__c = 'TEST NO CORRECTION NEEDED';
      update pcs;
    } catch (Exception ex) {
      // System.assert(ex.getMessage().contains(System.Label.Case_Child_Cases_Open_Error_Msg));
    }
  }

  static testMethod void test_checkDuplicateCases() {
    Test.startTest();
    List<Account> accounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'ABC Company'
    ];
    List<Contact> contacts = [
      SELECT Id, Name
      FROM Contact
      WHERE Name = 'Test Contact 1'
    ];
    CaseTriggerHandler.reset();
    String case_dup_exception = '';
    if (UserInfo.getUserId() != System.Label.Email_to_Case_User) {
      try {
        List<Case> blrevcs = TestDataUtility.createBLRevisionCase(
          accounts,
          contacts,
          null,
          'BL Rev Case 1',
          'Description 1',
          'Web',
          UserInfo.getUserId(),
          'Open',
          1
        );
        insert blrevcs;
        CaseTriggerHandler.reset();
      } catch (Exception ex) {
        case_dup_exception = ex.getMessage();
      }
      //System.assert(case_dup_exception.contains(System.Label.Case_Duplicate_Record_Error_Msg));
    } else {
      case_dup_exception = '';
      List<Case> blrevcs = TestDataUtility.createBLRevisionCase(
        accounts,
        contacts,
        null,
        'BL Rev Case 1',
        'Duplicate Case 1',
        'Web',
        System.Label.Email_to_Case_User,
        'Open',
        1
      );
      insert blrevcs;
      Set<Id> dupIds = (new Map<Id, Case>(blrevcs)).keyset();
      List<Case> dupCases = [
        SELECT Id, Original_Case__c
        FROM Case
        WHERE Id IN :dupIds
        LIMIT 1
      ];
      for (Case cs : dupCases) {
        System.assert(cs.Original_Case__c != null);
      }
    }
    Test.stopTest();
  }

  static testMethod void test_updateChildFieldsFromParent() {
    Test.startTest();
    Account acc = [SELECT Id FROM Account WHERE Name = 'ABC Company' LIMIT 1];
    Case parentCase = [
      SELECT
        id,
        Subject,
        Consignee_Name__c,
        Equipment_Type_Size__c,
        Contract_Number__c,
        Shipper_Name__c,
        Assignee_Pricing_Location__c,
        RecordTypeId,
        ContactId,
        Priority,
        BOL_Number__c,
        Voyage__c,
        Origin,
        Booking__c,
        Bill_to_Party__c,
        Move_Type__c
      FROM Case
      WHERE Subject = 'BL Rev Case 1'
      LIMIT 1
    ];

    Map<string, Schema.SobjectField> caseFdMap = Case.getSobjectType()
      .getDescribe()
      .fields.getMap();
    Case cs1 = new Case();
    cs1.Id = parentCase.Id;
    cs1.Consignee_Name__c = acc.Id;
    cs1.Bill_to_Party__c = acc.Id;
    cs1.Shipper_Name__c = acc.Id;
    cs1.Consignee_Name__c = acc.Id;
    cs1.ContactId = parentCase.ContactId;
    //cs1.Origin=parentCase.Origin;
    cs1.Move_Type__c = caseFdMap.get('move_type__c')
        .getDescribe()
        .getPicklistValues()[0]
      .getValue();
    cs1.Assignee_Pricing_Location__c = caseFdMap.get(
          'assignee_pricing_location__c'
        )
        .getDescribe()
        .getPicklistValues()[0]
      .getValue();
    cs1.Priority = caseFdMap.get('priority')
        .getDescribe()
        .getPicklistValues()[0]
      .getValue();
    cs1.Booking__c = '123456789123';
    cs1.BOL_Number__c = '123409871234';
    cs1.Voyage__c = '12345678';
    cs1.Equipment_Type_Size__c = caseFdMap.get('equipment_type_size__c')
        .getDescribe()
        .getPicklistValues()[0]
      .getValue();
    cs1.Contract_Number__c = '12345678';
    cs1.Update_Count__c = 1;
    cs1.origin = 'EDI/GT NEXUS';
    cs1.Type = caseFdMap.get('type').getDescribe().getPicklistValues()[0]
      .getValue();
    update cs1;
    CaseTriggerHandler.reset();

    List<Case> pricingCases = TestDataUtility.createPricingRateIssueCase(
      new List<Account>{ acc },
      null,
      new List<Case>{ parentCase },
      'Child Pricing Rate Issue Case 2',
      'Description 1',
      'Web',
      UserInfo.getUserId(),
      'Open',
      1
    );
    insert pricingCases;
    CaseTriggerHandler.reset();

    Case childcs = [
      SELECT Id, Voyage__c
      FROM Case
      WHERE Subject = 'Child Pricing Rate Issue Case 2'
      LIMIT 1
    ];
    System.assert(childcs.Voyage__c == '12345678');
    Test.stopTest();
  }

  static testMethod void test_updateParentCaseStatus_PricingRateIssueRT2() {
    Case childCase = [
      SELECT Id, Status, Subject, ParentId
      FROM Case
      WHERE
        ParentId != NULL
        AND RecordTypeId = :System.Label.Rating_Issue_record_type
      LIMIT 1
    ];
    Id ParentId = childCase.ParentId;
    Case parentCase = [
      SELECT Id, Status, Subject
      FROM Case
      WHERE Id = :ParentId
      LIMIT 1
    ];
    Test.startTest();
    System.assert(parentCase.Status != null);
    try {
      parentCase.Status = 'Closed - Rate Not Feasible';
      update parentCase;
      CaseTriggerHandler.reset();
    } catch (Exception ex) {
      System.assert(
        ex.getMessage().contains(System.Label.Case_Child_Cases_Open_Error_Msg)
      );
    }

    parentCase = [
      SELECT Id, Status, Subject
      FROM Case
      WHERE Id = :parentCase.Id
    ];
    System.assert(parentCase.Status != null);

    Test.stopTest();
  }

  static testMethod void test_updateParentCaseStatus_PricingRateIssueRT() {
    Account accs = [SELECT Id FROM Account LIMIT 1];
    RecordType rt = [
      SELECT Id, Name
      FROM RecordType
      WHERE Name = 'Create BL Revision'
      LIMIT 1
    ];
    Case parentCase = [
      SELECT Id, Status, Subject
      FROM Case
      WHERE Subject = 'Parent BL Rev Case 1'
      LIMIT 1
    ];
    Case childCase = [
      SELECT Id, Status, Subject
      FROM Case
      WHERE Subject = 'Child Pricing Rate Issue Case 1'
      LIMIT 1
    ];
    Test.startTest();

    System.assert(parentCase.Status != null);

    childCase.Status = 'Closed - Rate Not Feasible';
    update childCase;
    CaseTriggerHandler.reset();

    parentCase = [
      SELECT Id, Status, Subject
      FROM Case
      WHERE Id = :parentCase.Id
    ];
    System.assert(parentCase.Status != null);

    Test.stopTest();
  }

  static void assignPermissionSet(List<Id> userIds, String permissionSetName) {
    Set<Id> permSetAssignees = new Set<Id>();
    Id permSetId = [
      SELECT Id, Name
      FROM PermissionSet
      WHERE Name = :permissionSetName
      LIMIT 1
    ]
    .Id;
    for (PermissionSetAssignment pas : [
      SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE PermissionSetId = :permSetId
    ]) {
      permSetAssignees.add(pas.AssigneeId);
    }

    List<PermissionSetAssignment> permAssignments = new List<PermissionSetAssignment>();
    for (Id userId : userIds) {
      if (!permSetAssignees.contains(userId)) {
        permAssignments.add(
          new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = permSetId
          )
        );
      }
    }
    insert permAssignments;
  }
  /*
    static List<User> getUsers(string profileName, integer numberOfUsers){
        
        Profile Profile1 = [SELECT Id, Name FROM Profile WHERE Name = :profileName];
        List<User> users = new List<User>();
        for(integer i=0; i<numberOfUsers; i++){
            users.add(new User(alias = ('sucrow'+i), email='test123@noemail.com',
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = Profile1.id, country='United States',IsActive =true,
                              timezonesidkey='America/Los_Angeles', username=('sampleuser180520'+i+'@crowley.com')));
        }
        insert users;
       
        List<Id> userIds = new List<Id>();
        for(User u: users){
            userIds.add(u.Id);
        }
        return users;
    }*/

  static testMethod void test_setParentAccount_caseCreatedWithParentAccount2() {
    Test.startTest();
    assignPermissionSet(
      new List<Id>{ UserInfo.getUserId() },
      'Allow_to_Update_Parent_Account'
    );
    User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(u) {
      AccountTriggerHandler.clearRecursionVar();

      Account parentAcc = new Account();
      Account parentAcc2 = new Account();
      Account childAcc = new Account();
      Account childAcc2 = new Account();

      List<Account> parentAccs = [
        SELECT Id, Name
        FROM Account
        WHERE Name LIKE '%Parent Account%'
      ];

      List<Account> childAccs = new List<Account>();
      for (Account acc : parentAccs) {
        childAccs.addAll(
          TestDataUtility.createAccount(
            'Child ' + acc.Name,
            null,
            'E-commerce',
            acc.Id,
            false,
            1
          )
        );
      }
      insert childAccs;
      AccountTriggerHandler.clearRecursionVar();

      childAcc = [
        SELECT Id, Name, ParentId, Parent.Name
        FROM Account
        WHERE Name = 'Child Parent Account'
        LIMIT 1
      ];
      System.debug('childAcc -> ' + childAcc);
      System.debug('childAcc -> ' + childAcc.Parent.Name);

      parentAcc2 = [
        SELECT Id, Name
        FROM Account
        WHERE Name = 'Parent Account1'
        LIMIT 1
      ];
      System.debug('parentAcc2 -> ' + parentAcc2);

      // If case is being created with an account that has a parent account
      List<Case> casesWithParentAccs = TestDataUtility.createBLRevisionCase(
        new List<Account>{ childAcc },
        null,
        null,
        'Test Case 1',
        'Description 1',
        'Web',
        UserInfo.getUserId(),
        'Open',
        1
      );
      insert casesWithParentAccs;
      CaseTriggerHandler.reset();

      // If account Id is cleared
      List<Case> casesWithoutAccs = new List<Case>();
      for (Case cas : casesWithParentAccs) {
        casesWithoutAccs.add(new Case(Id = cas.Id, AccountId = null));
      }
      update casesWithoutAccs;
      CaseTriggerHandler.reset();
      Case testCase1 = [
        SELECT Id, Parent_Account__c
        FROM Case
        WHERE Subject = 'Test Case 1'
        LIMIT 1
      ];
      System.assert(testCase1.Parent_Account__c == null);

      //	The account Id is updated on case with an account that does not have any parent account (parentAcc2 itself a parent and does not have any its parent account)
      //	Therefore, the Parent_Account__c field gets cleared.
      testCase1.AccountId = parentAcc2.Id;
      update testCase1;
      CaseTriggerHandler.reset();
      testCase1 = [
        SELECT Id, Parent_Account__c
        FROM Case
        WHERE Subject = 'Test Case 1'
        LIMIT 1
      ];
      System.assert(testCase1.Parent_Account__c == null);

      // Creating a case without account but with a Contact
      // Updating account's parent account launches SetParentAccountonCaseBatch
      /*Account conAcc = [Select Id, Name From Account Where Name='ABC Company' Limit 1];
            conAcc.ParentId = parentAcc.Id;
            update conAcc;
            Contact ct = [Select Id, AccountId, FirstName, LastName From Contact Where LastName ='Contact 1' and FirstName='Test' Limit 1];
            List<Case> casesWithContacts = TestDataUtility.createBLRevisionCase(null, new List<Contact>{ct}, null, 'Test Data 2', 'Description 2', 'Web', UserInfo.getUserId(), 'Open', 1);
            insert casesWithContacts;
            CaseTriggerHandler.reset();
            System.assert([Select Id, Parent_Account__c From Case Where Subject='Test Data 2' Limit 1].Parent_Account__c==null);
            */
    }
    Test.stopTest();
  }
  static testMethod void test_setCaseParentAccountOnContactUpdate() {
    assignPermissionSet(
      new List<Id>{ UserInfo.getUserId() },
      'Allow_to_Update_Parent_Account'
    );
    User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(u) {
      Test.startTest();

      AccountTriggerHandler.clearRecursionVar();

      Account parentAcc = [
        SELECT Id, Name
        FROM Account
        WHERE Name = 'Parent Account'
        LIMIT 1
      ];
      Account ABCComp = [
        SELECT Id, ParentId, Name
        FROM Account
        WHERE Name = 'ABC Company'
        LIMIT 1
      ];
      ABCComp.ParentId = parentAcc.Id;
      update ABCComp;
      AccountTriggerHandler.clearRecursionVar();

      Contact con = [
        SELECT Id, AccountId
        FROM Contact
        WHERE AccountId = :ABCComp.Id
        LIMIT 1
      ];

      List<Case> cases = TestDataUtility.createBLRevisionCase(
        null,
        null,
        null,
        'Test Case 1',
        'Description',
        'Web',
        UserInfo.getUserId(),
        'Open',
        1
      );
      insert cases;
      CaseTriggerHandler.reset();
      for (Case cs : cases) {
        cs.ContactId = con.Id;
      }
      update cases;
      CaseTriggerHandler.reset();
      Case cs = [
        SELECT Id, Parent_Account__c
        FROM Case
        WHERE Subject = 'Test Case 1'
      ];
      System.assert(cs.Parent_Account__c != null);
    }
  }

  static testMethod void test_parentAccountUpdatedonAccount() {
    assignPermissionSet(
      new List<Id>{ UserInfo.getUserId() },
      'Allow_to_Update_Parent_Account'
    );
    User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    System.runAs(u) {
      Test.startTest();
      //creating account
      Account parentAcc = new Account();
      Account parentAcc2 = new Account();
      Account childAcc = new Account();

      List<Account> parentAccs = [
        SELECT Id, Name
        FROM Account
        WHERE Name LIKE '%Parent Account%'
      ];

      List<Account> childAccs = new List<Account>();
      for (Account acc : parentAccs) {
        childAccs.addAll(
          TestDataUtility.createAccount(
            'Child 2 ' + acc.Name,
            null,
            'E-commerce',
            acc.Id,
            true,
            1
          )
        );
      }
      insert childAccs;
      AccountTriggerHandler.clearRecursionVar();

      childAcc = [
        SELECT Id, Name, ParentId, Parent.Name
        FROM Account
        WHERE Name = 'Child 2 Parent Account'
        LIMIT 1
      ];
      System.debug('childAcc -> ' + childAcc);
      System.debug('childAcc -> ' + childAcc.Parent.Name);

      parentAcc2 = [
        SELECT Id, Name
        FROM Account
        WHERE Name = 'Parent Account1'
        LIMIT 1
      ];
      System.debug('parentAcc2 -> ' + parentAcc2);

      childAcc.ParentId = parentAcc.Id;
      update childAcc;
      AccountTriggerHandler.clearRecursionVar();

      // If case is being created with an account that has a parent account
      List<Case> cs = TestDataUtility.createBLRevisionCase(
        new List<Account>{ childAcc },
        null,
        null,
        'Subject',
        'Test Data',
        'Web',
        UserInfo.getUserId(),
        'Open',
        1
      );

      insert cs;
      CaseTriggerHandler.reset();
      Id csId;
      for (Case cas : cs) {
        csId = cas.Id;
      }
      childAcc.ParentId = parentAcc2.Id;

      update childAcc;

      Test.stopTest();
      //checking if the case Parent Account field gets auto set to contact account's parent account
      //System.assert([Select Id, Parent_Account__c From Case Where Id=:csId Limit 1].Parent_Account__c==parentAcc2.Id);
    }
  }

  static testMethod void Test_CasesClosedCustomerInquirySLA() {
    Case CICase = [
      SELECT Id, Status
      FROM Case
      WHERE Subject = 'Customer Inquiry Case 1'
      LIMIT 1
    ];
    Test.startTest();
    CICase.Status = 'Closed Resolved';
    update CICase;
    Test.stopTest();
    Case afterupdatecase = [
      SELECT Id, Status
      FROM Case
      WHERE Subject = 'Customer Inquiry Case 1'
      LIMIT 1
    ];
    system.assert(afterupdatecase.Status == 'Closed Resolved');
  }

  static testMethod void Test_CasesClosedCustomerInquirySLA3() {
    Case CICase = [
      SELECT Id, Status
      FROM Case
      WHERE Subject = 'RE:Booking Request Case 1'
      LIMIT 1
    ];
    Test.startTest();
    CICase.Status = 'Closed Resolved';
    update CICase;
    Test.stopTest();
    Case afterupdatecase = [
      SELECT Id, Status
      FROM Case
      WHERE Subject = 'RE:Booking Request Case 1'
      LIMIT 1
    ];
    system.assert(afterupdatecase.Status == 'Closed Resolved');
  }

  static testMethod void Test_CasesClosedCustomerInquirySLA2() {
    Case BKCase = [
      SELECT Id, Status
      FROM Case
      WHERE Subject = 'Booking Request Case 1'
      LIMIT 1
    ];
    Test.startTest();
    BKCase.Status = 'Closed Resolved';
    update BKCase;
    Test.stopTest();
    Case afterupdatecase = [
      SELECT Id, Status
      FROM Case
      WHERE Subject = 'Booking Request Case 1'
      LIMIT 1
    ];
    system.assert(afterupdatecase.Status == 'Closed Resolved');
  }

  static testMethod void Test_CasesClosedCustomerInquirySLA4() {
    Case BKCase = [
      SELECT Id, Status
      FROM Case
      WHERE Tier__c = 'Tier 2'
      LIMIT 1
    ];
    Test.startTest();
    BKCase.Status = 'Closed Resolved';
    update BKCase;
    Test.stopTest();
    Case afterupdatecase = [
      SELECT Id, Status
      FROM Case
      WHERE Tier__c = 'Tier 2'
      LIMIT 1
    ];
    system.assert(afterupdatecase.Status == 'Closed Resolved');
  }

  static testMethod void test_PopulateSummary() {
    RecordType rt = [
      SELECT Id, Name
      FROM RecordType
      WHERE Name = 'Create Customer Inquiry'
      LIMIT 1
    ];
    Case parentCase = [
      SELECT Id, Status, Subject
      FROM Case
      WHERE Subject = 'Parent BL Rev Case 1'
      LIMIT 1
    ];
    Test.startTest();
    parentCase.RecordTypeId = rt.Id;
    parentCase.Reason_for_hold__c = 'Pricing / Breakbulk';
    update parentCase;
    Test.stopTest();
    Case afterupdatecase = [
      SELECT Id, Status, Subject, Summary_BR__c, RecordTypeId, RecordType.Name
      FROM Case
      WHERE Subject = 'Parent BL Rev Case 1'
      LIMIT 1
    ];
    System.assert(afterupdatecase.RecordType.Name.contains('Customer Inquiry'));
  }

  static testMethod void test_PopulateSummary2() {
    Case parentCase = [
      SELECT Id, Status, Subject
      FROM Case
      WHERE Subject = 'Customer Inquiry Case 1'
      LIMIT 1
    ];
    Test.startTest();
    parentCase.Subject = '';
    parentCase.Request_Type__c = '';
    update parentCase;
    Test.stopTest();
    system.debug('parentCase' + parentCase);
    //system.assertEquals(null, parentCase.Subject);
  }

  static testMethod void test_deleteCase() {
    Case DelCase = [SELECT Id FROM Case LIMIT 1];
    Test.startTest();
    delete DelCase;
    Test.stopTest();
  }

  /*
    static testMethod void test_updateParentCaseStatus_CustomerInquiry(){
        Group q = [Select Id, Name, Type From Group Where Type='Queue' and Name='Customer Inquiry'];
        List<Account> accs = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
		List<Address__c> addresses = [Select Id, Account__c From Address__c Where Account__c=:accs[0].Id];
        List<RecordType> contactRTs = [Select Id, Name, SobjectType From RecordType Where SobjectType='Contact' Limit 1];
        List<Contact> cts = TestDataUtility.createContact(contactRTs[0].Id, accs[0].Id, addresses, 'test', 'contact', 'test@yopmail.com', '9999888877', false, UserInfo.getUserId(), 1);
        
        Case parentCase = createCustomerInquiryCase(accs[0].Id, cts[0].Id, null, 'Subject1', 'Desc1', 'Web', q.Id, 'Open', 1)[0];
        CaseTriggerHandler.reset();
        Case childCase = TestDataUtility.createPricingRateIssueCase( accs[0].Id, cts[0].Id, parentCase.Id, 'Subject2', 'Desc2', 'Web', q.Id, 'Open', 1)[0];
        System.debug('customer inquiry flow if status awaiting information '+childCase);
        
        parentCase = [Select Id, Status, OwnerId From Case Where Id=: parentCase.Id];
        System.debug('parentCase -> '+parentCase);
        
        System.assert(parentCase.Status == 'Awaiting more information');
        
        CaseTriggerHandler.reset();
        
        Case closedChildCase = new Case();
        closedChildCase.Id = childCase.Id;
        closedChildCase.Status = 'Closed Resolved';
        //closedChildCase.Issue_Type__c = 'Pricing Issue';
        //closedChildCase.Resolution_Category__c = 'Contract Renewed';
        update closedChildCase;
        
        parentCase = [Select Id, RecordTypeId, Subject, Status From Case Where Id=:parentCase.Id];
        System.debug('customer inquiry flow if status Ready for Review -> '+parentCase);
        System.assert(parentCase.Status == 'Ready for Review');
    }
    */
  /*static testMethod void test_updateParentCaseStatus_BookingRequest(){
        List<Account> accounts = TestDataUtility.createAccount('ABC Company', 'IT', null, false, 1); 
        
        RecordType rt = [Select Id, Name From RecordType Where Name='Create Booking Request' Limit 1];
        Case case1 = TestDataUtility.createCase(rt.Id, accounts[0].Id, null, null, null, null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
        
        rt = [Select Id, Name From RecordType Where Name='Create Rate Proposal' Limit 1];
        Case case2 = TestDataUtility.createCase(rt.Id, accounts[0].Id, null, case1.Id, null, null, 'Web', UserInfo.getUserId(), 'Open', 1)[0];
    }*/

  /*static testMethod void test_updateChildCaseStatus(){
        Id Create_Existing_Customer_Rate_Request_RT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Create Existing Customer Rate Request').getRecordTypeId();
    	Id Create_Pricing_Rate_Proposal_RT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Create Pricing Rate Proposal').getRecordTypeId();
    	List<Account> accs = TestDataUtility.createAccount('Test Account 1', 'E-commerce', null, false, 1);
        
        Case pcs1 = new Case();
        pcs1.AccountId = accs[0].Id;
        pcs1.Subject = 'Subject1';
        pcs1.Origin = 'Web';
        pcs1.OwnerId = UserInfo.getUserId();
        pcs1.Status = 'Open';
        pcs1.Load_Port__c = 'ANGUILLA';
        pcs1.Final_Discharge_Port__c = 'Anguilla, AI';
        pcs1.Cargo_Available_Date__c = Date.today();
        pcs1.Freight_Type__c = 'Equipment';
        pcs1.Hazardous__c = 'Yes';
        pcs1.RecordTypeId = Create_Existing_Customer_Rate_Request_RT;
        pcs1.Request_Type__c = 'New Booking';
        insert pcs1;
        
        CaseTriggerHandler.reset();
        
        Case childcs1 = new Case();
        childcs1.AccountId = accs[0].Id;
        childcs1.Origin = 'Web';
        childcs1.Type = 'Medium';
        childcs1.Subject = 'Subject2';
        childcs1.RecordTypeId = Create_Pricing_Rate_Proposal_RT;
        childcs1.ParentId = pcs1.Id;
        insert childcs1;
        
        CaseTriggerHandler.reset();
        
        Case tempCs1 = new Case();
        tempCs1.Id = pcs1.Id;
        tempCs1.Feedback_Received__c = 'Partially Approved';
		update tempCs1;
    }*/
}
