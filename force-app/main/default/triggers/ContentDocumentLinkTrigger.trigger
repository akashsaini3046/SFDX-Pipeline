trigger ContentDocumentLinkTrigger on ContentDocumentLink(
  after insert,
  before delete
) {
  new ContentDocumentLinkTriggerHandler().run();
}
