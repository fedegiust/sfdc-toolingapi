public with sharing class CalloutHelper {
    public static HttpResponse sendRequest(String method, String endpoint, String body) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        req.setMethod(method);
        if (!String.isBlank(body)) {
            req.setBody(body);
        }

        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + endpoint);
        
        HttpResponse res = h.send(req);

        return res;  
    }
}
