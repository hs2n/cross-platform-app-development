import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

// TODO: Is a global function best practice?
void _updateFirebaseToken(FirebaseUser user) async {
  if (user != null) {
    await _secureStorage.write(
        key: "firebaseToken",
        value: (await user.getIdToken(refresh: false)).token);
  } else {
    await _secureStorage.delete(key: "firebaseToken");
  }
}

class UserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase sign in"),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return FlatButton(
              child: const Text('Sign out'),
              textColor: Theme.of(context).buttonColor,
              onPressed: () async {
                _updateFirebaseToken(null); // Delete token from secure storage

                final FirebaseUser user = await _firebaseAuth.currentUser();

                if (user == null) {
                  Scaffold.of(context).showSnackBar(const SnackBar(
                    content: Text('User not logged in.'),
                  ));
                  return;
                }
                _signOut();
                final String uid = user.uid;
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(uid + ' successfully signed out.'),
                ));

                try {
                  // This is for debug purposes so account must always be chosen
                  await _googleSignIn.disconnect();
                } catch (err) {
                  print("Could not sign out: ${err.toString()}");
                }
              },
            );
          })
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _EmailPasswordForm(),
            _GoogleSignInSection(),
          ],
        );
      }),
    );
  }

  // Example code for sign out.
  void _signOut() async {
    await _firebaseAuth.signOut();
  }
}

///
///   Email / Password
///

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success;
  String _userEmail;
  String _statusMessage = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: const Text('Test sign in with email and password'),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: RaisedButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _signInWithEmailAndPassword();
                }
              },
              child: const Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "$_statusMessage",
              style: _success != false
                  ? TextStyle(color: Colors.black)
                  : TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code of how to sign in with email and password.
  void _signInWithEmailAndPassword() async {
    try {
      final FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;

      if (user != null) {
        _updateFirebaseToken(user);
        setState(() {
          _success = true;
          _userEmail = user.email;
          _statusMessage =
              "User with email '$_userEmail' successfully signed in.";
        });
      } else {
        setState(() {
          _success = false;
          _statusMessage = "Sign in failed.";
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage = "Could not sign in: ${e.message}";
      });
    } catch (err) {
      setState(() {
        _success = false;
        _statusMessage = "Encountered unexpected exception: ${err.toString()}";
      });
    }
  }
}

///
///  Google sign in
///

class _GoogleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<_GoogleSignInSection> {
  bool _success;
  String _statusMessage = "";
  String _userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: const Text('Test sign in with Google'),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton(
            onPressed: () async {
              _signInWithGoogle();
            },
            child: const Text('Sign in with Google'),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "$_statusMessage",
            style: _success != false
                ? TextStyle(color: Colors.black)
                : TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }

  // Example code of how to sign in with google.
  void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user =
          (await _firebaseAuth.signInWithCredential(credential)).user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      assert(user.uid == currentUser.uid);

      if (user != null) {
        _updateFirebaseToken(currentUser);
        setState(() {
          _success = true;
          _userID = user.uid;
          _statusMessage = "Successfully signed in uid '$_userID'";
        });
      } else {
        setState(() {
          _success = false;
          _statusMessage = "Sign in failed";
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _statusMessage =
            "Could not complete sign in through Google: ${e.message}";
      });
    } catch (err) {
      setState(() {
        _statusMessage = "Caught an unexpected exception: ${err.toString()}";
      });
    }
  }
}
