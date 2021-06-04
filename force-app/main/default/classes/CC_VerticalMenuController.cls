public class CC_VerticalMenuController {
  @AuraEnabled
  public static List<Horizontal_Menu__mdt> getMenuItems() {
    String communityName = getCommunityName();
    List<Horizontal_Menu__mdt> list_MenuOptions = new List<Horizontal_Menu__mdt>();
    Integer newSequence = 1;
    Integer visibilityLevel = 1;
    List<String> lstVisibleTabsMasterLabel = new List<String>();
    lstVisibleTabsMasterLabel = CC_WithoutSharingUtility.getVisibleTabsMasterLabel(
      UserInfo.getUserId()
    );

    list_MenuOptions = [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Is_Active__c,
        Sequence__c,
        URL__c,
        Style_Classes__c,
        Lightning_Component_Name__c,
        Visibility_Level__c,
        Target__c
      FROM Horizontal_Menu__mdt
      WHERE
        Is_Active__c = TRUE
        AND Visibility_Level__c <= :visibilityLevel
        AND Community_Name__c = :communityName
        AND MasterLabel IN :lstVisibleTabsMasterLabel
      ORDER BY Sequence__c ASC
    ];

    for (Horizontal_Menu__mdt menu : list_MenuOptions) {
      menu.Sequence__c = newSequence++;
    }
    return list_MenuOptions;
  }
  @AuraEnabled
  public static String getCommunityName() {
    String nwid = Network.getNetworkId();
    return networkIdVsName.get(nwid);
  }

  public static Map<Id, String> networkIdVsName {
    get {
      if (networkIdVsName == null) {
        networkIdVsName = new Map<Id, String>();
        List<Network> networks = new List<Network>();
        networks = [SELECT Id, Name FROM Network];
        if (networks != null && !networks.isEmpty()) {
          for (Network network : networks) {
            networkIdVsName.put(network.Id, network.Name);
          }
        }
      }
      return networkIdVsName;
    }
    set;
  }
}
