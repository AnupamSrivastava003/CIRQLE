// shows individual posts and comments in the post

import 'package:cirqle/components/my_comment_tile.dart';
import 'package:cirqle/components/my_post_tile.dart';
import 'package:cirqle/helper/navigate_pages.dart';
import 'package:cirqle/models/post.dart';
import 'package:cirqle/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    // listen to all comments for this post
    final allComments = listeningProvider.getComments(widget.post.id);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Comments'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          MyPostTile(
            post: widget.post,
            onUserTap: () => goUserPage(context, widget.post.uid),
            onPostTap: () {},
          ),

          // comments on this post
          allComments.isEmpty
              ? Center(
                  child: Text("No comments yet.."),
                )
              : ListView.builder(
                  itemCount: allComments.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final comment = allComments[index];
                    return MyCommentTile(
                        comment: comment,
                        onUserTap: () => goUserPage(context, comment.uid));
                  })
        ],
      ),
    );
  }
}
