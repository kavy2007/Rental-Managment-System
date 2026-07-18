-- ============================================
-- 00_database.sql
-- Database Creation and Configuration
-- MySQL 8.0 Compatible
-- ============================================

CREATE DATABASE IF NOT EXISTS rental_management
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE rental_management;

SET FOREIGN_KEY_CHECKS = 1;
