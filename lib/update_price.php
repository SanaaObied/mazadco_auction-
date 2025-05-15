<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Enable CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

// Handle preflight requests for CORS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'db_connection.php'; // Ensure database connection is included

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $itemId = $_POST['item_id'] ?? '';
    $newPrice = $_POST['new_price'] ?? '';

    // Validate input
    if (empty($itemId) || empty($newPrice) || !is_numeric($newPrice)) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid data']);
        exit();
    }

    // Update price in database
    $query = "UPDATE auction_items SET price = ? WHERE item_id = ?";
    $stmt = $conn->prepare($query);

    if (!$stmt) {
        echo json_encode(['status' => 'error', 'message' => 'Database error: '  ]);
        exit();
    }

    $stmt->bindParam("di", $newPrice, $itemId);

    if ($stmt->execute()) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to update price']);
    }

    
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}
?>
