import 'package:flutter/material.dart';
import 'package:tailors_connect/screens/userscreen/favpage.dart';
import 'package:tailors_connect/screens/userscreen/profilepage.dart';
import 'package:tailors_connect/screens/userscreen/uhomepage.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomestate();
}

class _UserHomestate extends State<UserHome> {
  int index = 0;
  final pages = [
    const UserHomePage(),
    FavouritePage(),
    //const SentRequestsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[index],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: (value) {
              setState(() {
                index = value;
              });
            },
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.red,
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_sharp),
                label: 'Favourite',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.send),
              //   label: 'Sent Requests',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
