trigger ContentDocumentTrigger on ContentDocument(after insert, before delete) {
  new ContentDocumentTriggerHandler().run();
}
