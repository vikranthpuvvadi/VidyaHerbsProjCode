public class AccountRelatedSharingRecords{
    
    public void shareRelatedRecordsOnAccOwnrChg(Map<Id, Account> accountIdMap, Map<Id, Id> mapAcctOldId, String objectName, String parentFieldName){
          new UtilityControllerClass().reShareTheRecordsToAccOwner(accountIdMap,mapAcctOldId,objectName,parentFieldName);
    }
}