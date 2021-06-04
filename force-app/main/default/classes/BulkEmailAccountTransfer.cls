public class BulkEmailAccountTransfer {
  public void sendEmail(
    Map<Id, Account> newAccountMap,
    Map<Id, Account> oldAccountMap
  ) {
    List<String> tableColumnsList = new List<String>();
    Set<Id> userIdSet = new Set<Id>();
    List<User> userList = new List<User>();
    Set<String> emailList = new Set<String>();
    List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();
    //Map<Id, List<Account>> newOwnerIdAccountMap = new Map<Id, List<Account>>();
    //Map<Id, List<Account>> oldOwnerIdAccountMap = new Map<Id, List<Account>>();
    Map<Id, List<Account>> AllOwnerIdAccountMap = new Map<Id, List<Account>>();
    Map<Id, String> userToEmailMap = new Map<Id, String>();
    Map<Id, String> userToNameMap = new Map<Id, String>();

    tableColumnsList.add(ConstantClass.SERIAL_NUMBER);
    tableColumnsList.add(ConstantClass.ACCOUNT_NAME_STRING);
    tableColumnsList.add(ConstantClass.ACCOUNT_OLD_OWNER);
    tableColumnsList.add(ConstantClass.ACCOUNT_NEW_OWNER);
    //tableColumnsList.add(ConstantClass.ACCOUNT_CVIF_STRING);

    String AccountsTable = Label.OWNER_CHANGE_HEADER_NEW_OWNER;
    Integer num;
    //String AccountsTable2 = Label.OWNER_CHANGE_HEADER;
    String cloneAccountsTable = '';
    //String cloneAccountsTable2 = '';
    AccountsTable +=
      '<table cellpadding="0" cellspacing="0" width="90%" align="center" border="1" style="border-collapse:collapse;"">' +
      '<tr style="font-weight:bold;">';
    //AccountsTable2 += '<table cellpadding="0" cellspacing="0" width="100%" align="center" border="1" style="border-collapse:collapse;"">'+
    //    '<tr style="font-weight:bold;">';

    String strTDOpen = Label.ATN_TD_OPEN;
    String strTROpen = Label.ATN_TR_OPEN;
    String strTDClose = Label.ATN_TD_CLOSE;
    String strTRClose = Label.ATN_TR_CLOSE;
    String strTHOpen = Label.ATN_TH_OPEN;
    String strTHClose = Label.ATN_TH_CLOSE;

    for (String str : tableColumnsList) {
      AccountsTable += strTHOpen + str + strTHClose;
      //AccountsTable2+= strTHOpen +str+ strTHClose;
    }
    AccountsTable += strTRClose;
    //AccountsTable2+= strTRClose;
    cloneAccountsTable = AccountsTable;
    //cloneAccountsTable2 = AccountsTable2;
    for (Account acc : newAccountMap.values()) {
      userIdSet.add(acc.OwnerId);
      if (!AllOwnerIdAccountMap.containsKey(acc.OwnerId)) {
        AllOwnerIdAccountMap.put(acc.OwnerId, new List<Account>());
      }
      AllOwnerIdAccountMap.get(acc.OwnerId).add(acc);

      if (
        oldAccountMap.containsKey(acc.Id) &&
        acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId
      ) {
        userIdSet.add(oldAccountMap.get(acc.Id).OwnerId);
        if (
          !AllOwnerIdAccountMap.containsKey(oldAccountMap.get(acc.Id).OwnerId)
        ) {
          AllOwnerIdAccountMap.put(
            oldAccountMap.get(acc.Id).OwnerId,
            new List<Account>()
          );
        }

        AllOwnerIdAccountMap.get(oldAccountMap.get(acc.Id).OwnerId).add(acc);
      }
    }

    userList = [SELECT Id, Email, Name FROM User WHERE Id IN :userIdSet];

    if (!userList.isEmpty()) {
      for (User use : userList) {
        userToEmailMap.put(use.Id, use.Email);
        userToNameMap.put(use.Id, use.Name);
      }
    }

    for (Id u : AllOwnerIdAccountMap.keyset()) {
      AccountsTable = cloneAccountsTable;
      num = 1;
      for (Account acc : AllOwnerIdAccountMap.get(u)) {
        AccountsTable +=
          strTROpen +
          strTDOpen +
          ' ' +
          num +
          ' ' +
          strTDClose +
          strTDOpen +
          ' ' +
          acc.Name +
          ' ' +
          strTDClose +
          strTDOpen +
          ' ' +
          userToNameMap.get(oldAccountMap.get(acc.Id).OwnerId) +
          ' ' +
          strTDClose +
          strTDOpen +
          ' ' +
          userToNameMap.get(acc.OwnerId) +
          ' ' +
          strTDClose +
          strTRClose;
        //strTDOpen + acc.CVIF__c + strTDClose + strTRClose;
        num++;
      }

      AccountsTable += Label.OWNER_CHANGE_FOOTER;

      if (userToEmailMap.containsKey(u) && userToEmailMap.get(u) != null) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ userToEmailMap.get(u) });
        mail.setSubject('Account Portfolio Change');
        mail.setHTMLBody(AccountsTable);
        list_singleEmails.add(mail);
      }
    }

    if (list_singleEmails.size() > 0) {
      TriggerHandler.bypass('EmailMessageTriggerHandler');
      Messaging.sendEmail(list_singleEmails);
      TriggerHandler.clearBypass('EmailMessageTriggerHandler');
    }
  }
}
/*list_singleEmails.clear();
        
        for(Id u: oldOwnerIdAccountMap.keyset()){
            
            AccountsTable2 = cloneAccountsTable2;
            for(Account acc: oldOwnerIdAccountMap.get(u)){
                
                AccountsTable2 += strTROpen + strTDOpen + acc.Name + strTDClose +
                    strTDOpen + userToNameMap.get(oldAccountMap.get(acc.Id).OwnerId) + strTDClose +
                    strTDOpen + userToNameMap.get(acc.OwnerId) + strTDClose + 
                    strTDOpen + acc.CVIF__c + strTDClose + strTRClose;
            }
            
            AccountsTable2+= Label.ATN_EMAIL_FOOTER_HTML;
            
            if(userToEmailMap.containsKey(u) && userToEmailMap.get(u) != Null){
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[]{userToEmailMap.get(u)});
                mail.setSubject('Old accounts that are now assigned to another user');
                mail.setHTMLBody(AccountsTable2);
                list_singleEmails.add(mail);    
                
            }
        }
        
        if(list_singleEmails.size() > 0){
            Messaging.sendEmail(list_singleEmails);
        }
    }
    
} */
