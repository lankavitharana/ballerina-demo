import ballerina/http;

service hello on new http:Listener(9090) {

   resource function hi (http:Caller caller, http:Request request) {
        http:Response res = new;
        res.setPayload("Hello World!\n");
        checkpanic caller->respond(res);
       return;
   }
}
