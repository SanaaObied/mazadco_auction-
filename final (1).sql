-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 14, 2025 at 09:26 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `final`
--

-- --------------------------------------------------------

--
-- Table structure for table `auction_items`
--

CREATE TABLE `auction_items` (
  `item_id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `image_url` varchar(300) DEFAULT NULL,
  `status` enum('open','closed') DEFAULT 'open',
  `winning_bid` decimal(10,2) DEFAULT NULL,
  `winner_id` int(11) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `location` varchar(200) NOT NULL,
  `saller_name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `auction_items`
--

INSERT INTO `auction_items` (`item_id`, `category_id`, `title`, `description`, `price`, `image_url`, `status`, `winning_bid`, `winner_id`, `start_time`, `end_time`, `location`, `saller_name`) VALUES
(1, 1, 'Laptop', 'High-performance laptop with 16GB RAM', 500.00, 'images/laptop.jpg', 'open', 0.00, 0, '2025-04-01 09:00:00', '2025-04-07 18:00:00', 'Ramallah', 'jhone'),
(2, 1, 'Phone', 'Latest model smartphone with great features', 3.00, 'images/phone.jpg', 'open', 3.00, 1, '2025-04-01 10:00:00', '2025-04-05 15:00:00', 'nablus', 'user1_m'),
(3, 1, 'Watch', 'Stylish wristwatch with leather strap', 150.00, 'images/watch.jpg', 'open', 0.00, 0, '2025-04-02 08:00:00', '2025-04-09 19:00:00', 'Ramallah', 'lila'),
(4, 10, 'Camera', 'Digital camera with 20x zoom', 300.00, 'images/camera.jpg', 'open', 3.00, 11, '2025-04-03 11:00:00', '2025-04-10 17:00:00', 'Ramallah', 'salawi'),
(5, 2, 'Headphones', 'Noise-cancelling headphones', 220.00, 'images/headphones.jpg', 'open', 11.00, 11, '2025-04-04 09:00:00', '2025-04-06 14:00:00', 'yafa', 'salawi'),
(6, 6, 'Table', 'Wooden dining table for 6 people', 250.00, 'images/table.jpg', 'open', 0.00, 0, '2025-04-01 12:00:00', '2025-04-08 13:00:00', 'aka', 'teama'),
(7, 5, 'Bicycle', 'Mountain bike with 21 gears', 200.00, 'images/bicycle.jpg', 'open', 0.00, 0, '2025-04-05 10:00:00', '2025-04-12 16:00:00', 'Ramallah', 'lona'),
(8, 7, 'Fan', 'Electric fan with 3 speed settings', 40.00, 'images/fan.jpg', 'open', 1.00, 3, '2025-04-02 14:00:00', '2025-04-04 18:00:00', 'Ramallah', 'user3_l'),
(9, 4, 'Microwave', 'Microwave oven with multiple settings', 80.00, 'images/microwave.jpg', 'open', 0.00, 0, '2025-04-03 13:00:00', '2025-04-07 12:00:00', 'Ramallah', 'leen'),
(10, 4, 'Fridge', 'Energy-efficient fridge with freezer', 640.00, 'images/fridge.jpg', 'open', 2.00, 11, '2025-04-06 10:00:00', '2025-04-13 17:00:00', 'Ramallah', 'salawi');

-- --------------------------------------------------------

--
-- Table structure for table `bids`
--

CREATE TABLE `bids` (
  `bid_id` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `bid_amount` decimal(10,2) DEFAULT NULL,
  `bid_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bids`
--

INSERT INTO `bids` (`bid_id`, `item_id`, `user_id`, `bid_amount`, `bid_time`) VALUES
(11, 1, 1, 510.00, '2025-04-01 10:00:00'),
(12, 1, 2, 520.00, '2025-04-02 11:00:00'),
(13, 1, 3, 550.00, '2025-04-03 12:00:00'),
(14, 2, 1, 320.00, '2025-04-01 11:00:00'),
(15, 2, 4, 330.00, '2025-04-02 14:00:00'),
(16, 3, 2, 160.00, '2025-04-02 10:00:00'),
(17, 3, 5, 170.00, '2025-04-03 12:00:00'),
(18, 4, 1, 420.00, '2025-04-02 15:00:00'),
(19, 4, 6, 430.00, '2025-04-03 13:00:00'),
(20, 5, 4, 120.00, '2025-04-03 16:00:00'),
(21, 2, 1, 1.00, '2025-05-11 04:46:35'),
(22, 2, 1, 2.00, '2025-05-11 04:49:19'),
(23, 2, 1, 3.00, '2025-05-11 04:50:59'),
(24, 4, 11, 1.00, '2025-05-11 05:48:51'),
(25, 4, 11, 2.00, '2025-05-11 06:00:00'),
(26, 4, 11, 3.00, '2025-05-11 06:18:48'),
(27, 5, 11, 1.00, '2025-05-11 07:10:52'),
(28, 5, 11, 2.00, '2025-05-11 07:24:36'),
(29, 5, 11, 3.00, '2025-05-11 07:24:50'),
(30, 5, 11, 4.00, '2025-05-12 05:56:12'),
(31, 5, 11, 5.00, '2025-05-12 05:56:23'),
(32, 5, 11, 6.00, '2025-05-12 05:57:07'),
(33, 5, 1, 7.00, '2025-05-12 05:57:57'),
(34, 5, 1, 8.00, '2025-05-12 05:58:15'),
(35, 5, 1, 9.00, '2025-05-12 05:58:24'),
(36, 5, 11, 10.00, '2025-05-13 17:55:34'),
(37, 5, 11, 11.00, '2025-05-13 17:56:21'),
(38, 8, 3, 1.00, '2025-05-13 17:58:55'),
(39, 10, 11, 1.00, '2025-05-13 18:04:49'),
(40, 10, 11, 2.00, '2025-05-13 18:04:55');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`) VALUES
(8, 'Books'),
(1, 'Electronics'),
(5, 'Fashion'),
(2, 'Furniture'),
(4, 'Home Appliances'),
(9, 'Jewelry'),
(10, 'Musical Instruments'),
(6, 'Sports Equipment'),
(7, 'Toys'),
(3, 'Vehicles');

-- --------------------------------------------------------

--
-- Table structure for table `favorite`
--

CREATE TABLE `favorite` (
  `favorite_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `favorite`
--

INSERT INTO `favorite` (`favorite_id`, `user_id`, `item_id`) VALUES
(16, 1, 2),
(17, 11, 7),
(18, 1, 1),
(19, 2, 5),
(20, 1, 4),
(21, 1, 3);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `item_id` int(11) DEFAULT NULL,
  `bidder_id` int(11) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `payment_status` enum('pending','completed') DEFAULT 'pending',
  `payment_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `item_id`, `bidder_id`, `amount`, `payment_status`, `payment_time`) VALUES
(1, 1, 3, 550.00, 'completed', '2025-04-04 10:00:00'),
(2, 2, 4, 330.00, 'completed', '2025-04-05 14:00:00'),
(3, 3, 5, 170.00, 'completed', '2025-04-06 15:00:00'),
(4, 4, 6, 430.00, 'pending', '2025-04-07 12:00:00'),
(5, 5, 4, 120.00, 'completed', '2025-04-06 17:00:00'),
(6, 6, 2, 250.00, 'completed', '2025-04-07 13:00:00'),
(7, 7, 3, 210.00, 'pending', '2025-04-08 14:00:00'),
(8, 8, 5, 90.00, 'pending', '2025-04-09 11:00:00'),
(9, 9, 1, 80.00, 'completed', '2025-04-10 09:00:00'),
(10, 10, 2, 620.00, 'pending', '2025-04-11 10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `payment_way` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `mobile_number` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `address` text DEFAULT NULL,
  `account_type` varchar(50) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `bids_count` int(11) DEFAULT 0,
  `win_ratio` float DEFAULT 0,
  `bid_cancellations` int(11) DEFAULT 0,
  `transaction_count` int(11) DEFAULT 0,
  `total_transaction_value` decimal(15,2) DEFAULT 0.00,
  `successful_payments` int(11) DEFAULT 0,
  `delivery_success_rate` float DEFAULT 0,
  `delivery_complaints` int(11) DEFAULT 0,
  `delivery_cancellations` int(11) DEFAULT 0,
  `fraud_reports` int(11) DEFAULT 0,
  `total_payments` int(11) DEFAULT 0,
  `average_payment_delay_days` float DEFAULT 0,
  `payment_methods_used` text DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `payment_way`, `password`, `email`, `mobile_number`, `created_at`, `updated_at`, `address`, `account_type`, `image`, `bids_count`, `win_ratio`, `bid_cancellations`, `transaction_count`, `total_transaction_value`, `successful_payments`, `delivery_success_rate`, `delivery_complaints`, `delivery_cancellations`, `fraud_reports`, `total_payments`, `average_payment_delay_days`, `payment_methods_used`, `name`, `status`) VALUES
(1, 'user1_m', 'Credit Card', 'user1', 'user1@example.com', '1234567890', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 1', 'customer', 'img1.png', 50, 0.6, 2, 30, 5000.00, 28, 0.9, 1, 0, 0, 30, 1.5, 'Visa, PayPal', '', 'Medium'),
(2, 'user2_h', 'PayPal', 'user2', NULL, ' ', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 2', 'customer', 'img2.png', 10, 0.2, 10, 15, 20.00, 1, 0.2, 0, 6, 20, 15, 8, 'PayPal', '', NULL),
(3, 'user3_l', 'Bank Transfer', 'user3', 'user3@example.com', '1234567892', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 3', 'customer', 'img3.png', 100, 0.8, 0, 60, 10000.00, 58, 0.95, 0, 0, 0, 60, 0.5, 'Bank Transfer', '', 'High'),
(4, 'user4', 'Credit Card', 'user4', 'user4@example.com', '1234567893', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 4', 'customer', 'img4.png', 30, 0.5, 3, 25, 4000.00, 20, 0.75, 3, 2, 1, 25, 3, 'Visa', '', 'Medium'),
(5, 'user5', 'PayPal', 'pass5', 'user5@example.com', '1234567894', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 5', 'customer', 'img5.png', 80, 0.9, 1, 70, 15000.00, 68, 0.98, 0, 0, 0, 70, 0.2, 'PayPal, Visa', '', 'High'),
(6, 'user6', 'Crypto', 'pass6', 'user6@example.com', '1234567895', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 6', 'customer', 'img6.png', 5, 0.2, 0, 10, 2000.00, 9, 0.7, 2, 1, 2, 10, 4.5, 'Bitcoin', '', 'Medium'),
(7, 'user7', 'Bank Transfer', 'pass7', 'user7@example.com', '1234567896', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 7', 'customer', 'img7.png', 60, 0.4, 5, 40, 6000.00, 35, 0.8, 4, 2, 1, 40, 2.8, 'Bank Transfer, PayPal', '', 'Medium'),
(8, 'user8', 'Credit Card', 'pass8', 'user8@example.com', '1234567897', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 8', 'customer', 'img8.png', 20, 0.5, 0, 18, 3500.00, 17, 0.9, 1, 0, 0, 18, 1.2, 'Mastercard', '', 'Medium'),
(9, 'user9', 'PayPal', 'pass9', 'user9@example.com', '1234567898', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 9', 'customer', 'img9.png', 90, 0.85, 0, 80, 12000.00, 80, 1, 0, 0, 0, 80, 0, 'PayPal', '', 'High'),
(10, 'user10', 'Credit Card', 'user10', 'user10@example.com', '1234567899', '2025-05-03 16:33:46', '2025-05-03 16:33:46', 'Address 10', 'customer', 'img10.png', 15, 0.2, 4, 10, 2500.00, 6, 0.6, 3, 2, 3, 10, 5, 'Visa, Amex', '', 'Medium'),
(11, 'salawi', 'Cash on delivery', 'salawi', 'safalawi@hotmail.com', '8765434567', '2025-05-03 00:00:00', NULL, 'rammallah', 'customer', NULL, 0, 0, 0, 0, 0.00, 0, 0, 0, 0, 0, 0, 0, NULL, 'salawi', 'Low'),
(12, 'sanaa', 'Apple Pay', 'sana123sana', 'sana@gmail', '0592845458', '2025-05-04 00:00:00', NULL, 'ramaa', 'customer', NULL, 0, 0, 0, 0, 0.00, 0, 0, 0, 0, 0, 0, 0, NULL, 'sanaa', 'Low'),
(13, 'admin', 'None', 'admin123', 'admin@example.com', '0000000000', '2025-05-09 06:13:31', '2025-05-09 06:13:31', 'Admin Address', 'admin', 'admin.png', 0, 0, 0, 0, 0.00, 0, 0, 0, 0, 0, 0, 0, 'None', 'Admin Name', 'active');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `auction_items`
--
ALTER TABLE `auction_items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `fk_category` (`category_id`);

--
-- Indexes for table `bids`
--
ALTER TABLE `bids`
  ADD PRIMARY KEY (`bid_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `category_name` (`category_name`);

--
-- Indexes for table `favorite`
--
ALTER TABLE `favorite`
  ADD PRIMARY KEY (`favorite_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `auction_items`
--
ALTER TABLE `auction_items`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `bids`
--
ALTER TABLE `bids`
  MODIFY `bid_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `favorite`
--
ALTER TABLE `favorite`
  MODIFY `favorite_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `auction_items`
--
ALTER TABLE `auction_items`
  ADD CONSTRAINT `fk_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE CASCADE;

--
-- Constraints for table `bids`
--
ALTER TABLE `bids`
  ADD CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `auction_items` (`item_id`);

--
-- Constraints for table `favorite`
--
ALTER TABLE `favorite`
  ADD CONSTRAINT `favorite_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `favorite_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `auction_items` (`item_id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `auction_items` (`item_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
