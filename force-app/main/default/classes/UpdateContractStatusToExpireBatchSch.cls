/*
 * Name: UpdateContractStatusToExpireBatchSch
 * Purpose: Schedule Batch Class UpdateContractStatusToExpireBatch to run daily.
 * Author: Nagarro
 * Created Date: 29-Dec-2020
 * Test Class : ContractTriggerHandler_Test
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
global class UpdateContractStatusToExpireBatchSch implements Schedulable {
  global void execute(SchedulableContext sc) {
    Database.executeBatch(new UpdateContractStatusToExpireBatch());
  }
}
