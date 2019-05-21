import ballerina/config;
import ballerina/http;
import wso2/twitter;
import ballerina/io;

twitter:Client tw = new({
        clientId: config:getAsString("clientId"),
        clientSecret: config:getAsString("clientSecret"),
        accessToken: config:getAsString("accessToken"),
        accessTokenSecret: config:getAsString("accessTokenSecret"),
        clientConfig: {}
    });

http:Client homer = new("https://thesimpsonsquoteapi.glitch.me");

@http:ServiceConfig {
    basePath: "/"
}
service hello on new http:Listener(9090) {
    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) {
        _ = start doTweet();
        http:Response res = new;
        res.setPayload("Async call\n");
        checkpanic caller->respond(res);
    }
}

function doTweet() returns error? {
    var hResp = check homer->get("/quotes");
    var jsonPay = check hResp.getJsonPayload();
    string payload = jsonPay[0].quote.toString();
    payload = payload+" #ballerina";

    twitter:Status st = check  tw->tweet(payload);
    io:println("Tweeted: " + untaint st.text);
    return;
}
