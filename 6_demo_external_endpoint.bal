import ballerina/config;
import ballerina/http;
import wso2/twitter;

http:Client homer = new("https://thesimpsonsquoteapi.glitch.me");

twitter:Client tw = new({
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig: {}  
});

@http:ServiceConfig { basePath: "/" }
service hello on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) {

        var hResp = checkpanic homer->get("/quote");
        var status = checkpanic hResp.getTextPayload();
        status = status + " #ballerina";

        twitter:Status st = checkpanic tw->tweet(status);
        json myJson = {
            text: status,
            id: st.id,
            agent: "ballerina"
        };

        checkpanic caller->respond(untaint myJson);
    }
}
