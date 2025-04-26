package com.demo.sampleservice.demo;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "demo_log")
public class DemoEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "logged_at", nullable = false)
    private LocalDateTime loggedAt;

    protected DemoEntity() {
    }

    public DemoEntity(LocalDateTime loggedAt) {
        this.loggedAt = loggedAt;
    }

    public Long getId() {
        return id;
    }

    public LocalDateTime getLoggedAt() {
        return loggedAt;
    }
}
