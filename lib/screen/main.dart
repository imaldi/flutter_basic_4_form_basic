import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_basic_4/model/contact.dart';
import 'package:flutter_basic_4/service/contact_service.dart';
import 'package:intl/intl.dart';
import '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validasi Dropdown Menu',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Validasi Dropdown Menu'),
      debugShowCheckedModeBanner: false,
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

  List<String> _colors = <String>['','red','green','blue','orange'];
  String _color = '';
  Contact newContact= new Contact();
  final TextEditingController _controller = new TextEditingController();
  final Map<String, MaterialColor> _dropdownValues = {
    ''        : null,
    "red"     : Colors.red,
    "green"   : Colors.green,
    "blue"    : Colors.blue,
    'orange'  : Colors.orange};

  String _name;
  String _chosenValue = '';

  Future<Null> _chooseDate(
      BuildContext context, String initialDateString
      ) async{
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now) ?
    initialDate : now);
    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());
    
    if(result == null) return;
    
    setState(() {
      _controller.text = new DateFormat.yMd().format(result);
    });
  }

  bool isValidDob(String dob) {
    if(dob.isEmpty)return true;
    var d = convertToDate(dob);
    return d != null && d.isBefore(new DateTime.now());
  }

  DateTime convertToDate(String input){
    try{
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    }catch (e){
      return null;
    }
  }

  bool isValidPhoneNumber(String input){
    final RegExp regex = new RegExp(r'^\(\d\d\d\)\d\d\d\-\d\d\d\d$');
    return regex.hasMatch(input);
  }

  bool isValidEmail(String input){
    final RegExp regex = new RegExp(
      r'/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/'
      // r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-] {0,253} [a-zA-Z0-9]) ? (?:\.[a-zA-Z0-9] (?:[a-zA-Z0-9-]{0,253} [a-zA-Z0-9]) ?) *$"
    );
    return regex.hasMatch(input);
  }
  void showMessage(String message, [MaterialColor color = Colors.red]){
    _scaffoldKey.currentState.showSnackBar( new SnackBar(backgroundColor: color,content: new Text(message),));
  }

  void _submitForm(){
    final FormState form = _formKey.currentState;

    // print('==========================================');

    if(!form.validate()){
      // print('Form Not Valid');
      showMessage('Form is not valid! Please review and correct.');
    } else {
      form.save();
      // String message = 'Form Valid: Name: $_name; Color: $_chosenValue';
      // showMessage(message,_dropdownValues[_chosenValue]);
      print('Form save called, newContact is now up to date...');
      print('Email: ${newContact.name}');
      print('Dob: ${newContact.dob}');
      print('Phone: ${newContact.phone}');
      print('Email: ${newContact.email}');
      print('Favorite Color: ${newContact.favoriteColor}');
      print('===========================================');
      print('Submitting to back end...');
      var contactService = new ContactService();
      contactService.createContact(newContact).then((value) =>
      showMessage('New contact created for ${value.name}!',Colors.blue));
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
                  hintText: 'Enter your first and last name',
                  labelText: 'Name',
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                validator: (val) => val.isEmpty ? 'A name is required' : null,
                onSaved: (val) => _name = val,
                // (val == null || val.isEmpty) ? 'Please choose a color' : null,
              ),
              new Row(children: [
                new Expanded(child: new TextFormField(
                  decoration: new InputDecoration(
                    icon: const Icon(Icons.calendar_today),
                    hintText: 'Enter your date of birth',
                    labelText: 'Dob',
                  ),
                    controller: _controller,
                    keyboardType: TextInputType.datetime,
                    validator: (val) =>
                    isValidDob(val) ? null : 'Not a valid date',
                    onSaved: (val) => newContact.dob = convertToDate(val),
                  )
                ),
                new IconButton(icon: new Icon(Icons.more_horiz), onPressed: ((){
                  _chooseDate(context, _controller.text);
                }),
                )
              ],),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.phone),
                  hintText: 'Enter a phone number',
                  labelText: 'Phone',
                ),
                keyboardType: TextInputType.phone,
                onSaved: (val) => newContact.phone = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email),
                  hintText: 'Enter an email address',
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                // validator: (val) => isValidEmail(val) ? null
                //     : 'Please enter a valid email address',
                onSaved: (val) => newContact.email = val,
              ),
              FormField<String>(
                // initialValue: _chosenValue,
                // onSaved: (val) => _chosenValue = val,
                validator:(val){
                  return val != '' ? null : 'Please select a color';
                },
                    // (val) => (val == null || val.isEmpty) ? 'Please choose a color' : null,
                builder: (FormFieldState<String> state){
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: Icon(Icons.color_lens),
                      labelText: 'Favorite Color',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    isEmpty: _color == '',
                    // state.value == '' || state.value == null,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _color,
                        // state.value,
                        isDense: true,
                        onChanged: (String newValue){
                          // if(newValue == ''){
                          //   newValue == null;
                          // }
                          newContact.favoriteColor = newValue;
                          _color = newValue;
                          state.didChange(newValue);
                        },
                        items:
                        _colors.map((String newValue){
                        // _dropdownValues.keys.map((String value){
                          return DropdownMenuItem<String>(
                            value: newValue,
                            // value,
                            child: Text(
                              // value
                            newValue
                          ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              new Container(
                padding: EdgeInsets.only(left: 40.0,top: 20.0),
                // all(40.0),
                child: RaisedButton(
                  child: Text('Submit'),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
