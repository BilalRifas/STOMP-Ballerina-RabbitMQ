import my.stomp;
import ballerina/log;
import ballerina/io;
import ballerina/socket;
import ballerina/transactions;

// This initializes a STOMP connection with the STOMP broker.
stomp:Sender stompSender = new({
        host: "localhost",
        port: 61613,
        login: "guest",
        passcode: "guest",
        vhost: "/",
        acceptVersion: "1.1"
    });

public function main() {
    // Message is published within the transaction block.
    // Each message sent should be received from other end else rollback
    // to retry the message along with transaction Id.
    transaction {
        // This sends the Ballerina message to the stomp broker.
        string message = "Hello World From Ballerina";
        string destination = "/queue/test";
        var broadcast = stompSender->send(message,destination);
        //if (returnVal is error) {
        //    io:println("Unable to send message", returnVal);
        //}
    }
}
