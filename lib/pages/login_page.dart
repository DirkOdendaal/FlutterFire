import 'package:cloud/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud/classes/auth_provider.dart';

class EmailFieldValidator {
  static String? validate(String value) {
    return value == "" ? "Required" : null;
  }
}

class UsernameFieldValidator {
  static String? validate(String value) {
    return value == "" ? "Required" : null;
  }
}

class PasswordFieldValidator {
  static String? validate(String value) {
    if (value.isEmpty) {
      return "Required";
    }

    if (value.length < 8) {
      return "Minimum 8 char";
    }
  }
}

enum Formtype { login, register }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "";
  String _password = "";
  String _username = "";
  TextEditingController _firstPassword = TextEditingController();
  TextEditingController _secondPassword = TextEditingController();
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

  Future<void> _displayTextInputDialog(
      BuildContext context, int newState, String message) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Alert(
            meassage: message,
            alertState: newState,
          );
        });
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        var auth = AuthProvider.of(context)!.auth;
        if (_formType == Formtype.login) {
          await auth!.signInWithEmailAndPassword(_email, _password);
        } else {
          await auth!
              .createUserWithEmailAndPassword(_email, _password, _username);
        }
      } catch (e) {
        _displayTextInputDialog(context, 2, "Login Error $e");
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
    formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: formKey,
                child: Column(
                  children: labelInputs() + buttonInputs(),
                )),
          ),
        ),
      ),
    );
  }

  List<Widget> labelInputs() {
    if (_formType == Formtype.login) {
      return [
        TextFormField(
          decoration: const InputDecoration(labelText: "Email"),
          validator: (value) => EmailFieldValidator.validate(value!),
          onSaved: (value) => _email = value!,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Password"),
          validator: (value) => PasswordFieldValidator.validate(value!),
          onSaved: (value) => _password = value!,
          obscureText: true,
        ),
      ];
    } else {
      return [
        TextFormField(
          decoration: const InputDecoration(labelText: "Username"),
          validator: (value) => UsernameFieldValidator.validate(value!),
          onSaved: (value) => _username = value!,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Email"),
          validator: (value) => EmailFieldValidator.validate(value!),
          onSaved: (value) => _email = value!,
        ),
        TextFormField(
          controller: _firstPassword,
          decoration: const InputDecoration(labelText: "Password"),
          validator: (value) => PasswordFieldValidator.validate(value!),
          onSaved: (value) => _password = value!,
          obscureText: true,
        ),
        TextFormField(
          controller: _secondPassword,
          decoration: const InputDecoration(labelText: "Confirm Password"),
          validator: (value) {
            if (value != _firstPassword.text) {
              return "Passwords Don't Match";
            }
          },
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
