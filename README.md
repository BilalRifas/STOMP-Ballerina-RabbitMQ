# STOMP-Ballerina-RabbitMQ
STOMP ballerina client using RabbitMQ broker.

![alt text](https://github.com/BilalRifas/STOMP-Ballerina-RabbitMQ/blob/master/STOMP%20Diagram.png)

![alt text](https://cdn-images-1.medium.com/max/800/1*6-dgobKL8tTQCXBsBPadqw.png)

# How to do it
Setting up the environment

1. First, go to Ballerinalang website and download the latest Ballerina distribution.
Note: This scenario is tested on Ballerina 0.990.2 release

2. Download & install RabbitMQ broker by the instructions given here:

https://www.rabbitmq.com/download.html

3. Configure the RabbitMQ Broker’s STOMP plugin in-order to enable STOMP related message transactions.

https://www.rabbitmq.com/stomp.html

Also video tutorial on how to enable STOMP plugin for RabbitMQ: https://www.youtube.com/watch?v=LEjOmn8dfDg

4. Start the RabbitMQ broker using terminal command(linux):

// To start the broker
invoke-rc.d rabbitmq-server start
// To get the status of the broker
invoke-rc.d rabbitmq-server status
// To stop the broker
invoke-rc.d rabbitmq-server stop

 # CONNECT FRAME
  string connect = "CONNECT\n" + 
                   "passcode:guest\n" +  
                   "accept-version:1.1\n" + 
                   "login:guest\n" + 
                   "host:/\n" + 
                   "\n" + 
                   END_OF_FRAME;
                          
 # SEND FRAME
 string send = "SEND\n" + 
               "destination:/queue/test\n" + 
               "receipt:message-12345\n" + 
               "\n" + 
               text + 
               END_OF_FRAME;
