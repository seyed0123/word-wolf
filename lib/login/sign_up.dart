import 'package:flutter/material.dart';

class Sign_up extends StatefulWidget {
  const Sign_up({Key? key}) : super(key: key);

  @override
  State<Sign_up> createState() => _Sign_upState();
}

class _Sign_upState extends State<Sign_up> {

  final username = TextEditingController();
  final password = TextEditingController();
  final rePassword = TextEditingController();
  final email = TextEditingController();
  bool _isChecked = false;
  final ScrollController _scrollController = ScrollController();



  String dropdownValue = 'English';

  final List<String> dropdownOptions = ['English', 'Persian', 'German','French','Spanish','Arabic'];

  String error = '';
  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  void sendData(){
    String err = '';
    if(username.text == '' || password.text == ''|| rePassword.text == '' || email.text == ''){
      err = 'All fields are required';
    }else if (password.text != rePassword.text) {
      err = 'password doesn\'t match';
    }else if(_isChecked == false){
      err='agree the terms';
    }
    if( err!=''){
      setState(() {
        error = err;
      });
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds:  200),
        curve: Curves.linear,
      );
      return;
    }
    print(username.text+password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Wolf')),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: <Widget>[
              Text(
                '$error',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20,
                ),
              ),
              TextField(
                controller: username,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'username',
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              TextField(
                obscureText: true,
                controller: password,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'password',
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              TextField(
                obscureText: true,
                controller: rePassword,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'enter password again',
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Row(
                children: [
                  Text('mother tongue'),
                  Icon(Icons.arrow_circle_down),
                ],
              ),
              DropdownButton<String>(
                borderRadius:BorderRadius.all(Radius.circular(5)),
                isExpanded: true,
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize:  24,
                elevation:  100,
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
              const SizedBox(
                  height: 25,
                ),
              TextField(
                controller: email,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'email',
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  Text('I agree to the terms and conditions'),
                ],
              ),
              const SizedBox(
                height: 75,
              ),
              ElevatedButton(
                onPressed: () {
                  sendData();
                },
                style: ElevatedButton.styleFrom(
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
                ),
                child: const Text('sign up'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
