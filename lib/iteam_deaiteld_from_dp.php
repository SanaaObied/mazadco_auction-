<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
  header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Your existing PHP code below...

header("Access-Control-Allow-Origin: *");
 
require_once 'db_connection.php'; 

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $item_id = $_POST['item_id'] ?? 0;

    if ($item_id == 0) {
        echo json_encode(['error' => 'Invalid item ID']);
        exit();
    }

    $query = "SELECT item_id, title, description, price, image_url, status, start_time, end_time, location, saller_name 
              FROM auction_items 
              WHERE item_id = :item_id";
    
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':item_id', $item_id, PDO::PARAM_INT);
    $stmt->execute();

    $item = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($item) {
        echo json_encode($item);
    } else {
        echo json_encode(['error' => 'Item not found']);
    }
} else {
    echo json_encode(['error' => 'Invalid request method']);
}
?>
