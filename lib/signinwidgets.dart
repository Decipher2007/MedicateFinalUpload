import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testforkotlinversion/main.dart';
import 'package:testforkotlinversion/profile_screen.dart';
import 'package:testforkotlinversion/signinwidgets.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInLoad extends StatefulWidget {
  const SignInLoad({super.key});

  @override
  State<SignIn> createState() => _SignInLoadState();
}

class _SignInLoadState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SignIn();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  static Future<void> signInUsingEmailPassword({required String email, required String password, required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        print("No User was found for that email");
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _passwordSecondController = TextEditingController();
    TextEditingController _nameController = TextEditingController();

    var _formKey = GlobalKey<FormState>();
    bool isLoading = false;
    void _submit() {

      final isValid = _formKey.currentState!.validate();
      if (!isValid) {
        return;
      }
      _formKey.currentState!.save();
    }



    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text("Medicate", style: TextStyle(color: Colors.black, fontSize: 28.0, fontWeight: FontWeight.bold)),
              const Text("Sign In To Your App", style: TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25.0),
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  hintText: "First Name",
                  prefixIcon: Icon(Icons.add_chart_rounded, color: Colors.black),
                ),
              ),
              const SizedBox(height: 25.0),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "User Email",
                  prefixIcon: Icon(Icons.mail, color: Colors.black),
                ),
              ),
              Form(
                key: _formKey,
                child: Column (
                  children: <Widget>[
                    const SizedBox(
                      height: 26.0,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "User Password",
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
                      ),
                      onFieldSubmitted: (value) {},
                      validator: (value) {
                        if (value == null || value.isEmpty || value != _passwordSecondController.text) {
                          return 'No Whitespace or Different Passwords';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 26.0,
                    ),
                    TextFormField(
                      controller: _passwordSecondController,
                      obscureText: true,
                      onFieldSubmitted: (value) {},
                      decoration: const InputDecoration(
                        hintText: "Confirm User Password",
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value != _passwordController.text) {
                          return 'No Whitespace or Different Passwords';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              const Text(
                  "Don't Remember your Password?",
                  style: TextStyle(color: Colors.blue)
              ),
              const SizedBox(
                height: 5.0,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> LoginScreen()));
                },
                child: const Text(
                  "Have an Account? Log In",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              Container(
                width: 400,
                child: RawMaterialButton(
                  fillColor: const Color(0xFF0069FE),
                  elevation: 0.0,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.0)
                  ),
                  onPressed: () async {
                    _submit();
                    if (_formKey.currentState!.validate() == true) {

                      signInUsingEmailPassword(email: _emailController.text, password: _passwordController.text, context: context);

                      FirebaseAuth auth = FirebaseAuth.instance;
                      User? user;

                      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                      String? uid = userCredential.user?.uid;

                      var db = FirebaseFirestore.instance;


                      final userData = {
                        "Name": _nameController.text,
                      };

                      // Create or update user document in Firestore
                      db.collection("Users").doc(uid).set(userData, SetOptions(merge: true));

                      // Create an empty "Events" sub-collection for the user
                      await db.collection("Users").doc(uid).collection("Events").add({});



                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> MyHomePage()));
                    }

                  },
                  child: const Text("Sign In",
                    style: TextStyle (
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );



  }
}

