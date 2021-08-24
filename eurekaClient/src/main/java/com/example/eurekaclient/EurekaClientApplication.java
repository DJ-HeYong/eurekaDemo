package com.example.eurekaclient;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
//@EnableEurekaClient 和 @EnableDiscoveryClient 都是让eureka发现该服务并注册到eureka上的注解
//相同点：都能让注册中心Eureka发现，并将该服务注册到注册中心上；
//不同点：@EnableEurekaClient只适用于Eureka作为注册中心，而@EnableDiscoveryClient可以是其他注册中心；
@EnableEurekaClient
//表示开启Fegin客户端
@EnableFeignClients
public class EurekaClientApplication {

    //生产者，可以把生产者想象成一个客户端，发送消息到EurekaServer，然后消费者将消息消费后，返回结果给生产者！！！
    public static void main(String[] args) {
        SpringApplication.run(EurekaClientApplication.class, args);
    }

}
