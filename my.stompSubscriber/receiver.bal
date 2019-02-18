import ballerina/socket;
import ballerina/io;
import ballerina/log;
import ballerina/runtime;
import ballerina/system;

# Configurations related to a STOMP connection
#
# + host - STOMP provider url.
# + port - STOMP port.
# + config - Config.
# + login - STOMP user login.
# + passcode - STOMP passcode.
# + vhost - default stomp vhost.
# + acceptVersion - 1.1.
# + socketClient - socketConnection.
# + endOfFrame - null octet.

public type Receiver client object {

    public string host = "";
    public int port = 0;
    public string login = "";
    public string passcode = "";
    public string vhost = "";
    public string acceptVersion = "";
    private socket:Client socketClient;

    // End of frame used a null octet (^@ = \u0000).
    public string endOfFrame = "\u0000";

    public ConnectionConfiguration config = {
        host:host,
        port:port,
        login:login,
        passcode:passcode,
        vhost:vhost,
        acceptVersion:acceptVersion
    };

    public function __init(ConnectionConfiguration stompConfig) {
        self.config = stompConfig;
        //self->send(stompConfig.message,stompConfig.destination);
        self.host = stompConfig.host;
        self.port = stompConfig.port;
        self.login = stompConfig.login;
        self.passcode = stompConfig.passcode;
        self.vhost = stompConfig.vhost;
        self.acceptVersion = stompConfig.acceptVersion;
        self.socketClient = new({
                host: self.host,
                port: self.port,
                callbackService: ClientService
            });
        self->connect(stompConfig.host, stompConfig.port, stompConfig.login,
            stompConfig.passcode,
            stompConfig.vhost,
            stompConfig.acceptVersion) ;
    }

    public remote function connect(string hosts,int ports,string logins, string passcodes, string vhosts, string acceptVersions);

    //public remote function begin();

    public remote function subscribe(string destinations, string subscribeId, string ack);

    //public remote function unsubscribe(string subscribeId);

    //public remote function ack();

    public remote function disconnect();

    //public remote function nack();
};

public type ConnectionConfiguration record {
    string host;
    int port;
    string login;
    string passcode;
    string vhost;
    string acceptVersion;
};

remote function Receiver.connect(string hosts, int ports, string logins, string passcodes, string vhosts, string acceptVersions) {
    socket:Client socketClient = self.socketClient;
    io:println("Starting up the Ballerina Stomp Service\n");

    // CONNECT frame to get connected.
    string connect = "CONNECT" + "\n" + "accept-version:" + acceptVersions + "\n" + "login:" + logins + "\n" + "passcode:" + passcodes +
        "\n" + "host:" + vhosts + "\n" + "\n" + self.endOfFrame;

    byte[] payloadByte = connect.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    var writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the connect frame", writeResult);
    }
    io:println("Successfully connected to stomp broker");

    // Make the publisher wait until it sends the message to the destination.
    runtime:sleep(5000);

    //var startBegin = self->begin();
}

//remote function Receiver.begin(){
//    socket:Client socketClient = self.socketClient;
//
//    // Generating unique id for message reciept.
//    string transactionId = system:uuid();
//
//    string begin = "BEGIN" + "\n" + "transaction:" + transactionId + "\n" + "\n" + self.endOfFrame;
//
//    byte[] payloadByte = begin.toByteArray("UTF-8");
//    // Send desired content to the server using the write function.
//    var writeResult = socketClient->write(payloadByte);
//    if (writeResult is error) {
//        io:println("Unable to write the connect frame", writeResult);
//    }
//    io:println(" Begin has been made with transaction: ", transactionId);
//}

remote function Receiver.subscribe(string destinations, string subscribeId, string ack){
    socket:Client socketClient = self.socketClient;

    //"subscribe" + "\n" + "destination:"+ destination + "\n" + "id:01\n" + "ack:client\n" + "\n" + END_OF_FRAME;
    // SUBSCRIBE frame to receive messages.
    string subscribe = "SUBSCRIBE" + "\n" + "destination:" +destinations+ "\n" + "id:"+subscribeId+ "ack:"+ack+ "\n" + "\n" + self.endOfFrame;

    byte[] payloadByte = subscribe.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    var writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the connect frame", writeResult);
    }
    io:println("Subscribed to ",destinations," with subscriptionId: ",subscribeId);

    // Make the publisher wait until it sends the message to the destination.
    runtime:sleep(5000);

    var disconnection =  self->disconnect();
    //var commit = self->commit(subscribeId);
    //var unsubscribe = self->unsubscribe(subscribeId);
}

//remote function Receiver.unsubscribe(string subscribeId){
//    socket:Client socketClient = self.socketClient;
//
//    //"subscribe" + "\n" + "destination:"+ destination + "\n" + "id:01\n" + "ack:client\n" + "\n" + END_OF_FRAME;
//    // SUBSCRIBE frame to receive messages.
//    string unsubscribe = "UNSUBSCRIBE" + "\n" + "id:"+subscribeId+ "\n" + "\n" + self.endOfFrame;
//
//    byte[] payloadByte = unsubscribe.toByteArray("UTF-8");
//    // Send desired content to the server using the write function.
//    var writeResult = socketClient->write(payloadByte);
//    if (writeResult is error) {
//        io:println("Unable to write the connect frame", writeResult);
//    }
//    io:println("Unsubscribed subscriptionId: ",subscribeId);
//
//    // Make the publisher wait until it sends the message to the destination.
//    runtime:sleep(5000);
//
//    var disconnection =  self->disconnect();
//}

//remote function Receiver.commit(string subscribeId){
//    socket:Client socketClient = self.socketClient;
//
//    string commit = "COMMIT" + "\n" + "subscription:" + subscribeId +"\n" + self.endOfFrame;
//
//    byte[] payloadByte = commit.toByteArray("UTF-8");
//    // Send desired content to server
//    var commitResult = socketClient->write(payloadByte);
//    if (commitResult is error) {
//        io:println("Unable to commit", commitResult);
//    }
//    io:println("Commit had been made");
//}

//remote function Receiver.nack(){
//
//    socket:Client socketClient = self.socketClient;
//
//    if (receiver.subscribe() is error){
//        io;prinln("Error occured");
//    }
//
//    string nack = "nack" + "\n" + "transaction:" + transactionId + "\n" + "ack" + ackId + "\n" + "\n" + self.endOfFrame;
//
//    byte[] payload = nack.toByteArray("UTF-8");
//
//    var result = socketClient->write(payload);
//    if (result is error){
//        io:println("error occured in writing nack frame into broker", result);
//    }
//        io:println("nack success");
//}

//remote function Receiver.ack(){
//    socket:Client socketClient = self.socketClient;
//
//    // Generating ack id for message received.
//    //string ackId = system:uuid();
//
//    // Generating unique id for message reciept.
//    string transactionId = system:uuid();
//
//    string ack = "ACK" + ackId + transactionId + self.endOfFrame;
//
//    byte[] payloadByte = ack.toByteArray("UTF-8");
//    // Send desired content to the server using the write function.
//    var writeResult = socketClient->write(payloadByte);
//    if (writeResult is error) {
//        io:println("Unable to write the ack frame", writeResult);
//    }
//    io:println("Disconnected from stomp broker successfully");
//}

remote function Receiver.disconnect() {
    socket:Client socketClient = self.socketClient;

    // DISCONNECT frame to disconnect.
    string disconnect = "DISCONNECT" + "\n" + "\n" + self.endOfFrame;

    byte[] payloadByte = disconnect.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    var writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the connect frame", writeResult);
    }
    io:println("Disconnected from stomp broker successfully");
}

// Callback service for the TCP client. The service needs to have four predefined resources.
service ClientService = service {

    // This is invoked once the client connects to the TCP server.
    resource function onConnect(socket:Caller caller) {
        io:println("Connect to: ", caller.remotePort);
    }

    // This is invoked when the server sends any content.
    resource function onReadReady(socket:Caller caller, byte[] content) {
        io:ReadableByteChannel byteChannel = io:createReadableChannel(content);
        io:ReadableCharacterChannel characterChannel =
        new io:ReadableCharacterChannel(byteChannel, "UTF-8");
        var str = characterChannel.read(300);
        if (str is string) {
            io:println(untaint str);
        } else {
            io:println(str);
        }
    }

    // This is invoked once the connection is closed.
    resource function onClose(socket:Caller caller) {
        io:println("Leave from: ", caller.remotePort);
    }

    // This resource is invoked for the error situation
    // if it happens during the `onConnect`, `onReadReady`, and `onClose` functions.
    resource function onError(socket:Caller caller, error err) {
        io:println(err);
    }
};

