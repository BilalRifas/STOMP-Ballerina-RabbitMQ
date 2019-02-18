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

public type Sender client object {

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
            stompConfig.acceptVersion);
    }

    public remote function connect(string hosts,int ports,string logins, string passcodes, string vhosts, string acceptVersions);

    public remote function begin();

    public remote function send(string messages, string destinations);

    public remote function disconnect();
};

public type ConnectionConfiguration record {
    string host;
    int port;
    string login;
    string passcode;
    string vhost;
    string acceptVersion;
};

remote function Sender.connect(string hosts, int ports, string logins, string passcodes, string vhosts, string acceptVersions){
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

    var startBegin = self->begin();
}

remote function Sender.begin(){
    socket:Client socketClient = self.socketClient;

    // Generating unique id for message reciept.
    string transactionId = system:uuid();

    string begin = "BEGIN" + "\n" + "transaction:" + transactionId + "\n" + "\n" + self.endOfFrame;

    byte[] payloadByte = begin.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    var writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the connect frame", writeResult);
    }
    io:println(" Begin has been made with transaction: ", transactionId);
}

remote function Sender.send(string messages, string destinations){
    socket:Client socketClient = self.socketClient;

    // Generating unique id for message reciept.
    string messageId = system:uuid();

    // SEND frame to send message.
    string send = "SEND" + "\n" + "destination:" + destinations + "\n" + "receipt:" + messageId + "\n" + "content-type:text/plain" + "\n" + "\n" +
        messages + "\n" + "\n" + self.endOfFrame;
    //
    //if (send is error){
    //    io:println("Unable to generate SEND frame", send);
    //}

    byte[] payloadByte = send.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    var writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the connect frame", writeResult);
    }
    io:println("Message: ", messages ," is sent successfully");

    // Make the publisher wait until it sends the message to the destination.
    runtime:sleep(5000);

    var disconnection = self->disconnect();
}

remote function Sender.disconnect() {
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

