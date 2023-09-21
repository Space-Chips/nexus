import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/components/wall_post.dart';
import 'package:nexus/helper/helper_methods.dart';

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  String userEmailFilter = ''; // Initialize filter string

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('U S E R  P O S T S'),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
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
              decoration: const InputDecoration(
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
                      isGreaterThanOrEqualTo:
                          userEmailFilter) // Filter by email
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    // Center the CircularProgressIndicator
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Check if data is not null and if docs is not empty
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      // get messages
                      final post = snapshot.data!.docs[index];
                      return WallPost(
                        message: post['Message'],
                        user: post['User'],
                        userEmail: post['UserEmail'],
                        isAdminPost: post['isAdminPost'],
                        mediaDest: post['MediaDestination'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                        time: formatDate(post['TimeStamp']),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error:${snapshot.error}'),
                  );
                } else {
                  return const Center(
                    child: Text('No posts found.'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Posts")
          .doc(postId)
          .collection("Comments")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData) {
          final comments = snapshot.data!.docs;

          return Column(
            children: comments.map((comment) {
              final commentData = comment.data();
              return ListTile(
                title: Text(commentData['CommentText']),
                subtitle: Text('Commented by: ${commentData['CommentedBy']}'),
              );
            }).toList(),
          );
        } else {
          return const Text('No comments yet.');
        }
      },
    );
  }
}
