public with sharing class ActionsAPI {
    public static final String ACTIONS_BASE_URL = '/services/data/v51.0/actions';

    /**
     * sendEmailAlert
     * Thie method will decide if we should process the email alert in Sync or Async mode.
     * Then it will send email alerts based on the record and entity to process
     *
     * @param sobjId         Set with record ids to process the action
     * @param entityName     Name of the object the action is related to (Opportunity)
     * @param emailAlertName Email alert api name
     */
    public static String sendEmailAlert(Set<Id> sobjId, String entityName, String emailAlertName) {
        
        if (!Test.isRunningTest() && !System.isFuture()) {
            sendEmailAlertAsync(sobjId, entityName, emailAlertName);
            return 'Will process in future';
        } else {
            return sendEmailAlertSync(sobjId, entityName, emailAlertName);
        }
    }

    /**
     * sendEmailAlertAsync
     * Will process the email alert in Async mode
     *
     * @param sobjId         Set with record ids to process the action
     * @param entityName     Name of the object the action is related to (Opportunity)
     * @param emailAlertName Email alert api name
     */
    @future(callout=true)
    public static void sendEmailAlertAsync(Set<Id> sobjId, String entityName, String emailAlertName) {
        sendEmailAlertSync(sobjId, entityName, emailAlertName);
    }

    /**
     * sendEmailAlertAsync
     * Will process the email alert in Sync mode returning a string with the response
     *
     * @param sobjId         Set with record ids to process the action
     * @param entityName     Name of the object the action is related to (Opportunity)
     * @param emailAlertName Email alert api name
     */
    public static String sendEmailAlertSync(Set<Id> sobjId, String entityName, String emailAlertName) {
        String response;
        try {
            Map<String, List<Map<String, Object>>> payload = new Map<String, List<Map<String, Object>>>();

            payload.put('inputs', new List<Map<String, Object>>());
            for (Id oId : sobjId) {
                payload.get('inputs').add(new Map<String, Object>{ 'SObjectRowId' => String.valueOf(oId) });
            }

            HttpResponse res = CalloutHelper.sendRequest('POST', ACTIONS_BASE_URL +
                                                '/custom/emailAlert/' +
                                                entityName +
                                                '/' +
                                                emailAlertName, JSON.serialize(payload));

            response = res.getBody();

            List<Task> tasksToCreate = new List<Task>();

            for (Id oId : sobjId) {
                tasksToCreate.add(
                    new Task(
                        WhatId = oId,
                        Type = 'Email',
                        TaskSubtype = 'Email',
                        Subject = 'Email Alert Sent: ' + emailAlertName,
                        Status = 'Completed',
                        Priority = 'Low',
                        OwnerId = UserInfo.getUserId(),
                        Description = response
                    )
                );
            }

            if (!tasksToCreate.isEmpty() && Task.SObjectType.getDescribe().isCreateable()) {
                insert tasksToCreate;
            }
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        return response;
    }
}
