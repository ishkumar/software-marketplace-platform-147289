-- MySQL schema for software marketplace

-- USERS
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(64) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    provider ENUM('local', 'google', 'github') DEFAULT 'local' NOT NULL,
    full_name VARCHAR(128),
    avatar_url VARCHAR(512),
    is_active BOOLEAN DEFAULT TRUE,
    is_publisher BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- SOFTWARE LISTINGS
CREATE TABLE listings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_id INT NOT NULL,
    title VARCHAR(128) NOT NULL,
    summary TEXT,
    application_type ENUM('saas', 'mobile', 'web', 'desktop', 'api') NOT NULL,
    is_paid BOOLEAN DEFAULT TRUE,
    price DECIMAL(10,2),
    download_url VARCHAR(512),
    external_link VARCHAR(512),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES users(id) ON DELETE CASCADE
);

-- LIKES
CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    listing_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY user_listing (user_id, listing_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

-- TRANSACTIONS (PURCHASE/SUBSCRIPTION)
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    listing_id INT NOT NULL,
    transaction_type ENUM('purchase', 'subscription') NOT NULL,
    payment_provider ENUM('manual', 'stripe', 'test') DEFAULT 'manual',
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

-- ENGAGEMENTS (user <-> publisher, e.g. message/contact request)
CREATE TABLE engagements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    recipient_id INT NOT NULL,
    listing_id INT,
    message TEXT,
    status ENUM('pending', 'accepted', 'rejected', 'resolved') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (recipient_id) REFERENCES users(id),
    FOREIGN KEY (listing_id) REFERENCES listings(id)
);

-- Indexes for efficient queries
CREATE INDEX idx_listings_publisher ON listings(publisher_id);
CREATE INDEX idx_likes_listing ON likes(listing_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_engagements_sender ON engagements(sender_id);
CREATE INDEX idx_engagements_recipient ON engagements(recipient_id);
