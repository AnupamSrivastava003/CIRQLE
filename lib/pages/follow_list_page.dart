import 'package:cirqle/components/my_user_tile.dart';
import 'package:cirqle/models/user.dart';
import 'package:cirqle/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;
  const FollowListPage({super.key, required this.uid});

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFollowerList();
    loadFollowingList();
  }

  Future<void> loadFollowerList() async {
    await databaseProvider.loadUsersFollowerProfiles(widget.uid);
  }

  Future<void> loadFollowingList() async {
    await databaseProvider.loadUsersFollowingProfiles(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    // listen
    final followers = listeningProvider.getListOfFollowersProfile(widget.uid);
    final following = listeningProvider.getListOfFollowingProfile(widget.uid);
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            foregroundColor: Theme.of(context).colorScheme.primary,
            bottom: TabBar(
                labelColor: Theme.of(context).colorScheme.inversePrimary,
                dividerColor: Colors.transparent,
                unselectedLabelColor: Theme.of(context).colorScheme.primary,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                tabs: [
                  Tab(
                    text: "Followers",
                  ),
                  Tab(
                    text: "Following",
                  ),
                ]),
          ),
          body: TabBarView(children: [
            _buildUserList(followers, "No followers.."),
            _buildUserList(following, "No following..")
          ]),
        ));
  }

  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];

              return MyUserTile(user: user);
            },
          );
  }
}
