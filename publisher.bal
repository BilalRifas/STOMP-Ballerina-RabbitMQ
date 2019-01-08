// This is the client implementation for the stomp protocol with TCP socket to publish message to broker.
import ballerina/io;
import ballerina/socket;
import ballerina/config;
import ballerina/runtime;

// Stomp TCP socket configuration.
string Host = config:getAsString("HOST");
int Port = config:getAsInt("PORT");

public function main() {

    // Create a new socket client by providing the host, port, and callback service.
    socket:Client socketClient = new({ host: Host, port: Port,
            callbackService: ClientService });

    io:println("Starting up the Ballerina Stomp Service\n");
    // Headers.
    string destination = "/queue/test";
    string login = "guest";
    string passcode = "guest";
    string vhost = "/";
    string transactionId = "transaction-1";

    // End of frame used a null octet (^@ = \u0000).
    string END_OF_FRAME = "\u0000";

    // CONNECT frame to get connected.
    string connect = "CONNECT"+"\n"+"accept-version:1.1\n"+"login:"+login+"\n"+"passcode:"+passcode+"\n"+
        "host:"+vhost+"\n"+"\n"+END_OF_FRAME;
    // BEGIN frame using transactions to group the sending of several messages so that
    // either none or all of them get handled by the broker.
    string begin = "BEGIN"+"\n"+"transaction:"+transactionId+"\n"+"\n"+END_OF_FRAME;
    // Combining both CONNECT and BEGIN frames.
    string command = connect+begin;
    byte[] payloadByte = command.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    var writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the connect frame", writeResult);
    }
    // Make the publisher wait until it connects to the stomp broker.
    runtime:sleep(3000);

    // SEND frame to publish the messages to queue.
    string send = "SEND"+"\n"+"destination:"+destination+"\n"+"receipt:message-001\n"+"\n"+"First Message Hello STOMP "+"\n"
        +"transaction:"+transactionId+"\n"+END_OF_FRAME+
        "SEND"+"\n"+"destination:"+destination+"\n"+"receipt:message-002\n"+"\n"+"Second Message Hello STOMP"+"\n"+
        "transaction:"+transactionId+"\n"+END_OF_FRAME;
    payloadByte = send.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the send frame ", writeResult);
    }
    // Make the publisher wait until it sends the message to the queue.
    runtime:sleep(5000);

    // DISCONNECT frame to disconnect client from stomp broker.
    string disconnect = "DISCONNECT"+"\n" + "\n" + END_OF_FRAME+"\n" ;
    payloadByte = disconnect.toByteArray("UTF-8");
    // Send desired content to the server using the write function.
    writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to write the disconnect frame ", writeResult);
    }
}

// Callback service for the stomp TCP client. The service needs to have four predefined resources.
service ClientService = service {

    // This is invoked once the client connects to the stomp broker.
    resource function onConnect(socket:Caller caller) {
        io:println("Connect to: ", caller.remotePort, "\n");
    }

    // This is invoked when the stomp broker sends any content.
    resource function onReadReady(socket:Caller caller, byte[] command) {
        io:ReadableByteChannel byteChannel = io:createReadableChannel(command);
        io:ReadableCharacterChannel characterChannel =
        new io:ReadableCharacterChannel(byteChannel, "UTF-8");
        var str = characterChannel.read(100);
        if (str is string) {
            io:println(untaint str);
        } else {
            io:println(str);
        }
    }

    // This is invoked once the connection is closed.
    resource function onClose(socket:Caller caller) {
        io:println("Disconnected from Stomp broker at: ", caller.remotePort);
    }

    // This resource is invoked for the error situation
    // if it happens during the `onConnect`, `onReadReady`, and `onClose` functions.
    resource function onError(socket:Caller caller, error err) {
        io:println(err);
    }
};
