/**
 * @description       : Document Request Trigger
 * @author            : Vikranth Puvvadi
 * @group             : 
 * @last modified on  : 07-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger DocumentRequestsTrigger on Document_Requests__c (After insert , After update) {
      
      if(trigger.isAfter && trigger.isInsert){
        new AccountRelatedControllerClass().sharingTheRecordBasedOnSobject(trigger.New);
      }

      if(trigger.isAfter && trigger.isUpdate){
        
        Map<Id,Id> changedAccIdMap = new Map<Id,Id>();
        for(Document_Requests__c eSam : trigger.new){
            if(trigger.oldMap.get(eSam.Id).Account__c != eSam.Account__c){
                changedAccIdMap.put(eSam.Account__c,trigger.oldMap.get(eSam.Id).Account__c);
            }
        }
        
        Map<Id,Account> accountNewMap = new Map<Id,Account>([SELECT ID , OwnerId FROM Account where Id IN:changedAccIdMap.keySet()]);
        Map<Id,Id> accountOldMap = new Map<Id,Id>();
        
        for(Account eAcc : [SELECT ID , OwnerId FROM Account where Id IN:changedAccIdMap.values()]){
            accountOldMap.put(eAcc.Id,eAcc.OwnerId);
        }
        
        new UtilityControllerClass().reShareTheRecordsToAccOwner(accountNewMap,accountOldMap,'Document_Requests','Account');

            
    }
}