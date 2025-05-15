<?php
header("Content-Type: application/json");
include 'db.php.inc.php';

try {
    $pdo = db_connect();
    $stmt = $pdo->query("SELECT image, name AS title, user AS subtitle, price AS priceNow FROM items");
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($items, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
