({
  doInit: function (component, event, helper) {
    var idContract = helper.getURLParameter("id");
    var columns = ["Affiliates", "CVIF ID"];
    component.set("v.columns", columns);
    component.set("v.recordId", idContract);
    helper.getContracts(component, event, helper);
  },
  viewdetail: function (component, event, helper) {
    var navService = component.find("navigationService");
    var redirectUrl = event.currentTarget.id;
    var selectedItemID = redirectUrl.substring(
      redirectUrl.lastIndexOf("/") + 1,
      redirectUrl.length
    );
    var redirectPageName = redirectUrl.substring(0, redirectUrl.indexOf("/"));
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: redirectPageName
      },
      state: {
        id: selectedItemID
      }
    };
    navService.navigate(pageReference);
  },

  navigateToAccount: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "accounts"
      }
    };
    navService.navigate(pageReference);
  },
  navigateToAccountDetail: function (component, event, helper) {
    var navService = component.find("navigationService");
    var contract = component.get("v.contract");
    var idAccount = contract.Account.Id;
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "accountDetail"
      },
      state: {
        id: idAccount
      }
    };
    navService.navigate(pageReference);
  },
  navigateToRecord: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idContract = component.get("v.recordId");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "contractDetail"
      },
      state: {
        id: idContract
      }
    };
    navService.navigate(pageReference);
  },
  navigateToHome: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  }
});
