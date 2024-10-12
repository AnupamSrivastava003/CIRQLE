// the database service class handles data to and from firebase
// this database provider class processes the data to display in our app
// this makes our code more modular, cleaner and easier to read and test

// also if one day we decide to switch our backend (from firebase to something else)
// then its much easier to manage and switch to the other database.

import 'package:cirqle/models/comment.dart';
import 'package:cirqle/models/post.dart';
import 'package:cirqle/models/user.dart';
import 'package:cirqle/services/auth/auth_service.dart';
import 'package:cirqle/services/database/database_service.dart';
import 'package:flutter/material.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _db = DatabaseService();

  // get user profile
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  // update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  //POSTS

  // local list of posts
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  // get post
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

  // post Message
  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);
    await loadAllPosts();
  }

  // fetch all posts
  Future<void> loadAllPosts() async {
    final allPosts = await _db.getAllPostFromFirebase();
    // get blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    // filter out blocked user &update locally
    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

    loadFollowingPosts();
    initializeLikeMap();
    notifyListeners();
  }

  //filter and return posts given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  // load following post
  Future<void> loadFollowingPosts() async {
    String currentUid = _auth.getCurrentUid();
    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);
    _followingPosts =
        _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();
    notifyListeners();
  }

  // delete post
  Future<void> deletePost(String postId) async {
    await _db.deletePostFromFirebase(postId);
    await loadAllPosts();
  }

  // likes

  // local map to create like counts for each post
  Map<String, int> _likeCounts = {
    // for each postid: count like
  };

  // local list to track posts liked by current user
  List<String> _likedPosts = [];

  // does the current user like this post
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  // get like count for a post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  // initialize like map locally
  void initializeLikeMap() {
    final currentUserID = _auth.getCurrentUid();

    // when new user logs in clear the local data
    _likedPosts.clear();

    // for each post get like data
    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;
      // if the current user already like this psot
      if (post.likedBy.contains(currentUserID)) {
        // add this post of local list of liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  // toggle likes
  Future<void> toggleLike(String postId) async {
    // store original value in case it fails
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;

    // perform like/dislike
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    notifyListeners();

    try {
      await _db.toggleLikeInFirebase(postId);
    } catch (e) {
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;
      notifyListeners();
    }
  }

  // Comments
  // local list of comments
  final Map<String, List<Comment>> _comments = {};

  // get comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  // fetch comments from database for a post
  Future<void> loadComments(String postId) async {
    final allComments = await _db.getCommentsFromFirebase(postId);
    _comments[postId] = allComments;
    notifyListeners();
  }

  // add comment
  Future<void> addComment(String postId, message) async {
    await _db.addCommentInFirebase(postId, message);
    await loadComments(postId);
  }

  // delete a comment
  Future<void> deleteComment(String commentId, postId) async {
    await _db.deleteCommentInFirebase(commentId);
    await loadComments(postId);
  }

  // ACCOUNT STUFF

  // local list of blocked users
  List<UserProfile> _blockedUsers = [];

  // get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUsers;

  // fetch blocked user
  Future<void> loadBlockedUsers() async {
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();
    final blockedUsersData = await Future.wait(
        blockedUserIds.map((id) => _db.getUserFromFirebase(id)));
    _blockedUsers = blockedUsersData.whereType<UserProfile>().toList();
    notifyListeners();
  }

  // block user
  Future<void> blockUser(String userId) async {
    await _db.blockUserInFirebase(userId);
    await loadBlockedUsers();
    await loadAllPosts();
    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String blockedUserId) async {
    await _db.unblockUserInFirebase(blockedUserId);
    await loadBlockedUsers();
    await loadAllPosts();
    notifyListeners();
  }

  // report user
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserInFirebase(postId, userId);
  }

  // FOLLOWERS

  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  // load follower
  Future<void> loadUserFollowers(String uid) async {
    final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);

    // update local data
    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;

    notifyListeners();
  }

  // load following
  Future<void> loadUserFollowing(String uid) async {
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    // update local data
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;

    notifyListeners();
  }

  // follow user
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    if (!_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.add(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;

      _following[currentUserId]?.add(targetUserId);

      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
    }
    notifyListeners();

    try {
      await _db.followUserInFirebase(targetUserId);
      await loadUserFollowers(currentUserId);
      await loadUserFollowing(currentUserId);
    } catch (e) {
      _followers[targetUserId]?.remove(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;
      _following[currentUserId]?.remove(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;
      notifyListeners();
    }
  }

  // unfollow user
  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    if (_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.remove(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;

      _following[currentUserId]?.remove(targetUserId);

      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1;
    }
    notifyListeners();

    try {
      await _db.unFollowUserInFirebase(targetUserId);
      await loadUserFollowers(currentUserId);
      await loadUserFollowing(currentUserId);
    } catch (e) {
      _followers[targetUserId]?.add(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;
      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
      notifyListeners();
    }
  }

  // is current user following target user
  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  // map of profiles
  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];
  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  // loading them
  Future<void> loadUsersFollowerProfiles(String uid) async {
    try {
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);
      List<UserProfile> followerProfiles = [];
      for (String followerId in followerIds) {
        UserProfile? followerProfile =
            await _db.getUserFromFirebase(followerId);
        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }
      _followersProfile[uid] = followerProfiles;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadUsersFollowingProfiles(String uid) async {
    try {
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);
      List<UserProfile> followingProfiles = [];
      for (String followingId in followingIds) {
        UserProfile? followingProfile =
            await _db.getUserFromFirebase(followingId);
        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        }
      }
      _followingProfile[uid] = followingProfiles;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // search

  List<UserProfile> _searchResults = [];
  List<UserProfile> get searchResult => _searchResults;

  Future<void> searchUsers(String searchTerm) async {
    try {
      final results = await _db.searchUserInFirebase(searchTerm);
      _searchResults = results;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
