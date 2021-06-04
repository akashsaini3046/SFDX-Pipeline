public with sharing class CommonUtility {
  public static String getCommunityName() {
    String nwid = networkId;
    if (!String.isBlank(nwid)) {
      String communityName = [SELECT name FROM Network WHERE id = :nwid][0]
      .name;
      return communityName;
    } else {
      return null;
    }
  }

  public static String getCommunityUrlPathPrefix() {
    String nwid = networkId;
    if (!String.isBlank(nwid)) {
      String communityUrlPathPrefix = [
        SELECT UrlPathPrefix
        FROM Network
        WHERE id = :nwid
      ][0]
      .UrlPathPrefix;
      return communityUrlPathPrefix;
    } else {
      return null;
    }
  }

  public static String networkId {
    get {
      if (networkId == null) {
        networkId = Network.getNetworkId();
      }
      return networkId;
    }
    set;
  }
}
