import 'package:cirqle/components/my_drawer.dart';
import 'package:cirqle/components/my_input_alert_box.dart';
import 'package:cirqle/components/my_post_tile.dart';
import 'package:cirqle/helper/navigate_pages.dart';
import 'package:cirqle/models/post.dart';
import 'package:cirqle/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  final _messageController = TextEditingController();

  // on startup
  @override
  void initState() {
    super.initState();
    loadAllPosts();
  }

  // load all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  // show post message dialog box
  void _openPostMessageBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: _messageController,
            hintText: "What's on your mind?",
            onPressed: () async {
              await postMessage(_messageController.text);
            },
            onPressedText: "Post"));
  }

  // user wants to post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: AppBar(
          title: Text(
            "H O M E",
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.inversePrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              tabs: [
                Tab(
                  text: "For you",
                ),
                Tab(
                  text: "Following",
                ),
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.add),
        ),
        body: TabBarView(children: [
          _buildPostList(listeningProvider.allPosts),
          _buildPostList(listeningProvider.followingPosts),
        ]),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? Center(
            child: Text("Nothing's here.."),
          )
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MyPostTile(
                post: post,
                onUserTap: () => goUserPage(context, post.uid),
                onPostTap: () => goPostPage(context, post),
              );
            });
  }
}
