import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Word Wolf'),
            FilledButton(onPressed: (){Navigator.pushNamed(context, '/login');}, child: Text("login"))
          ],
        ),
      ),
      body:Column(
        children: [
          FilledButton(onPressed: (){Navigator.pushNamed(context, '/new_word');}, child: Text("new word"))
        ],
      )
    );
  }
}
