<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Configurações do banco de dados
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "flutter";

// Conexão com o banco de dados
$conn = new mysqli($servername, $username, $password, $dbname);

// Verifica se ocorreu algum erro na conexão
if ($conn->connect_error) {
    die("Conexão falhou: " . $conn->connect_error);
}

// Rotas da API
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    // Obter todos os produtos
    $sql = "SELECT * FROM products";
    $result = $conn->query($sql);
    $products = array();

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }
    }

    echo json_encode($products);
} elseif ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Adicionar um novo produto
    $data = json_decode(file_get_contents("php://input"), true);

    $name = $data["name"];
    $price = $data["price"];

    $sql = "INSERT INTO products (name, price) VALUES ('$name', $price)";
    $conn->query($sql);
    echo json_encode(array("message" => "Produto adicionado com sucesso."));
} elseif ($_SERVER["REQUEST_METHOD"] === "PUT") {
    // Atualizar um produto existente
    $data = json_decode(file_get_contents("php://input"), true);

    $id = $data["id"];
    $name = $data["name"];
    $price = $data["price"];

    $sql = "UPDATE products SET name='$name', price=$price WHERE id=$id";
    $conn->query($sql);
    echo json_encode(array("message" => "Produto atualizado com sucesso."));
} elseif ($_SERVER["REQUEST_METHOD"] === "DELETE") {
    // Excluir um produto
    $id = $_GET["id"];
    $sql = "DELETE FROM products WHERE id=$id";
    $conn->query($sql);
    echo json_encode(array("message" => "Produto excluído com sucesso."));
}

$conn->close();
?>
