import 'dart:math';

import 'package:contacts/screens/favourites.dart';
import 'package:contacts/utils/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final getContactProvider = FutureProvider<List<Contact>>((ref) async {
  List<Contact> contacts = [];
  if (await FlutterContacts.requestPermission()) {
    contacts = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);
  }

  return contacts;
});

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  List<Map<String, Object>> groupList(List<Contact> contacts) {
    final Map<String, List<Contact>> groupedLists = {};

    for (var person in contacts) {
      if (person.displayName.isNotEmpty) {
        final firstLetter = person.displayName[0].toUpperCase();
        if (groupedLists[firstLetter] == null) {
          groupedLists[firstLetter] = <Contact>[];
        }

        groupedLists[firstLetter]!.add(person);
      }
    }

    groupedLists.removeWhere(
      (key, value) {
        value.removeWhere((element) => element.displayName.startsWith("+"));
        value.removeWhere((element) => element.displayName.startsWith("."));
        value.removeWhere((element) => element.displayName
            .startsWith(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')));

        value.removeWhere((element) => element.phones.isEmpty);

        return value.isEmpty;
      },
    );

    return groupedLists.entries
        .map((entry) => {'label': entry.key, 'contacts': entry.value})
        .toList();
  }

  final isSelectedProvider = StateProvider<String>((ref) => "");
  final isShowProvider = StateProvider<bool>((ref) => false);

  final colors = [
    Colors.red.withOpacity(0.8),
    Colors.green.withOpacity(0.8),
    Colors.blue.withOpacity(0.8),
    Colors.purple.withOpacity(0.8),
    Colors.orange.withOpacity(0.8),
    Colors.pink.withOpacity(0.8),
    Colors.indigo.withOpacity(0.8),
    Colors.teal.withOpacity(0.8),
    Colors.brown.withOpacity(0.8),
    Colors.lime.withOpacity(0.8),
    Colors.pinkAccent.withOpacity(0.8),
  ];

  @override
  Widget build(BuildContext context) {
    final contactList = ref.watch(getContactProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MySearchBar(),
            Expanded(
                child: contactList.when(
              data: (data) {
                final groupedData = groupList(data).toList();

                return CustomScrollView(
                  slivers: [
                    for (var data in groupedData)
                      SliverCrossAxisGroup(
                        slivers: [
                          SliverAppBar(
                            title: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(data['label'].toString()),
                            ),
                            titleTextStyle: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            pinned: true,
                            forceMaterialTransparency: true,
                            toolbarHeight: 70,
                          ),
                          SliverCrossAxisExpanded(
                            flex: 8,
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  List<Contact> contact =
                                      data['contacts'] as List<Contact>;

                                  Color color = colors[Random().nextInt(11)];

                                  return ContactCard(
                                    contact: contact[index],
                                    isShowProvider: isShowProvider,
                                    isSelectedProvider: isSelectedProvider,
                                    color: color,
                                  )
                                      .animate()
                                      .fadeIn(
                                        duration: 150.ms,
                                        curve: Curves.easeInOut,
                                      )
                                      .moveX(
                                        begin: 60,
                                        duration: 500.ms,
                                        curve: Curves.easeInOut,
                                      );
                                },
                                childCount:
                                    (data['contacts'] as List<Contact>).length,
                              ),
                            ),
                          )
                        ],
                      ),
                  ],
                );
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends ConsumerWidget {
  const ContactCard({
    super.key,
    required this.contact,
    required this.isShowProvider,
    required this.isSelectedProvider,
    required this.color,
  });

  final Contact contact;
  final StateProvider<bool> isShowProvider;
  final StateProvider<String> isSelectedProvider;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(isSelectedProvider);

    final isShow = ref.watch(isShowProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: EdgeInsets.symmetric(
          horizontal: selected == contact.displayName.toString() ? 12 : 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        highlightColor: Theme.of(context).primaryColorLight.withOpacity(0.1),
        splashColor: Theme.of(context).primaryColorLight.withOpacity(0.5),
        onTap: () {
          ref.read(isShowProvider.notifier).state = false;
          ref.read(isSelectedProvider.notifier).state = "";

          if (selected != contact.displayName.toString()) {
            ref.read(isSelectedProvider.notifier).state =
                contact.displayName.toString();
            Future.delayed(const Duration(milliseconds: 240), () {
              ref.read(isShowProvider.notifier).state = true;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linearToEaseOut,
          decoration: ShapeDecoration(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            color: selected == contact.displayName.toString()
                ? Theme.of(context).colorScheme.primaryFixed
                : Colors.transparent,
            shadows: selected == contact.displayName.toString()
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 1,
                      spreadRadius: 0.1,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          height: selected == contact.displayName ? 160 : 90,
          alignment: Alignment.center,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Head(color: color, contact: contact),
              ),
              Visibility(
                visible:
                    selected == contact.displayName.toString() ? isShow : false,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Body(contact: contact),
                    ),
                  ],
                ).animate().fadeIn(duration: 120.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Head extends StatelessWidget {
  const Head({
    super.key,
    required this.color,
    required this.contact,
  });

  final Color color;
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        contact.displayName.toString(),
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            image: contact.thumbnail == null
                ? null
                : DecorationImage(
                    image: MemoryImage(
                      contact.thumbnail!,
                    ),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
          ),
          child: contact.thumbnail == null
              ? Text(
                  contact.displayName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                )
              : null),
    );
  }
}

class Body extends ConsumerStatefulWidget {
  const Body({super.key, required this.contact});

  final Contact contact;

  @override
  ConsumerState createState() => _BodyState();
}

class _BodyState extends ConsumerState<Body> {
  saveToFav() async {
    await Hive.openBox("favourites");
    final box = Hive.box("favourites");

    final data = {
      "name": widget.contact.displayName,
      "number": widget.contact.phones[0].number,
      "image": widget.contact.thumbnail,
      "id": widget.contact.id,
    };

    if (box.containsKey(widget.contact.id)) {
      box.delete(widget.contact.id);
    } else {
      box.put(widget.contact.id, data);
    }
    ref.refresh(getFavListProvider);
    setState(() {});
  }

  favIcon(id) {
    final box = Hive.box("favourites");
    if (box.containsKey(id)) {
      return const Icon(Icons.star_rounded, size: 24);
    } else {
      return const Icon(Icons.star_outline_rounded, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 50,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call_outlined, size: 24),
                  Text("Call", style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: 70,
                height: 50,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.message_outlined, size: 24),
                    Text("Message",
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              saveToFav();
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: 70,
                height: 50,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    favIcon(widget.contact.id),
                    Text("Favorite",
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
