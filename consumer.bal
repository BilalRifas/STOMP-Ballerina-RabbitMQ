import my.stompSubscriber;
import ballerina/log;
import ballerina/io;
import ballerina/socket;
import ballerina/system;
import ballerina/transactions;

// This initializes a STOMP connection with the STOMP broker.
stompSubscriber:Receiver stompReceiver = new({
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
        string destination = "/queue/test";
        string subscribeId = system:uuid();
        string ack = "client";
        var receive = stompReceiver->subscribe(destination, subscribeId, ack);
        //if (receive is error) {
        //    io:println("Unable to send message", receive);
        //}
    }
}
