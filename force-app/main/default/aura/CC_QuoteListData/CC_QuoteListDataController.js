({
  doInit: function (component, event, helper) {
    console.log("inside data component");
  },
  handleDataValueChange: function (component, event, helper) {
    helper.modifyData(component, event, helper);
  },
  handleAccountClick: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idAccount = event.currentTarget.id;
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
  handleQuoteNumberClick: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idQuote = event.currentTarget.id;
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "quote-detail"
      },
      state: {
        id: idQuote
      }
    };
    navService.navigate(pageReference);
  },
  handleMenuSelect: function (component, event, helper) {
    var idQuote = event.getSource().get("v.class");
    var selectedMenu = event.detail.menuItem.get("v.value");
    switch (selectedMenu) {
      case "email":
        component.set("v.showSendEmail", "true");
        component.set("v.recordId", idQuote);
        break;
      case "requote":
        component.set("v.recordId", idQuote);
        helper.handleReQuoteClick(component, event, helper);
        break;
      case "book":
        component.set("v.recordId", idQuote);
        helper.handleBookClick(component, event, helper);
        break;
      case "download":
        component.set("v.recordId", idQuote);
        helper.fetchURL(component, event, helper);
        break;
    }
  },

  selectedItemName: function (component, event, helper) {
    var Name = event.currentTarget.dataset.name;
    component.set("v.quoteName", Name);
  }
});
