import ballerina/config;
import ballerina/http;
import wso2/twitter;

http:Client homer = new("https://thesimpsonsquoteapi.glitch.me", config={
        circuitBreaker: {
            failureThreshold: 0.0,
            resetTimeMillis: 3000,
            statusCodes: [500, 501, 502]
        },
        timeoutMillis: 900
    });

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

        var quote = homer->get("/quote");
        json resp;
        if (quote is http:Response) {
            var payload = checkpanic quote.getTextPayload();
            payload = payload + " #ballerina";

            var st = checkpanic tw->tweet(payload);
            resp = {
                text: payload,
                id: st.id,
                agent: "ballerina"
            };
        } else {
            resp = "Circuit is open. Invoking default behavior.\n";
        }

        checkpanic caller->respond(untaint resp);
    }
}
