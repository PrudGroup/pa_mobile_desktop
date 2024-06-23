import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final String productId;
  final String? affLinkId;
  const ProductDetails({
    super.key,
    required this.productId,
    this.affLinkId
  });

  @override
  ProductDetailsState createState() => ProductDetailsState();
}

class ProductDetailsState extends State<ProductDetails> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
