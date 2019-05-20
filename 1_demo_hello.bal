import ballerina/http;

service hello on new http:Listener(9090) {

    resource function hi(http:Caller caller, http:Request request) {
        checkpanic caller -> respond("Hello World!\n");
    }
}
