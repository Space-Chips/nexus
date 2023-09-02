import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPostsPage extends StatefulWidget {
  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  String userEmailFilter = ''; // Initialize filter string

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Posts'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  userEmailFilter = value; // Update filter when text changes
                });
              },
              decoration: InputDecoration(
                labelText: 'Filter by Email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Posts")
                  .where('UserEmail',
                      isEqualTo: userEmailFilter) // Filter by email
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Check if data is not null and if docs is not empty
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  // Extract the list of posts
                  final List<DocumentSnapshot> posts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index].data() as Map<String, dynamic>;

                      // Display the post details
                      return ListTile(
                        title: Text(post['Message']),
                        subtitle: Text('Posted by: ${post['User']}'),
                      );
                    },
                  );
                } else {
                  return Text('No posts found.');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
