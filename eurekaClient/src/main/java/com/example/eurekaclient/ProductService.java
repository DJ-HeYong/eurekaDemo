package com.example.eurekaclient;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestMapping;

//name 为消费者项目中application.yml配置文件中的application.name;
//path 为消费者项目中application.yml配置文件中的context.path;
@FeignClient(name = "consumer-server",path ="/consumer" )

//@Componet注解最好加上，不加idea会显示有错误，但是不影响系统运行；
@Component
public interface ProductService {

    @RequestMapping(value = "getTokenInConsumer") //value是调用消费者那边
    String getToken();
}