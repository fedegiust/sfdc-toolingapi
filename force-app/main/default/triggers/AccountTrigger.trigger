trigger AccountTrigger on Account (before insert, after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        ActionsAPI.sendEmailAlert(Trigger.newMap.keySet(), 'Account', 'New_Account');
    }
}