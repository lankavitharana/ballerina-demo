import ballerina/config;
import ballerina/http;
import wso2/twitter;
import ballerinax/kubernetes;

twitter:Client tw = new({
    clientId: config:getAsString("clientId"),
    clientSecret: config:getAsString("clientSecret"),
    accessToken: config:getAsString("accessToken"),
    accessTokenSecret: config:getAsString("accessTokenSecret"),
    clientConfig:{}
});

@kubernetes:Service {
    serviceType: "NodePort",
    name: "ballerina-demo"
}
listener http:Listener cmdListener = new(9090);


http:Client homer = new("https://thesimpsonsquoteapi.glitch.me");

@kubernetes:Deployment {
    image: "demo/ballerina-demo",
    name: "ballerina-demo",
    dockerHost: "tcp://192.168.99.100:2376",
    dockerCertPath: "/home/rajith/.minikube/certs"
}
@kubernetes:ConfigMap{
    conf: "twitter.toml"
}
@http:ServiceConfig {
    basePath: "/"
}
service hello on cmdListener {
    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) {
        var custMsg = trap request.getTextPayload();

        var hResp = checkpanic homer->get("/quotes");
        var jsonPay = checkpanic hResp.getJsonPayload();
        string payload = jsonPay[0].quote.toString();        
        if (custMsg is string) { payload = payload + " " + custMsg; }
        if (!payload.contains("#ballerina")){ payload = payload + " #ballerina #RLV"; }

        twitter:Status st = checkpanic tw->tweet(payload);

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
