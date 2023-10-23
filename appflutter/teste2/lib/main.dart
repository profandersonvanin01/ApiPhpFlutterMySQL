import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Crud de Produtos',
      initialRoute: '/',
      routes: {
        '/': (context) => const ProductListScreen(),
        '/add': (context) => const AddProductScreen(),
      },
    );
  }
}

class Product {
  final String id;
  final String name;
  final String price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];

  Future<void> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.20.152/apiflutter/api.php'));

    if (response.statusCode == 200) {
      setState(() {
        Iterable list = json.decode(response.body);
        products = list.map((model) => Product.fromJson(model)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> deleteProduct(String id) async {
    final response = await http
        .delete(Uri.parse('http://192.168.20.152/apiflutter/api.php?id=$id'));

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Produto apagado com successo");
      fetchProducts();
    } else {
      Fluttertoast.showToast(msg: "Falha ao apagar p produto");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste CRUD Produtos'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('Preço: \$${product.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteProduct(product.id);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProductScreen(product: product),
                ),
              ).then((value) {
                if (value == true) {
                  fetchProducts();
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add').then((value) {
            if (value == true) {
              fetchProducts();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Future<void> addProduct() async {
    final String name = nameController.text;
    final double price = double.parse(priceController.text);

    final response = await http.post(
      Uri.parse('http://192.168.20.152/apiflutter/api.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': name, 'price': price}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Produto adicionado com successo");
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Falha ao adicionar o produto");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Produto'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Preço'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addProduct();
              },
              child: const Text('Adicionar Produto'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateProductScreen extends StatefulWidget {
  final Product product;

  // ignore: prefer_const_constructors_in_immutables
  UpdateProductScreen({super.key, required this.product});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.product.name;
    priceController.text = widget.product.price.toString();
  }

  Future<void> updateProduct() async {
    final String name = nameController.text;
    final double price = double.parse(priceController.text);

    final response = await http.put(
      Uri.parse('http://192.168.20.152/apiflutter/api.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'id': widget.product.id, 'name': name, 'price': price}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Produto atualizado com successo");
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: "Falha ao atualizar o produto");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Produto'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Preço'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateProduct();
              },
              child: const Text('Atualizar Produto'),
            ),
          ],
        ),
      ),
    );
  }
}
