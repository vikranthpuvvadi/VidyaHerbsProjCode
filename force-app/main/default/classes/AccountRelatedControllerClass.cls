/**
 * @description       : this class is used for Sharing the Record with Account Owner
 * @author            : Vikranth Puvvadi
 * @group             : 
 * @last modified on  : 07-08-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public without sharing class AccountRelatedControllerClass {


    public void sharingTheRecordBasedOnSobject(list < sObject > newList) {
        try {

            Map < Id, String > sObjMap = new Map < Id, String > ();
            Map < Id, Id > acctOwnerIdMap = new Map < Id, Id > ();
            Map < Id, Id > prjAccOwnIdMap = new Map < Id, Id > ();
            list < sObject > objList = new list < sObject > ();
            for (sObject eSoj: newList) {

                if (!String.isEmpty(eSoj.Id)) {
                    String sObjName = getSobjName(eSoj.Id);
                    if (!String.isEmpty(sObjName)) {
                        sObjMap.put(eSoj.Id, sObjName);

                        String accountId = getAccountIdBasedOnSobject(eSoj.Id, sObjName);
                        if (!String.isEmpty(accountId)) {
                            acctOwnerIdMap.put(eSoj.Id, accountId);
                        }

                        if (sObjName.equals('Sample__c') && eSoj.get('Project_With_Working_With__c') != null) {
                            String projectAccountId = getProjectSampleAccountId(eSoj.Id, sObjName);
                            if (!String.isEmpty(projectAccountId)) {
                                prjAccOwnIdMap.put(eSoj.Id, projectAccountId);
                            }
                        }
                    }
                }


            }

            // system.debug('line 27 acctOwnerIdMap'+acctOwnerIdMap);

            if (!sObjMap.isEmpty() && !acctOwnerIdMap.isEmpty()) {
                for (Id eId: sObjMap.keySet()) {
                    String objectName = sObjMap.get(eId);
                    if (objectName.contains('__c')) {
                        objectName = objectName.replace('__c', '__share');

                    } else if (!objectName.contains('__c')) {
                        objectName = objectName + 'share';
                    }
                    Sobject eObj = (Sobject) type.forName(objectName).newInstance();

                    eObj.put('RowCause', 'Manual');
                    eObj.put('UserOrGroupId', acctOwnerIdMap.get(eId));
                    if (eObj instanceof Quote__Share || eObj instanceof Sample__share || eObj instanceof Supply_Agreement__Share) {
                        eObj.put('AccessLevel', 'Edit');
                        eObj.put('ParentId', eId);
                    } else if (eObj instanceof Opportunityshare) {
                        eObj.put('OpportunityAccessLevel', 'Edit');
                        eObj.put('OpportunityId', eId);
                    }

                    objList.add(eObj);

                }

            }

            if (!sObjMap.isEmpty() && !prjAccOwnIdMap.isEmpty()) {
                for (Id eId: sObjMap.keySet()) {
                    String objectName = sObjMap.get(eId);
                    if (objectName.contains('__c')) {
                        objectName = objectName.replace('__c', '__share');
                    } else if (!objectName.contains('__c')) {
                        objectName = objectName + 'share';
                    }
                    Sobject eObj = (Sobject) type.forName(objectName).newInstance();
                    eObj.put('ParentId', eId);
                    eObj.put('RowCause', 'Manual');
                    eObj.put('UserOrGroupId', prjAccOwnIdMap.get(eId));
                    if (eObj instanceof Quote__Share || eObj instanceof Sample__share || eObj instanceof Supply_Agreement__Share) {
                        eObj.put('AccessLevel', 'Edit');
                    } else if (eObj instanceof Opportunityshare) {
                        eObj.put('OpportunityAccessLevel', 'Edit');
                    }

                    objList.add(eObj);

                }
            }



            if (objList.size() > 0) {
                Database.insert(objList, false);
                system.debug('sharesToCreate' + objList);
            }

        } catch (Exception e) {
            system.debug('Line Number ' + e.getLineNumber() + 'Message' + e.getMessage());
        }

    }
    private static String getSobjName(Id recordId) {
        SObject record = recordId.getSObjectType().newSObject();
        String objectName = record.getSObjectType().getDescribe().getName();
        return objectName;
    }
    private static String getAccountIdBasedOnSobject(Id recordId, String objectType) {
        String query;
        String accountOwnerId;
        if (objectType.equals('Opportunity')) {
            query = 'Select ID ,  AccountId FROM ' + string.escapeSingleQuotes(objectType) + ' Where Id  =: recordId  Limit 1';
            sObject sObj = database.query(query);
            accountOwnerId = [SELECT ID, OwnerId FROM ACCOUNT Where Id =: (Id) sObj.get('AccountId') limit 1].OwnerId;
        } else {
            query = 'Select ID ,  Account__r.OwnerId FROM ' + string.escapeSingleQuotes(objectType) + ' Where Id  =: recordId  Limit 1';
            sObject sObj = database.query(query);
            //system.debug(sObj.get('Account__r.OwnerId'));
            accountOwnerId = [SELECT ID, OwnerId FROM ACCOUNT Where Id =: (Id) sObj.get('Account__c') limit 1].OwnerId;
        }


        return accountOwnerId;
    }

    private static String getProjectSampleAccountId(Id recordId, String objectType) {

        String query = 'Select ID ,  Project_With_Working_With__c FROM ' + string.escapeSingleQuotes(objectType) + ' Where Id  =: recordId  Limit 1';
        sObject sObj = database.query(query);
        //system.debug(sObj.get('Account__r.OwnerId'));
        String accountOwnerId = [SELECT ID, OwnerId FROM ACCOUNT Where Id =: (Id) sObj.get('Project_With_Working_With__c') limit 1].OwnerId;
        return accountOwnerId;
    }
}









/*




*/









/*switch on objectName {
                        when 'Quote__c' {		// when block 1
                            Quote__Share eShare =  new Quote__Share();
                                eShare.ParentId = eId;
                                eShare.UserOrGroupId =acctOwnerIdMap.get(eId);
                                eShare.RowCause = 'Manual';
                                eShare.AccessLevel = 'Edit';
                                objList.add(eShare); 
                        }	
                        when 'Sample__c' {		// when block 2
                            Sample__share eShare = new Sample__share();
                            eShare.ParentId = eId;
                            eShare.UserOrGroupId =acctOwnerIdMap.get(eId);
                            eShare.RowCause = 'Manual';
                            eShare.AccessLevel = 'Edit';
                            objList.add(eShare);                            
                        }
                        when 'Opportunityshare' {		// when block 3
                            Opportunityshare eShare = new Opportunityshare();
                            eShare.OpportunityId = eId;
                            eShare.UserOrGroupId =acctOwnerIdMap.get(eId);
                            eShare.RowCause = 'Manual';
                            eShare.OpportunityAccessLevel = 'Edit';
                            objList.add(eShare);
                        }
                        when 'Supply_Agreement__c' {		  // default block, optional
                            Supply_Agreement__Share eShare  =  new Supply_Agreement__Share();
                            eShare.ParentId = eId;
                            eShare.UserOrGroupId =acctOwnerIdMap.get(eId);
                            eShare.RowCause = 'Manual';
                            eShare.AccessLevel = 'Edit';
                            objList.add(eShare); 
                            
                        }
                    }*/









/* 
                if(!String.isEmpty(eSoj.Id)){
                if(!String.isEmpty(getSobjName(eSoj.Id))){
                     sObjMap.put(eSoj.Id,getSobjName(eSoj.Id));
                    if(!String.isEmpty(getAccountIdBasedOnSobject(eSoj.Id,getSobjName(eSoj.Id)))){
                         acctOwnerIdMap.put(eSoj.Id,getAccountIdBasedOnSobject(eSoj.Id,getSobjName(eSoj.Id)));
                    }
                    if(getSobjName(eSoj.Id).equals('Sample__c')&& eSoj.get('Project_With_Working_With__c')!=null){
                        //system.debug('Inside the If Project_With_Working_With__c'+eSoj.get('Project_With_Working_With__c'));
                        if(!String.isEmpty(getProjectSampleAccountId(eSoj.Id,getSobjName(eSoj.Id)))){
                          // system.debug('Inside the If  if Project_With_Working_With__c'+eSoj.get('Project_With_Working_With__c'));
                            prjAccOwnIdMap.put(eSoj.Id,getProjectSampleAccountId(eSoj.Id,getSobjName(eSoj.Id)));
                        }
                    }
                  }
            }




*/