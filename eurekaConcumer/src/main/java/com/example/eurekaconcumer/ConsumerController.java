package com.example.eurekaconcumer;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
public class ConsumerController {

    @RequestMapping(value = "getTokenInConsumer")
    public String getTokenInConsumer(){
        System.out.println("000");
        return UUID.randomUUID().toString();
    }
}
