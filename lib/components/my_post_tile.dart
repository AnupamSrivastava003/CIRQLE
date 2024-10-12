import 'package:cirqle/components/my_input_alert_box.dart';
import 'package:cirqle/helper/time_formatter.dart';
import 'package:cirqle/models/post.dart';
import 'package:cirqle/services/auth/auth_service.dart';
import 'package:cirqle/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  const MyPostTile(
      {super.key,
      required this.post,
      required this.onUserTap,
      required this.onPostTap});

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadComments();
  }

  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  final _commentComtroller = TextEditingController();

  void _openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: _commentComtroller,
            hintText: "Type a comment..",
            onPressed: () async {
              await _addComment();
            },
            onPressedText: "Post"));
  }

  // user tapped pressed button
  Future<void> _addComment() async {
    if (_commentComtroller.text.trim().isEmpty) return;

    try {
      await databaseProvider.addComment(
          widget.post.id, _commentComtroller.text.trim());
    } catch (e) {
      print(e);
    }
  }

  // load comment
  Future<void> _loadComments() async {
    await databaseProvider.loadComments(widget.post.id);
  }

  void _showOptions() {
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currentUid;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                if (isOwnPost)
                  ListTile(
                    title: Text("Delete"),
                    onTap: () async {
                      Navigator.pop(context);
                      await databaseProvider.deletePost(widget.post.id);
                    },
                    leading: Icon(Icons.delete),
                  )
                else ...[
                  ListTile(
                    title: Text("Report"),
                    onTap: () {
                      Navigator.pop(context);
                      _reportPostConfirmationBox();
                    },
                    leading: Icon(Icons.flag),
                  ),
                  ListTile(
                    title: Text("Block User"),
                    onTap: () {
                      Navigator.pop(context);
                      _blockUserConfirmationBox();
                    },
                    leading: Icon(Icons.block),
                  ),
                ],
                ListTile(
                  title: Text("Cancel"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  leading: Icon(Icons.cancel),
                ),
              ],
            ),
          );
        });
  }

  // report post confirmation
  void _reportPostConfirmationBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Report Message"),
              content:
                  const Text("Are you sure you want to report this message?"),
              actions: [
                //  cancel
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),

                // report
                TextButton(
                    onPressed: () async {
                      await databaseProvider.reportUser(
                          widget.post.id, widget.post.uid);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Message reported!")));
                    },
                    child: const Text("Report")),
              ],
            ));
  }

  // block user confirmation
  void _blockUserConfirmationBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Block User"),
              content: const Text("Are you sure you want to block this user?"),
              actions: [
                //  cancel
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),

                // report
                TextButton(
                    onPressed: () async {
                      await databaseProvider.blockUser(widget.post.uid);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User blocked!")));
                    },
                    child: const Text("Block")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // does the current user liked this post
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    // listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);

    // listen to comment count
    int commentCount = listeningProvider.getComments(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.post.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '@${widget.post.username}',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const Spacer(),
                  GestureDetector(
                      onTap: _showOptions,
                      child: Icon(
                        Icons.more_horiz,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.post.message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                // LIKES SECTION
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: _toggleLikePost,
                          child: likedByCurrentUser
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  color: Theme.of(context).colorScheme.primary,
                                )),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        likeCount != 0 ? likeCount.toString() : '',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),

                // COMMENT SECTIONS
                Row(
                  children: [
                    GestureDetector(
                      onTap: _openNewCommentBox,
                      child: Icon(
                        Icons.comment,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      commentCount != 0 ? commentCount.toString() : '',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    )
                  ],
                ),
                Spacer(),

                // timestamp
                Text(
                  formatTimeStamp(
                    widget.post.timestamp,
                  ),
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
