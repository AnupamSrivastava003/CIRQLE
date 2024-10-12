import 'package:cirqle/components/my_bio_box.dart';
import 'package:cirqle/components/my_follow_button.dart';
import 'package:cirqle/components/my_input_alert_box.dart';
import 'package:cirqle/components/my_post_tile.dart';
import 'package:cirqle/components/my_profile_stats.dart';
import 'package:cirqle/helper/navigate_pages.dart';
import 'package:cirqle/models/user.dart';
import 'package:cirqle/pages/follow_list_page.dart';
import 'package:cirqle/services/auth/auth_service.dart';
import 'package:cirqle/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // user info
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();

  // loading
  bool _isLoading = true;

  // follow unfollow toggler
  bool _isFollowing = false;

  final bioTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    // get the user profile info
    user = await databaseProvider.userProfile(widget.uid);

    await databaseProvider.loadUserFollowing(widget.uid);
    await databaseProvider.loadUserFollowers(widget.uid);

    _isFollowing = databaseProvider.isFollowing(widget.uid);

    setState(() {
      _isLoading = false;
    });
  }

  void _showEditBioBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: bioTextController,
            hintText: "Edit bio...",
            onPressed: saveBio,
            onPressedText: "Save"));
  }

  Future<void> saveBio() async {
    // start loading
    setState(() {
      _isLoading = true;
    });

    // update bio
    await databaseProvider.updateBio(bioTextController.text);

    // reload user
    await loadUser();

    // end loading
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> toggleFollow() async {
    if (_isFollowing) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Unfollow"),
                content: const Text("Are you sure you want to unfollow?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await databaseProvider.unfollowUser(widget.uid);
                      },
                      child: const Text("Yes")),
                ],
              ));
    } else {
      await databaseProvider.followUser(widget.uid);
    }
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);
    final followerCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);
    _isFollowing = listeningProvider.isFollowing(widget.uid);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(_isLoading ? '' : user!.name),
          foregroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
              onPressed: () => goHomePage(context),
              icon: const Icon(Icons.arrow_back)),
        ),
        body: ListView(
          children: [
            // user name
            Center(
                child: Text(
              _isLoading ? '' : '@${user!.username}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            )),

            const SizedBox(
              height: 25,
            ),

            // profile picture
            Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.all(25),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // profile stats - followers, following, no. of posts
            MyProfileStats(
              followerCount: followerCount,
              followingCount: followingCount,
              postCount: allUserPosts.length,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FollowListPage(
                            uid: widget.uid,
                          ))),
            ),

            const SizedBox(
              height: 25,
            ),

            // follow / unfollow button
            if (user != null && user!.uid != currentUserId)
              MyFollowButton(
                onPressed: toggleFollow,
                isFollowing: _isFollowing,
              ),

            // edit bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bio',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  if (user != null && user!.uid == currentUserId)
                    GestureDetector(
                      onTap: _showEditBioBox,
                      child: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                ],
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // bio box
            MyBioBox(text: _isLoading ? '...' : user!.bio),

            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25, bottom: 10),
              child: Text(
                "Posts",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),

            // list of all posts of a user
            allUserPosts.isEmpty
                ? const Center(
                    child: Text("No posts yet.."),
                  )
                : ListView.builder(
                    itemCount: allUserPosts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final post = allUserPosts[index];
                      return MyPostTile(
                        post: post,
                        onUserTap: () {},
                        onPostTap: () => goPostPage(context, post),
                      );
                    })
          ],
        ));
  }
}
