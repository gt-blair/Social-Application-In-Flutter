import 'package:chatapplication/helper/helper_function.dart';
import 'package:chatapplication/pages/auth/login_page.dart';
import 'package:chatapplication/pages/profile_page.dart';
import 'package:chatapplication/pages/search_page.dart';
import 'package:chatapplication/service/auth_service.dart';
import 'package:chatapplication/service/database_service.dart';
import 'package:chatapplication/widgets/group_tile.dart';
import 'package:chatapplication/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  //string manipulation
  String getId(String res){
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }

  gettingUserData() async {
    await HelperFunction.getUserEmailFromSF().then((value){
      setState(() {
        email = value!;

      });
    });

    await HelperFunction.getUserNameFromSF().then((val){
      setState(() {
        userName = val!;
      });
    });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot){
      setState(() {
        groups = snapshot;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, SearchPage());

            },
              icon: const Icon(Icons.search,),
          ),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Groups",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 15,),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: (){},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: (){
                nextScreenReplacement(
                  context,
                  ProfilePage(email: email, userName: userName)
                );
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Logout"),
                      content: Text("Join Us Again Anytime, Confirm to Exit"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),

                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()),
                                    (route) => false);
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),

                      ],

                    );
                  }
                );
                /*authService.signOut().whenComplete(() {
                  nextScreenReplacement(context, const LoginPage());
                });*/
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Log Out",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ) ,

    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
          return AlertDialog(
            title: const Text("Create a group/forum",
              textAlign: TextAlign.left,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true ? Center(
                  child: CircularProgressIndicator(color: Theme.of(context).primaryColor,) ,
                ) : TextField(
                  onChanged: (val) {
                    setState(() {
                      groupName = val;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(20)
                    ),
                  ),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel"
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if(groupName!=""){
                    setState(() {
                      _isLoading = true;
                    });
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createGroup(
                        userName,
                        FirebaseAuth.instance.currentUser!.uid,
                        groupName).whenComplete(() {
                          _isLoading = false;
                    });
                    Navigator.of(context).pop();
                    showSnackBar(context, Colors.green, "Group Created Successfuly");
                  }
                },
                child: const Text(
                    "Create"
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                ),
              ),
            ],
          );
          }),
        );
      }
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          if(snapshot.data['groups'] != null) {
            if(snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data["groups"].length - index -1;
                  return GroupTile(
                    groupId: getId(snapshot.data["groups"][reverseIndex]),
                    groupName: getName(snapshot.data["groups"][reverseIndex]),
                    username: snapshot.data['fullName'],
                  );
                },
              );
            }else{
              return noGroupWidget();
            }
          }else{
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  noGroupWidget(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              popUpDialog(context);
            },
              child: Icon(
                Icons.add_circle,
                color: Colors.grey[700],
                size: 75,)),
          const SizedBox(height: 20,),
          const Text("You are not a member of any forum/group, Tap on the add button to create or search existing groups",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
