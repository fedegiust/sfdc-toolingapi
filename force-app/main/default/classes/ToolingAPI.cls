public with sharing class ToolingAPI {
    public static final String TOOLING_BASE_RESOURCE = '/services/data/v50.0/tooling';

    public static HttpResponse traceFlags(String entityId, String logType,Integer period, String debugLevelId) {
        Map<String, Object> payload = new Map<String, Object>();

        payload.put('DebugLevelId', debugLevelId);
        payload.put('StartDate', DateTime.now());
        payload.put('ExpirationDate', DateTime.now().addHours(period));
        payload.put('LogType', logType);
        payload.put('TracedEntityId', entityId);
                
        HttpResponse res = CalloutHelper.sendRequest('POST', TOOLING_BASE_RESOURCE + '/sobjects/TraceFlag', JSON.serialize(payload));

        return res;        
    }

    public static HttpResponse sobjectsDescribe() {
        HttpResponse res = CalloutHelper.sendRequest('GET', TOOLING_BASE_RESOURCE + '/sobjects/', null);
        return res;      
    }
}
