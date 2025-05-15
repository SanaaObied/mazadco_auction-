<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Enable CORS (Allow requests from any origin)

// Include database connection
include_once './db_connection.php';

try {
    // Fetch auction items
    $sql = "SELECT item_id, image_url, price, title FROM auction_items";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    // Fetch results
    $auctionItems = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($auctionItems)) {
        echo json_encode(['message' => 'No items found']);
        exit();
    }

    // Debugging: Print URLs in the console log
    foreach ($auctionItems as $item) {
        // Print the image URL in the error log (console)
        error_log("Image URL: " . $item['image_url']);
 
    }

    // Debugging: Print the auction items to check the URL (for your reference)
    echo json_encode($auctionItems, JSON_UNESCAPED_SLASHES); // Ensure no slashes are escaped in the URLs

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Failed to retrieve auction items: ' . $e->getMessage()]);
}
?>
