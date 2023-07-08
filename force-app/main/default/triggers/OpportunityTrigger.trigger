trigger OpportunityTrigger on Opportunity (After insert , After Update) {
			
    
    if(trigger.isAfter && trigger.isInsert){
        new AccountRelatedControllerClass().sharingTheRecordBasedOnSobject(trigger.New);
    }
      
      
       if(trigger.isAfter && trigger.isUpdate){
        
        Map<Id,Id> changedAccIdMap = new Map<Id,Id>();
        for(Opportunity eSam : trigger.new){
            if(trigger.oldMap.get(eSam.Id).AccountId != eSam.AccountId){
                changedAccIdMap.put(eSam.AccountId,trigger.oldMap.get(eSam.Id).AccountId);
            }
        }
        
        Map<Id,Account> accountNewMap = new Map<Id,Account>([SELECT ID , OwnerId FROM Account where Id IN:changedAccIdMap.keySet()]);
        Map<Id,Id> accountOldMap = new Map<Id,Id>();
        
        for(Account eAcc : [SELECT ID , OwnerId FROM Account where Id IN:changedAccIdMap.values()]){
            accountOldMap.put(eAcc.Id,eAcc.OwnerId);
        }
        
        new UtilityControllerClass().reShareTheRecordsToAccOwner(accountNewMap,accountOldMap,'Opportunity','Account');

            
    }
}