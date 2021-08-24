package com.example.eurekaclient;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ProducerController {

    @Autowired
    private ProductService productService;

    @RequestMapping(value = "getToken")
    public String getToken(){  //   http://localhost:7002/product/getToken
        //收到客户端发来的请求，我们现在通过FeignClient，去调用消费者那边的url接口，获得结果！
        String str =  productService.getToken();
        return str;
    }
}
