// This is the client implementation for the TCP socket with the attached callback service. Callback service is optional.
import ballerina/runtime;
import ballerina/io;
import ballerina/socket;

string text = "HELLO STOMP";
string host = "localhost";
int port    = 61613;

public function main() {

    // Create a new socket client by providing the host, port, and callback service.
    socket:Client socketClient = new({ host: host, port: port, callbackService: ClientService });

    io:println("Starting up the Ballerina Stomp Service\n");

    // End of frame used a null octet (^@ = \u0000)
    string END_OF_FRAME = "\u0000";

    //connect frame to get connected
    //string connectCommand = "CONNECT\n" + "\n" + END_OF_FRAME +"SUBSCRIBE\n" + "destination:/queue/test\n" +"\n"+ END_OF_FRAME;

    string connectCommand = "CONNECT\n" + "accept-version:1.1\n" + "\n" + END_OF_FRAME +
        "SEND\n" + "destination:/queue/test\n" +"\n"+ text + END_OF_FRAME;

    byte[] payloadByte = connectCommand.toByteArray("UTF-8");

    //subscribe to a destination
    //string subscribe  = "/queue/test";
    //byte[] payloadByte2 = subscribe.toByteArray("UTF-8");

    //disconnect from stomp broker
    //string disconnect = "DISCONNECT\n\n\n";
    //byte[] payloadByte3 = disconnect.toByteArray("UTF-8");
    runtime:sleep(3000);

    // Send desired content to the server using the write function.
    var writeResult = socketClient->write(payloadByte);
    if (writeResult is error) {
        io:println("Unable to written the connectCommand ", writeResult);
    }

    //// Send desired content to the server using the write function.
    //var writeResult2 = socketClient->write(payloadByte2);
    //if (writeResult2 is error) {
    //    io:println("Unable to written the connectCommand ", writeResult);
    //}

}

// Callback service for the TCP client. The service needs to have four predefined resources.
service ClientService = service {

    // This is invoked once the client connects to the TCP server.
    resource function onConnect(socket:Caller caller) {
        io:println("Connect to: ", caller.remotePort, "\n");
    }

    // This is invoked when the server sends any content.
    resource function onReadReady(socket:Caller caller, byte[] connectCommand) {
        io:ReadableByteChannel byteChannel = io:createReadableChannel(connectCommand);
        io:ReadableCharacterChannel characterChannel =
        new io:ReadableCharacterChannel(byteChannel, "UTF-8");
        var str = characterChannel.read(300);
        if (str is string) {
            io:println(untaint str);
        } else {
            io:println(str);
        }

        io:println("Sent Stomp message: " + text);
        // Close the connection between the server and the client.
        //var closeResult = caller->close();
        //if (closeResult is error) {
        //    io:println(closeResult);
        //} else {
        //    io:println("Client connection closed successfully.");
        //}
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
