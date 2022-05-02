-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: May 25, 2020 at 08:24 PM
-- Server version: 10.3.22-MariaDB-0+deb10u1
-- PHP Version: 7.4.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `essentialmode`
--

-- --------------------------------------------------------

--
-- Table structure for table `gasstations`
--

CREATE TABLE `gasstations` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `account` bigint(20) DEFAULT 0,
  `fuel` bigint(20) DEFAULT 100,
  `fuelcost` int(11) DEFAULT 35,
  `buyprice` int(11) DEFAULT 30,
  `soldfuel` int(11) DEFAULT 0,
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `gasstations`
--

INSERT INTO `gasstations` (`id`, `owner`, `account`, `fuel`, `fuelcost`, `buyprice`, `soldfuel`, `x`, `y`, `z`) VALUES
(1, NULL, 0, 100, 50, 40, 0, 2539.24, 2594.4, 37.94),
(2, NULL, 0, 100, 50, 40, 0, 49.4187, 2778.79, 58.043),
(3, NULL, 0, 100, 50, 40, 0, 263.894, 2606.46, 44.983),
(4, NULL, 0, 100, 50, 40, 0, 1039.96, 2671.13, 39.55),
(5, NULL, 0, 100, 50, 40, 0, 1207.26, 2660.18, 37.899),
(6, NULL, 0, 100, 50, 40, 0, 2679.86, 3263.95, 55.24),
(7, NULL, 0, 100, 50, 40, 0, 2005.06, 3773.89, 32.403),
(8, NULL, 0, 100, 50, 40, 0, 1687.16, 4929.39, 42.078),
(9, NULL, 0, 100, 50, 40, 0, 1701.31, 6416.03, 32.763),
(10, NULL, 0, 100, 50, 40, 0, 179.857, 6602.84, 31.868),
(11, NULL, 0, 100, 50, 40, 0, -94.4619, 6419.59, 31.489),
(12, NULL, 0, 100, 50, 40, 0, -2555, 2334.4, 33.078),
(13, NULL, 0, 100, 50, 40, 0, -1800.38, 803.661, 138.651),
(14, NULL, 0, 100, 50, 40, 0, -1437.62, -276.747, 46.207),
(15, NULL, 0, 100, 50, 40, 0, -2096.24, -320.286, 13.168),
(16, NULL, 0, 100, 50, 40, 0, -724.619, -935.163, 19.213),
(17, NULL, 0, 100, 50, 40, 0, -526.019, -1211.10, 18.184),
(18, NULL, 0, 100, 50, 40, 0, -70.2148, -1761.79, 29.534),
(19, NULL, 0, 100, 50, 40, 0, 265.648, -1261.31, 29.292),
(20, NULL, 0, 100, 50, 40, 0, 819.653, -1028.85, 26.403),
(21, NULL, 0, 100, 50, 40, 0, 1208.95, -1402.57, 35.224),
(22, NULL, 0, 100, 50, 40, 0, 1181.38, -330.847, 69.316),
(23, NULL, 0, 100, 50, 40, 0, 620.843, 269.1, 103.089),
(24, NULL, 0, 100, 50, 40, 0, 2581.32, 362.039, 108.468),
(25, NULL, 0, 100, 50, 40, 0, 176.631, -1562.03, 29.263),
(26, NULL, 0, 100, 50, 40, 0, 176.631, -1562.03, 29.263),
(27, NULL, 0, 100, 50, 40, 0, -319.292, -1471.71, 30.549),
(28, NULL, 0, 100, 50, 40, 0, 1784.32, 3330.55, 41.253);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `gasstations`
--
ALTER TABLE `gasstations`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `gasstations`
--
ALTER TABLE `gasstations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
