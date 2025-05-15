<?php
$servername = "localhost";
$dbname = "mazadco_auction";
$username_db = "root"; // or your MySQL username
$password_db = ""; // your MySQL password (empty if using default XAMPP)

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8", $username_db, $password_db);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}
?>