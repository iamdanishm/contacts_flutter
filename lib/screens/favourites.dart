import 'dart:math';

import 'package:contacts/utils/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class FavScreen extends ConsumerStatefulWidget {
  const FavScreen({super.key});

  @override
  ConsumerState createState() => _FavScreenState();
}

final getFavListProvider = FutureProvider((ref) async {
  final favList = await Hive.openBox('favourites');
  final favListMap = favList.toMap();

  return favListMap;
});

class _FavScreenState extends ConsumerState<FavScreen> {
  @override
  Widget build(BuildContext context) {
    final favList = ref.watch(getFavListProvider);

    final colors = [
      Colors.red.withOpacity(0.8),
      Colors.green.withOpacity(0.8),
      Colors.blue.withOpacity(0.8),
      Colors.orange.withOpacity(0.8),
      Colors.pink.withOpacity(0.8),
      Colors.indigo.withOpacity(0.8),
      Colors.teal.withOpacity(0.8),
      Colors.lime.withOpacity(0.8),
      Colors.pinkAccent.withOpacity(0.8),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MySearchBar(),
            Expanded(
              child: favList.when(
                  data: (data) => GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          mainAxisExtent: 130,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: data.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Color color = colors[Random().nextInt(9)];
                          final fav = data.values.toList()[index];
                          return CustomPopup(
                            barrierColor: Colors.green.withOpacity(0.1),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.all(3),
                            content: SizedBox(
                              width: 100,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      final box = Hive.box("favourites");
                                      box.delete(fav['id']);
                                      ref.refresh(getFavListProvider);

                                      context.pop();
                                    },
                                    style: TextButton.styleFrom(
                                      fixedSize: const Size(90, 40),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      )),
                                      foregroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    child: const Text("Remove"),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      fixedSize: const Size(90, 40),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                    child: const Text("Edit"),
                                  ),
                                ],
                              ),
                            ),
                            isLongPress: true,
                            child: Column(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  alignment: Alignment.center,
                                  decoration: ShapeDecoration(
                                      shape: ContinuousRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(60)),
                                      color: color,
                                      image: fav['image'] == null
                                          ? null
                                          : DecorationImage(
                                              image: MemoryImage(fav['image']),
                                              fit: BoxFit.cover,
                                              onError:
                                                  (exception, stackTrace) {},
                                            ),
                                      shadows: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 1,
                                          spreadRadius: 0.2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]),
                                  child: fav['image'] != null
                                      ? null
                                      : Text(
                                          fav['name'][0].toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.w500),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  fav['name'],
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  error: (e, s) => Text(e.toString()),
                  loading: () => const Center(
                        child: CircularProgressIndicator(),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
