import 'package:flutter/material.dart';
import "dart:convert" as convert;
import "package:http/http.dart" as http;
import "../widgets/widgets.dart" as widgets;
import "../models/models.dart" as models;

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  List<models.Product> _products = [];
  String _errorMessage = "";
  bool _fetching = false;

  Future<void> getProducts() async {
    try {
      setState(() {
        _fetching = true;
      });
      var uri = Uri.http("10.0.2.2:3000", "/api/products", {"isFood": "true"});

      var response = await http.get(uri);

      if (response.statusCode != 200) {
        throw "Service not working!";
      }
      var jsonResponse = convert.jsonDecode(response.body);

      List<models.Product> responseProducts = [];

      for (var result in jsonResponse["result"] as List) {
        models.Product resultProduct = models.Product(
            id: result["_id"],
            name: result["name"],
            brand: result["brand"],
            description: result["description"],
            isHarmful: result["isHarmful"],
            ingredients: result["ingredients"],
            harmfulnessPercentage: result["harmfulnessPercentage"],
            productType: result["productType"]);
        responseProducts.add(resultProduct);
      }

      setState(() {
        _products = responseProducts;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _fetching = false;
      });
    }
  }

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        const widgets.HeadWithImage(
          text: "Nutrition",
          url: "assets/food.png",
          imageWidth: 80,
          rightMargin: 30,
          color: Colors.black,
          topPadding: 30,
          fontSize: 34,
        ),
        const SizedBox(
          height: 15,
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              if (!_fetching)
                ..._products.map((product) =>
                    widgets.ProductView(product: product, category: "F")),
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 26, color: Colors.red),
                  ),
                ),
              if (_fetching)
                SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ]),
    );
  }
}
