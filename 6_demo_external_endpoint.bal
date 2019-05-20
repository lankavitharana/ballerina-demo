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

@http:ServiceConfig {
  basePath: "/"
}
service hello on new http:Listener(9090) {
    @http:ResourceConfig {
      path: "/",
      methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) {

        var hResp = checkpanic homer->get("/quotes");
        var jsonPay = checkpanic hResp.getJsonPayload();
        string payload = jsonPay[0].quote.toString();
        if (!payload.contains("#ballerina")){ payload = payload+" #ballerina #RLV"; }

        var st = checkpanic tw->tweet(payload);

        json myJson = {
            text: payload,
            id: st.id,
            agent: "ballerina"
        };
        http:Response res = new;
        res.setPayload(untaint myJson);

        checkpanic caller->respond(res);
        return;
    }
}
