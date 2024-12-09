package com.gabriel.java_bank_app.repository;

import com.gabriel.java_bank_app.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Boolean existByEmail(String email);
}
