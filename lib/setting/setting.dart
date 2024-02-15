import 'package:flutter/material.dart';
import 'package:word_wolf/home/User.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late User user;
  late TextEditingController username = TextEditingController();
  late TextEditingController email = TextEditingController();
  late TextEditingController oldPass = TextEditingController();
  late TextEditingController newPass = TextEditingController();

  String dropdownValue = 'English';

  final List<String> dropdownOptions = ['English', 'Persian', 'German','French','Spanish','Arabic'];

  getUser(){
    user = User('1','seyed','123','seyed123ali123','Persian',200,8,100,true,2,'pro');

    username.text = user.username;
    email.text = user.email;
    dropdownValue = user.motherTongue;
  }

  void submitChanges(){

  }

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    newPass.dispose();
    oldPass.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    primary: Colors.blue, // Background color
    onPrimary: Colors.white, // Text color
    elevation: 5, // Shadow depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // Rounded corners
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Button padding
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold, // Bold text
      fontSize: 16, // Text size
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Word Wolf'),
            ElevatedButton(onPressed: (){submitChanges();}, style:buttonStyle , child: Text('Sumbit Changes')),
          ],
        ),
      ),
      body: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          padding: EdgeInsets.all(10),
          childAspectRatio: 2,
        children: [
            Center(
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: username,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(fontSize:  18.0, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                ),
                labelText: 'username',
                labelStyle: const TextStyle(color: Colors.blueAccent),
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: email,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(fontSize:  18.0, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                  ),
                  labelText: 'username',
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: newPass,
                obscureText: true,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(fontSize:  18.0, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                  ),
                  labelText: 'new pass',
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.password_outlined, color: Colors.blueAccent),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: oldPass,
                obscureText: true,
                cursorColor: Colors.blueAccent,
                style: const TextStyle(fontSize:  18.0, color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
                  ),
                  labelText: 'old pass',
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.password_outlined, color: Colors.blueAccent),
                ),
              ),
            ),
          ),
          DropdownButton<String>(
            borderRadius:BorderRadius.all(Radius.circular(5)),
            isExpanded: true,
            isDense: true,
            hint: Text('mother tongue'),
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            iconSize:  24,
            style: const TextStyle(color: Colors.black),
            underline: Container(
              height:  1,
              color: Colors.black45,
            ),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: dropdownOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius:  10, // Adjust the radius as needed
                      backgroundImage: AssetImage('assets/flag_of_$value.png'), // Replace with your asset path
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
          ),
        ]
      ),
    );
  }
}

//
// Center(
// child: Padding(
// padding: const EdgeInsets.all(8.0),
// child: TextField(
// controller: username,
// cursorColor: Colors.blueAccent,
// style: const TextStyle(fontSize:  18.0, color: Colors.black),
// decoration: InputDecoration(
// filled: true,
// fillColor: Colors.white,
// enabledBorder: OutlineInputBorder(
// borderRadius: BorderRadius.circular(30.0),
// borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
// ),
// focusedBorder: OutlineInputBorder(
// borderRadius: BorderRadius.circular(30.0),
// borderSide: const BorderSide(color: Colors.blueAccent, width:  2.0),
// ),
// labelText: 'username',
// labelStyle: const TextStyle(color: Colors.blueAccent),
// hintStyle: const TextStyle(color: Colors.grey),
// prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
// ),
// ),
// ),
// ),