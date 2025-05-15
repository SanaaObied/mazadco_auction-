<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Start the session to store user data
session_start();

// Enable CORS (Allow requests from any origin)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

// Connect to the database
require_once 'db_connection.php';

// Validate request data
if (!isset($_POST['username']) || !isset($_POST['password'])) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request']);
    exit;
}

// Get username & password from POST request
$username = trim($_POST['username']);
$password = trim($_POST['password']);

try {
    // Connect to the database using PDO
    $conn = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8", $username_db, $password_db);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Fetch user from database (Ensure case-sensitive comparison)
    $query = "SELECT * FROM users WHERE BINARY username = :username LIMIT 1";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':username', $username, PDO::PARAM_STR);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        // Compare passwords directly (since passwords are stored as plain text)
        if ($password === $user['password']) {
            // Store the user ID in the session
            $_SESSION['user_id'] = $user['id'];
            $ip_address = $_SERVER['REMOTE_ADDR'];

            // Return the user ID along with the success message
            echo json_encode([
                'status' => 'success',
                'message' => 'Login successful',
                'id' => (int) $user['id'],  // Ensure 'id' is an integer
            ]);
            
        } else {
            echo json_encode(['status' => 'failure', 'message' => 'Invalid password']);
        }
    } else {
        echo json_encode(['status' => 'failure', 'message' => 'User not found']);
    }

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
