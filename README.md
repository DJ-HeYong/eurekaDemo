# eurekaDemo
一个实现eureka的demo <br>
1、eurekaServer：服务注册中心 <br>
2、eurekaClient：生产者  <br>
3、eurekaCousumer:消费者 <br>

<br>

当我们生产者生产消息时：@FeignClient(name = "consumer-server",path ="/consumer" )  <br>
&emsp;&emsp;   @FeignClient中的 name：为消费者的application.name     <br>
&emsp;&emsp;   @当我们有多个消费者的application.name都一致时，默认情况下，eureka会依次让消费者来消费信息。  <br>
&emsp;&emsp;   @值得一提的是，name一样时，但是消费者项目中各自的application.yml 里面的 context-path 不一致时，会导致context-path不等于@FeignClient中的 path 情况下，发生调用错误。  <br>

<br>
<br>  

举例： <br>
有消费者A和消费者B的application.name都是 "consumer-server" <br>
生产者生产消息时，  @FeignClient中的 name 为  "consumer-server" <br>
那么eureka会默认先让其中一个消费者来消费，下次生产者再次调起的话，eureka会让另外一个消费者来消费。不会存在消费者A、B一起消费同一个消息。


