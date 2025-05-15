<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Enable CORS (Allow requests from any origin)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

// Connect to the database
require_once 'db_connection.php'; // Your database connection file

// Check if the necessary data is provided
$username = isset($_POST['username']) ? $_POST['username'] : null;
$password = isset($_POST['password']) ? $_POST['password'] : null;
$name = isset($_POST['name']) ? $_POST['name'] : null;
$email = isset($_POST['email']) ? $_POST['email'] : null;
$phone = isset($_POST['phone']) ? $_POST['phone'] : null;
$address = isset($_POST['address']) ? $_POST['address'] : null;
$date = isset($_POST['date']) ? $_POST['date'] : null;
$accountType = isset($_POST['accountType']) ? $_POST['accountType'] : null;
//$status = isset($_POST['status']) ? $_POST['status'] : null;

// Check if all required fields are provided
if ($username && $password && $name && $email && $phone && $address && $date && $accountType ) {
    try {
        // Prepare the SQL query using PDO with placeholders
        $sql = "INSERT INTO users (username, password, name, email, mobile_number, address, created_at, account_type, payment_way) 
                VALUES (:username, :password, :name, :email, :phone, :address, :date, :accountType, :payment_way)";

        // Prepare the statement
        $stmt = $conn->prepare($sql);

        // Bind parameters to the placeholders
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':password', $password);  // You may want to hash the password before saving
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':phone', $phone);
        $stmt->bindParam(':address', $address);
        $stmt->bindParam(':date', $date);
        $stmt->bindParam(':accountType', $accountType);
        $stmt->bindParam(':payment_way', $status);

        // Execute the query
        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "User registered successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error while inserting user data"]);
        }
    } catch (PDOException $e) {
        echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Missing required fields"]);
}
?>


<?

try {
    // Connect to the database using PDO
    $conn = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8", $username_db, $password_db);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Fetch user from database (Ensure case-sensitive comparison)
    $query = "SELECT id FROM users WHERE BINARY email = :email LIMIT 1";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':email', $email, PDO::PARAM_STR);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {

        echo json_encode([
            'status' => 'success',
            'message' => 'Login successful',
            'id' => $user['id']
        ]);
    } else {
        echo json_encode(['status' => 'failure', 'message' => 'User not found']);
    }

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>


?>