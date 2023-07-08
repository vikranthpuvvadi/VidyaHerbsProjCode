trigger SampleTrigger on Sample__c (After insert , After Update) {
    
    if(trigger.isAfter && trigger.isInsert){
        new AccountRelatedControllerClass().sharingTheRecordBasedOnSobject(trigger.New);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        
        Map<Id,Id> changedAccIdMap = new Map<Id,Id>();
        Map<Id,Id> projOwnerChangeId =  new Map<Id,Id>();
        for(Sample__c eSam : trigger.new){
            if(trigger.oldMap.get(eSam.Id).Account__c != eSam.Account__c){
                changedAccIdMap.put(eSam.Account__c,trigger.oldMap.get(eSam.Id).Account__c);
            }
            if(trigger.oldMap.get(eSam.Id).Project_With_Working_With__c != eSam.Project_With_Working_With__c){
                projOwnerChangeId.put(eSam.Project_With_Working_With__c,trigger.oldMap.get(eSam.Id).Project_With_Working_With__c);
            }

        }
        
        
        if(!changedAccIdMap.isEmpty()){
            Map<Id,Account> accountNewMap = new Map<Id,Account>([SELECT ID , OwnerId FROM Account where Id IN:changedAccIdMap.keySet()]);
       		Map<Id,Id> accountOldMap = new Map<Id,Id>();
        
            for(Account eAcc : [SELECT ID , OwnerId FROM Account where Id IN:changedAccIdMap.values()]){
                accountOldMap.put(eAcc.Id,eAcc.OwnerId);
            }
            
            new UtilityControllerClass().reShareTheRecordsToAccOwner(accountNewMap,accountOldMap,'Sample','Account');
        }
        
        
        
        if(!projOwnerChangeId.isEmpty()){
            Map<Id,Account> accountNewMap = new Map<Id,Account>([SELECT ID , OwnerId FROM Account where Id IN:projOwnerChangeId.keySet()]);
       		Map<Id,Id> accountOldMap = new Map<Id,Id>();
        
            for(Account eAcc : [SELECT ID , OwnerId FROM Account where Id IN:projOwnerChangeId.values()]){
                accountOldMap.put(eAcc.Id,eAcc.OwnerId);
            }
            
            new UtilityControllerClass().reShareTheRecordsToAccOwner(accountNewMap,accountOldMap,'Sample','Account');
        }
        
        

            
    }
    
     
     
    
}