import 'package:cirqle/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // ask for confirmation
  void confirmDeletion(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Account?"),
              content:
                  const Text("Are you sure you want to delete your account?"),
              actions: [
                //  cancel
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),

                // delete
                TextButton(
                    onPressed: () async {
                      await AuthService().deleteAccount();

                      // after deleting go to login and register page
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Account Settings"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () => confirmDeletion(context),
            child: Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
