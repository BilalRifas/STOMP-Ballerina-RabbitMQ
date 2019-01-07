# STOMP-Ballerina-RabbitMQ
STOMP ballerina client using RabbitMQ broker.

![alt text](https://github.com/BilalRifas/STOMP-Ballerina-RabbitMQ/blob/master/STOMP%20UseCase%20(Class%20Diagram).png)

STOMP UseCase (Class Diagram).png

![alt text](https://cdn-images-1.medium.com/max/800/1*6-dgobKL8tTQCXBsBPadqw.png)

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
