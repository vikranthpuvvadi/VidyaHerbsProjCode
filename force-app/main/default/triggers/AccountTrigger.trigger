trigger AccountTrigger on Account (After Update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        map<Id, Account> accountIdMap = new map<Id,Account>();
        map<ID,ID> mapAcctOldId = new map<Id,Id>();
        for(Account eAcc : trigger.New){
            if(eAcc.OwnerId != trigger.oldMap.get(eAcc.Id).OwnerId){
                accountIdMap.put(eAcc.Id,eAcc);
                mapAcctOldId.put(eAcc.Id,trigger.oldMap.get(eAcc.Id).OwnerId);
            }
        }
        if(!accountIdMap.isEmpty()){
            new AccountRelatedSharingRecords().shareRelatedRecordsOnAccOwnrChg(accountIdMap, mapAcctOldId,'Quote','Account');
            new AccountRelatedSharingRecords().shareRelatedRecordsOnAccOwnrChg(accountIdMap, mapAcctOldId,'Sample','Account');
            new AccountRelatedSharingRecords().shareRelatedRecordsOnAccOwnrChg(accountIdMap, mapAcctOldId,'Supply_Agreement','Account');
            new AccountRelatedSharingRecords().shareRelatedRecordsOnAccOwnrChg(accountIdMap, mapAcctOldId,'Opportunity','Account');

        }
    }
}