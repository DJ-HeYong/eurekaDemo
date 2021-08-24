package com.example.eurekacousumer;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
public class ConsumerController {

    @RequestMapping(value = "getTokenInConsumer")
    public String getTokenInConsumer(){
        return UUID.randomUUID().toString();
    }
}
