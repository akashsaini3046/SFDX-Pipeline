({
  doInit: function (component, event, helper) {
    var newlst = [];
    var quoteObjectList = component.get("v.quoteObjectList");
    quoteObjectList.map((quote) => {
      $A.createComponent(
        "lightning:tab",
        {
          label: quote.quoteName,
          id: "tab-view-details-" + quote.quoteId,
          onactive: component.getReference("c.handleActive")
        },
        function (newTab, status, error) {
          if (status === "SUCCESS") {
            newlst.push(newTab);
            component.set("v.quoteTabs", newlst);
          } else {
            throw new Error(error);
          }
        }
      );
    });
  },
  handleActive: function (component, event, helper) {
    helper.handleActive(component, event);
  },
  closeModel: function (component, event, helper) {
    component.set("v.showQuotesCreatedMessage", false);
  },
  handleCreateProspect: function (component, event, helper) {
    component.set("v.showCreateProspect", true);
  },
  closeProspectModel: function (component, event, helper) {
    component.set("v.showCreateProspect", false);
  }
});
