package com.demo.sampleservice.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@RestController
public class DemoController {

    private final DemoService demoService;

    public DemoController(DemoService demoService) {
        this.demoService = demoService;
    }

    /**
     * GET /demo
     * 현재 시간을 반환하고 DB에 저장합니다.
     */
    @GetMapping("/demo")
    public LocalDateTime handleDemoRequest() {
        return demoService.getAndLogCurrentTime();
    }
}
