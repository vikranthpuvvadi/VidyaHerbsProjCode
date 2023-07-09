/**
 * @description       : this class is used for Sharing the Record with Account Owner
 * @author            : Vikranth Puvvadi
 * @group             : 
 * @last modified on  : 07-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/

public without sharing class UtilityControllerClass {
   public void reShareTheRecordsToAccOwner(Map<Id, Account> accountIdMap, Map<Id, Id> mapAcctOldId, String objectName, String parentFieldName) {
      system.debug('sObject' + relatedObjectQery(accountIdMap, objectName, parentFieldName));
      list<sObject> sObjList = database.query(relatedObjectQery(accountIdMap, objectName, parentFieldName));
      system.debug('sObjList' + sObjList);
      if (!sObjList.isEmpty()) {
         map<Id, Id> sObjAccNewIdOwner = new map<Id, Id>();
         map<Id, Id> sObjAccIdMap = new map<Id, Id>();
         for (sObject eSobj : sObjList) {
            if (objectName == 'Opportunity') {
               sObjAccIdMap.put((Id) eSobj.get('Id'), (Id) eSobj.get('AccountId'));
               sObjAccNewIdOwner.put((Id) eSobj.get('Id'), accountIdMap.get((Id) eSobj.get('AccountId')).OwnerId);
            } else {
               sObjAccIdMap.put((Id) eSobj.get('Id'), (Id) eSobj.get('Account__c'));
               sObjAccNewIdOwner.put((Id) eSobj.get('Id'), accountIdMap.get((Id) eSobj.get('Account__c')).OwnerId);
            }
         }

         if (!sObjAccIdMap.isEmpty()) {
            system.debug('sObjAccNewIdOwner' + sObjAccNewIdOwner);
            String sObjAccString = string.join(new list<Id>(sObjAccIdMap.keySet()), '\',\'');
            String userOrGroupsIdString = string.join((list<Id>) mapAcctOldId.values(), '\',\'');
            string userOrGroupNewIdString = string.join((list<Id>) sObjAccNewIdOwner.values(), '\',\'');
            String manual = 'Manual';

            String query;
            if (objectName == 'Opportunity') {
               query = 'SELECT ID , OpportunityAccessLevel ,OpportunityId ,RowCause ,UserOrGroupId FROM ' + objectName + 'Share' + ' WHERE OpportunityId ' + 'IN (\'' + sObjAccString + '\')' + ' AND UserOrGroupId IN (\'' + UserOrGroupsIdString + '\')';
            } else {
               query = 'SELECT ID , AccessLevel ,ParentId ,RowCause ,UserOrGroupId FROM ' + objectName + '__share ' + ' WHERE ParentId ' + 'IN (\'' + sObjAccString + '\')' + ' AND UserOrGroupId IN (\'' + UserOrGroupsIdString + '\')';
            }

            set<Id> checkForOwnerSet = new set<Id>();
            for (SObject eShr : database.query(query)) {
               if ((String) eShr.get('RowCause') == 'Owner') {
                  if (objectName == 'Opportunity') {
                     checkForOwnerSet.add((Id) eShr.get('OpportunityId'));
                  } else {
                     checkForOwnerSet.add((Id) eShr.get('ParentId'));
                  }
               }
            }

            String queryAll;
            if (objectName == 'Opportunity') {
               queryAll = 'SELECT ID , OpportunityAccessLevel ,OpportunityId ,RowCause ,UserOrGroupId FROM ' + objectName + 'Share' + ' WHERE OpportunityId ' + 'IN (\'' + sObjAccString + '\')' + ' AND ' + ' UserOrGroupId IN (\'' + userOrGroupNewIdString + '\')';
            } else {
               queryAll = 'SELECT ID , AccessLevel ,ParentId ,RowCause ,UserOrGroupId FROM ' + objectName + '__share ' + ' WHERE ParentId ' + 'IN (\'' + sObjAccString + '\')' + ' AND ' + ' UserOrGroupId IN (\'' + userOrGroupNewIdString + '\')';
            }
            // Check for RowCause = All

            system.debug('query' + query);
            system.debug('queryAll' + queryAll);
            system.debug('queryAll' + database.query(queryAll));

            set<Id> checkUserSet = new set<Id>();
            for (SObject eShr : database.query(queryAll)) {
               if ((String) eShr.get('RowCause') == 'Owner') {
                  if (objectName == 'Opportunity') {
                     checkUserSet.add((Id) eShr.get('OpportunityId'));
                  } else {
                     checkUserSet.add((Id) eShr.get('ParentId'));
                  }
               }
            }

            system.debug('checkUserSet' + checkUserSet);

            list<SObject> newShareList = new list<SObject>();
            list<SObject> oldShareList = new list<SObject>();
            System.debug('dataBaseQuery' + database.query(query));
            for (SObject eObjShr : database.query(query)) {
               Sobject eObj;
               if (objectName == 'Opportunity') {
                  eObj = (Sobject) type.forName(objectName + 'share').newInstance();
                  eObj.put('OpportunityId', (Id) eObjShr.get('OpportunityId'));
                  eObj.put('RowCause', 'Manual');
                  eObj.put('UserOrGroupId', accountIdMap.get(sObjAccIdMap.get((Id) eObjShr.get('OpportunityId'))).OwnerId);
                  eObj.put('OpportunityAccessLevel', 'Edit');
               } else {
                  eObj = (Sobject) type.forName(objectName + '__share').newInstance();
                  eObj.put('ParentId', (Id) eObjShr.get('ParentId'));
                  eObj.put('RowCause', 'Manual');
                  eObj.put('UserOrGroupId', accountIdMap.get(sObjAccIdMap.get((Id) eObjShr.get('ParentId'))).OwnerId);
                  eObj.put('AccessLevel', 'Edit');
               }
               newShareList.add(eObj);

               if (objectName == 'Opportunity') {
                  if (!checkForOwnerSet.contains((Id) eObjShr.get('OpportunityId'))) {
                     oldShareList.add(eObjShr);
                  }
               } else {
                  if (!checkForOwnerSet.contains((Id) eObjShr.get('ParentId'))) {
                     oldShareList.add(eObjShr);
                  }
               }
            }
            system.debug('newShareList' + newShareList);
            system.debug('oldShareList' + oldShareList);

            if (!newShareList.isEmpty()) {
               system.debug('newShareList' + newShareList);
               insert newShareList;
            }
            if (!oldShareList.isEmpty()) {
               delete oldShareList;
               system.debug('oldShareList' + oldShareList);
            }
         }
      }
   }
   private string relatedObjectQery(Map<Id, Account> accountIdMap, String objectName, String parentFieldName) {
      list<Id> accList = new list<Id>();
      for (Id eId : accountIdMap.keySet()) {
         accList.add(eId);
      }

      String idsString = String.join(new List<Id>(accountIdMap.keySet()), '\',\'');

      String query;

      if (objectName.equals('Opportunity')) {
         query = 'SELECT ID, ' + parentFieldName + 'Id' + ' FROM ';
         query += objectName;
         query += ' WHERE ' + parentFieldName + 'Id' + ' IN (\'' + idsString + '\')';

      } else {
         query = 'SELECT ID, ' + parentFieldName + '__c' + ' FROM ';
         query += objectName + '__c';
         query += ' WHERE ' + parentFieldName + '__c ' + 'IN (\'' + idsString + '\')';
      }

      // String whereClause = 'WHERE Id IN (\'' + idsString + '\')';

      return query;
   }

   private static String getSobjName(Id recordId) {
      SObject record = recordId.getSObjectType().newSObject();
      String objectName = record.getSObjectType().getDescribe().getName();
      return objectName;
   }
}