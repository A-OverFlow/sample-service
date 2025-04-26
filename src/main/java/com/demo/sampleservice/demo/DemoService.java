package com.demo.sampleservice.demo;

import org.springframework.stereotype.Service;
import java.time.LocalDateTime;

@Service
public class DemoService {

    private final DemoRepository demoRepository;

    public DemoService(DemoRepository demoRepository) {
        this.demoRepository = demoRepository;
    }

    /**
     * 현재 시간을 저장하고 반환합니다.
     */
    public LocalDateTime getAndLogCurrentTime() {
        LocalDateTime now = LocalDateTime.now();
        demoRepository.save(new DemoEntity(now));
        return now;
    }
}
