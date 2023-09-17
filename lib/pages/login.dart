import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/login_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String selectedValue = "planner@g.com";

  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: selectedValue, password: passwordController.text);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print(e.code);
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        wrongPasswordMessage();
      }
    }
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Password salah'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'lib/images/Illustration.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Login ",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'nunito',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
              Text('Page',
                  style: TextStyle(
                    color: Color(0xFFFFC30D),
                    fontFamily: 'nunito',
                    fontSize: 30,
                  )),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          DropdownButton(
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: dropdownItems),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 150,
            child: TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                hintText: 'Password',
                hintStyle: TextStyle(color: Color.fromARGB(87, 255, 255, 255)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: LoginButton(
              text: "Login",
              onTap: signUserIn,
            ),
          ),
        ],
      ))),
    );
  }
}

List<DropdownMenuItem<String>> get dropdownItems {
  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(value: "planner@g.com", child: Text("Planner")),
    const DropdownMenuItem(value: "warehouse@g.com", child: Text("Warehouse")),
    const DropdownMenuItem(
        value: "purchasing@g.com", child: Text("Purchasing")),
    const DropdownMenuItem(
        value: "grupleader@g.com", child: Text("Grup Leader")),
  ];
  return menuItems;
}
