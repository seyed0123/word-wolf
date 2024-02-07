import 'package:flutter/material.dart';

class new_word extends StatefulWidget {
  const new_word({Key? key}) : super(key: key);

  @override
  State<new_word> createState() => _new_wordState();
}

class _new_wordState extends State<new_word> {

  final word = TextEditingController();

  String dropdownValue = 'English';

  final List<String> dropdownOptions = ['English', 'Persian', 'German','French','Spanish','Arabic'];

  String error = '';
  bool ok = false;
  @override
  void dispose() {
    word.dispose();
    super.dispose();
  }
  void sendData(BuildContext context){
    String err = '';
    if(word.text == ''){
      err = 'All fields are required';
    }
    if( err!=''){
      setState(() {
        error = err;
      });
      return;
    }
    showAlertDialog(context,word.text,'Hey');
    // if (ok==true) {
    //   Navigator.pop(context);
    // }
  }


  void verify(bool flag){
    ok=flag;
  }


  void showAlertDialog(BuildContext context,String word,String meaning) {

    Widget okButton = TextButton(
      child: const Text(
          "Yes",
      ),
      onPressed: () {
        verify(true);
        Navigator.of(context).pop();
      },
    );
    Widget noButton = TextButton(
      child: Text("No"),
      onPressed: () {
        verify(false);
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Do you confirm the word meaning?"),
      content: Text(
          '$word: $meaning',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        noButton,
        okButton,
      ],
    );

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Wolf'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            children: [
              const Text(
                'Add new word',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),),
              Text(
                '$error',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20,
                ),
              ),
              TextField(
                controller: word,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'word',
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Row(
                children: [
                  Text('This word belongs to which language?'),
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
                height: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  sendData(context);
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
                child: const Text('Add word'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}