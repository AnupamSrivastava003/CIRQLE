import 'package:cirqle/models/post.dart';
import 'package:cirqle/pages/account_settings_page.dart';
import 'package:cirqle/pages/blocked_users_page.dart';
import 'package:cirqle/pages/home_pages.dart';
import 'package:cirqle/pages/post_page.dart';
import 'package:cirqle/pages/profile_page.dart';
import 'package:flutter/material.dart';

// go to user page
void goUserPage(BuildContext context, String uid) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)));
}

// go to post page
void goPostPage(BuildContext context, Post post) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostPage(
                post: post,
              )));
}

// go to blocked user page
void goBlockedUsersPage(BuildContext context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => BlockedUsersPage()));
}

// go to accout settings page
void goAccountSettingsPage(BuildContext context) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => AccountSettingsPage()));
}

void goHomePage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => route.isFirst);
}
