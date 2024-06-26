import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/pages/home_page.dart';
import 'package:nexus/pages/profile_page.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  String userEmailFilter = ''; // Initialize filter string

  // navigate to profile page
  void goToProfilePage(String email) {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          email: email,
        ),
      ),
    );
  }

  // navigate to home page
  void goToHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Call your function here
            goToHomePage();
          },
          child: Text(
            "S E A R C H  U S E R",
            selectionColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  userEmailFilter = value;
                });
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary,
                labelText: 'Search by username',
                labelStyle: TextStyle(
                  color: Colors.grey[500],
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.grey, // Change the color here
                    BlendMode.srcIn,
                  ),
                  child: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where('username', isGreaterThanOrEqualTo: userEmailFilter)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No users found.'),
                  );
                }

                final userItems = snapshot.data!.docs
                    .where((userDocument) =>
                        userDocument.data().containsKey('username') &&
                        userDocument.data().containsKey('email') &&
                        userDocument.data().containsKey('bio') &&
                        userDocument.data()['followers'] is List)
                    .map((userDocument) {
                  final username = userDocument['username'];
                  final email = userDocument['email'];
                  final bio = userDocument['bio'];
                  final followersCount =
                      (userDocument['followers'] as List).length.toString();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      title: Text(
                        '$username',
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bio: $bio',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Followers: $followersCount',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        child: Text(
                          username[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        goToProfilePage(email);
                      },
                    ),
                  );
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.all(15),
                    child: ListView(
                      children: userItems,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
