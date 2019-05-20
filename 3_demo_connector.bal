import ballerina/config;
import ballerina/http;
import wso2/twitter;

twitter:Client tw = new({
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig: {}
});

@http:ServiceConfig {
    basePath: "/"
}
service hello on new http:Listener(9090) {
    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) {
        http:Response res = new;
        string payload = checkpanic request.getTextPayload();
        twitter:Status st = checkpanic tw->tweet(payload);
        res.setPayload("Tweeted: " + untaint st.text + "\n");
        checkpanic caller->respond(res);
        return;
    }
}
