import 'package:chatapplication/pages/auth/register_page.dart';
import 'package:chatapplication/service/auth_service.dart';
import 'package:chatapplication/service/database_service.dart';
import 'package:chatapplication/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helper/helper_function.dart';
import '../homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical:80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text("Let's Talk",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
                const SizedBox(height: 10),
                const Text("Login In to Your Account",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400
                  ),
                ),
                Image.asset("assets/login.png"),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Theme.of(context).primaryColor,
                    )
                  ),
                  onChanged: (val) {
                    setState(() {
                      email = val;
                      //print(email);
                    });
                  },
                  validator: (val) {
                    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!)
                        ? null : "Please Enter a valid email";
                  }
                ),

                const SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: textInputDecoration.copyWith(
                      labelText: "Password",
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Theme.of(context).primaryColor,
                      )
                  ),
                  validator: (val){
                    if(val!.length < 6){
                      return "Password must be at least 6 characters";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (val) {
                    setState(() {
                      password = val;
                      //print(password);
                    });
                  },
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                      )
                    ),
                    child: const Text(
                      "Log In",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      login();
                    } ,
                  ),
                ),
                const SizedBox(height: 10,),
                Text.rich(
                  TextSpan(
                    text: "Don't Have An Account? ",
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Register Here",
                        style: const TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          nextScreen(context, const RegisterPage());
                        }
                      )
                    ]
                  )
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  login () async {
    if(formKey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      await authService.loginWithEmailAndPassword(email, password).then((value) async{
        if(value == true){
          QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);

          //saving value to shared preferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(
            snapshot.docs[0]["fullName"]
          );

          nextScreenReplacement(context, const HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }


}
