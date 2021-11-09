import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Formtype { login, register }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "";
  String _password = "";
  Formtype _formType = Formtype.login;
  final formKey = GlobalKey<FormState>();
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == Formtype.login) {
          
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _email, password: _password);
        }
      } catch (e) {
        print('Error $e');
        // Hanle errors here
      }
    }
  }

  void moveToRegister() {
    formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.register;
    });
  }

  void moveToLogin() {
    setState(() {
      formKey.currentState!.reset();
      _formType = Formtype.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: labelInputs() + buttonInputs(),
            )),
      ),
    );
  }

  List<Widget> labelInputs() {
    if (_formType == Formtype.login) {
      return [
        TextFormField(
          decoration: const InputDecoration(labelText: "Email"),
          validator: (value) => value == "" ? "Email Required" : null,
          onSaved: (value) => _email = value!,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Password"),
          validator: (value) => value == "" ? "Password Required" : null,
          onSaved: (value) => _password = value!,
          obscureText: true,
        ),
      ];
    } else {
      return [
        TextFormField(
          decoration: const InputDecoration(labelText: "Email"),
          validator: (value) => value == "" ? "Email Required" : null,
          onSaved: (value) => _email = value!,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Password"),
          validator: (value) => value == "" ? "Password Required" : null,
          onSaved: (value) => _password = value!,
          obscureText: true,
        ),
      ];
    }
  }

  List<Widget> buttonInputs() {
    if (_formType == Formtype.login) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: ElevatedButton(
              onPressed: validateAndSubmit,
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 20.0),
              )),
        ),
        TextButton(
            onPressed: moveToRegister,
            child: const Text(
              "New here? Create and account.",
              style: TextStyle(fontSize: 12.0),
            ))
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: ElevatedButton(
              onPressed: validateAndSubmit,
              child: const Text(
                "Create Account",
                style: TextStyle(fontSize: 20.0),
              )),
        ),
        TextButton(
            onPressed: moveToLogin,
            child: const Text(
              "Already have account? Login.",
              style: TextStyle(fontSize: 12.0),
            ))
      ];
    }
  }
}
