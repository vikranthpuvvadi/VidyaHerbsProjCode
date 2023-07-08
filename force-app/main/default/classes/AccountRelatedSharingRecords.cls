/**
 * @description       : this class is used for Sharing the Record with Account Owner
 * @author            : Vikranth Puvvadi
 * @group             : 
 * @last modified on  : 07-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

public class AccountRelatedSharingRecords{
    
    public void shareRelatedRecordsOnAccOwnrChg(Map<Id, Account> accountIdMap, Map<Id, Id> mapAcctOldId, String objectName, String parentFieldName){
          new UtilityControllerClass().reShareTheRecordsToAccOwner(accountIdMap,mapAcctOldId,objectName,parentFieldName);
    }
}