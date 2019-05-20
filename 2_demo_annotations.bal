import ballerina/http;

@http:ServiceConfig { basePath: "/" }
service hello on new http:Listener(9090) {
    @http:ResourceConfig {
        path: "/",
        methods: ["POST"]
    }
    resource function hi (http:Caller caller, http:Request request) {
        var payload = checkpanic request.getTextPayload();
        http:Response res = new;
        res.setPayload("Hello " + untaint payload + "!\n");
        checkpanic caller->respond(res);
        return;
    }
}
