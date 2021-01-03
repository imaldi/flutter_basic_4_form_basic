import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_basic_4/main.dart';

class MyFormFieldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validating Dropdown',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Validating Dropdown',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> _dropdownValues = <String>['', 'red','green','blue','orange'];
  String _name;
  String _chosenValue;
  
  void showMessage(String message, [MaterialColor color = Colors.red]){
    _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: color,content:Text(message)));
  }

  void _submitForm(){
    final FormState form = _formKey.currentState;

    if(!form.validate()){
      showMessage('Form is not valid! Please review and correct.');
    } else {
      form.save();

      print('========================================');
      print('Form Saved: ');
      print('Name: $_name');
      print('Color: $_chosenValue');
      print('========================================');
      print('');

      showMessage("Name : $_name\nColor: $_chosenValue",Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidate: false,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: 'Enter your name',
                  labelText: 'Name'
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                validator: (val) => val.isEmpty ? 'A name is required' : null,
                onSaved: (val) => setState((){ _chosenValue = val; }),
              ),
              Container(
                padding: EdgeInsets.all(40),
                child: RaisedButton(
                  child: Text('Submit'),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

