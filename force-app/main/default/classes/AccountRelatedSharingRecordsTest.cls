@isTest
public class AccountRelatedSharingRecordsTest {
    @isTest
    public static void testShareRelatedRecordsOnAccOwnrChg() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', AccountId = testAccount.Id, StageName = 'Closed Won', CloseDate = Date.today());
        insert testOpportunity;

        // Create the instance of the AccountRelatedSharingRecords class
        AccountRelatedSharingRecords sharingRecords = new AccountRelatedSharingRecords();

        // Create a map of Account records with the Account Id and the updated Owner Id
        Map<Id, Account> accountIdMap = new Map<Id, Account>();
        accountIdMap.put(testAccount.Id, testAccount);

        // Create a map of the old Account Ids and the updated Account Ids
        Map<Id, Id> mapAcctOldId = new Map<Id, Id>();
        mapAcctOldId.put(testAccount.Id, testAccount.Id);

        // Specify the object name and parent field name
        String objectName = 'Opportunity';
        String parentFieldName = 'Account';

        // Call the shareRelatedRecordsOnAccOwnrChg method
        Test.startTest();
        sharingRecords.shareRelatedRecordsOnAccOwnrChg(accountIdMap, mapAcctOldId, objectName, parentFieldName);
        Test.stopTest();

        // Perform assertions to verify the results
        // ...

        // Example assertions
        // Verify that the Opportunity share records were created or updated correctly
        List<OpportunityShare> opportunityShares = [SELECT Id, RowCause, UserOrGroupId, OpportunityAccessLevel FROM OpportunityShare WHERE OpportunityId = :testOpportunity.Id];
        System.assertEquals(1, opportunityShares.size());
        OpportunityShare opportunityShare = opportunityShares[0];
        System.assertEquals('Manual', opportunityShare.RowCause);
        System.assertEquals(testAccount.OwnerId, opportunityShare.UserOrGroupId);
        System.assertEquals('Edit', opportunityShare.OpportunityAccessLevel);
    }
}