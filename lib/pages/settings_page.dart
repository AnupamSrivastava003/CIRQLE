import 'package:cirqle/components/my_settings_tile.dart';
import 'package:cirqle/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/navigate_pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("S E T T I N G S"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // dark mode
          MySettingsTile(
              action: CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context, listen: false)
                      .isDarkMode,
                  onChanged: (value) =>
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme()),
              title: "Dark Mode"),

          // block users tile
          MySettingsTile(
              action: IconButton(
                onPressed: () => goBlockedUsersPage(context),
                icon: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: "Blocked Users"),

          // Account setting tile
          MySettingsTile(
              action: IconButton(
                  onPressed: () => goAccountSettingsPage(context),
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.primary,
                  )),
              title: "Account settings")
        ],
      ),
    );
  }
}
