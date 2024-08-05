import 'package:contacts/screens/contacts.dart';
import 'package:contacts/screens/favourites.dart';
import 'package:contacts/screens/recents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomIndexProvider = StateProvider<int>((ref) => 0);

class BottomBar extends ConsumerStatefulWidget {
  const BottomBar({super.key});

  @override
  ConsumerState createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  @override
  Widget build(BuildContext context) {
    final index = ref.watch(bottomIndexProvider);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              selectedIcon: Icon(Icons.watch_later_rounded, size: 26),
              icon: Icon(Icons.watch_later_outlined, size: 26),
              tooltip: "Recent",
              label: ""),
          NavigationDestination(
            icon: Icon(size: 26, Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, size: 26),
            tooltip: "Contacts",
            label: "",
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline_rounded, size: 26),
            selectedIcon: Icon(Icons.star_rounded, size: 26),
            tooltip: "Favorites",
            label: "",
          ),
        ],
        selectedIndex: index,
        onDestinationSelected: (value) {
          ref.read(bottomIndexProvider.notifier).state = value;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.dialpad),
      ),
      body: const [
        RecentScreen(),
        ContactScreen(),
        FavScreen(),
      ][index],
    );
  }
}
