import 'dart:math';

import 'package:call_log/call_log.dart';
import 'package:contacts/utils/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

final recentLogsProvider = FutureProvider<Iterable<CallLogEntry>>((ref) async {
  Iterable<CallLogEntry> entries = await CallLog.get();

  Map<String, CallLogEntry> unique = {};

  for (final entry in entries) {
    if (!unique.containsKey(entry.number.toString())) {
      unique[entry.number.toString()] = entry;
    }
  }

  final uniqueValues = unique.values.take(5);

  return uniqueValues;
});

class RecentScreen extends ConsumerStatefulWidget {
  const RecentScreen({super.key});

  @override
  ConsumerState createState() => _RecentScreenState();
}

class _RecentScreenState extends ConsumerState<RecentScreen> {
  List<Map<String, dynamic>> _groupLogsByDate(List<CallLogEntry> logs) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final yesterday =
        DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    List<CallLogEntry> todayLogs = [];
    List<CallLogEntry> yesterdayLogs = [];
    List<CallLogEntry> olderLogs = [];

    for (var log in logs) {
      final logDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.fromMillisecondsSinceEpoch(log.timestamp!));
      if (logDate == today) {
        todayLogs.add(log);
      } else if (logDate == yesterday) {
        yesterdayLogs.add(log);
      } else {
        olderLogs.add(log);
      }
    }

    return [
      if (todayLogs.isNotEmpty) {'label': 'Today', 'logs': todayLogs},
      if (yesterdayLogs.isNotEmpty)
        {'label': 'Yesterday', 'logs': yesterdayLogs},
      if (olderLogs.isNotEmpty) {'label': 'Older', 'logs': olderLogs},
    ];
  }

  final isSelectedProvider = StateProvider<String>((ref) => "");
  final isShowProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MySearchBar(),
            Expanded(
              child: ref.watch(recentLogsProvider).when(
                  data: (data) {
                    final dt = data.toList();
                    final groupedLogs = _groupLogsByDate(dt);

                    return RefreshIndicator(
                      onRefresh: () {
                        ref.watch(recentLogsProvider);
                        return Future.delayed(const Duration(seconds: 2));
                      },
                      child: ListView.builder(
                        itemCount: groupedLogs.length,
                        itemBuilder: (context, index) {
                          final logGroup = groupedLogs[index];
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Text(
                                  logGroup['label'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ),
                              ...logGroup['logs'].map<Widget>((log) {
                                CallLogEntry recents = log;
                                Color color = colors[Random().nextInt(11)];
                                return RecentCard(
                                    recents: recents,
                                    isShowProvider: isShowProvider,
                                    isSelectedProvider: isSelectedProvider,
                                    color: color);
                              }),
                            ],
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator())),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentCard extends ConsumerWidget {
  const RecentCard({
    super.key,
    required this.recents,
    required this.isShowProvider,
    required this.isSelectedProvider,
    required this.color,
  });

  final CallLogEntry recents;
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
          horizontal: selected == recents.number.toString() ? 12 : 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        highlightColor: Theme.of(context).primaryColorLight.withOpacity(0.1),
        splashColor: Theme.of(context).primaryColorLight.withOpacity(0.5),
        onTap: () {
          ref.read(isShowProvider.notifier).state = false;
          ref.read(isSelectedProvider.notifier).state = "";

          if (selected != recents.number.toString()) {
            ref.read(isSelectedProvider.notifier).state =
                recents.number.toString();
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
            color: selected == recents.number.toString()
                ? Theme.of(context).colorScheme.primaryFixed
                : Colors.transparent,
            shadows: selected == recents.number.toString()
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
          height: selected == recents.number.toString() ? 160 : 90,
          alignment: Alignment.center,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 18),
                child: Head(colors: color, recents: recents),
              ),
              Visibility(
                visible: selected == recents.number.toString() ? isShow : false,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Body(contact: recents),
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

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.contact,
  });

  final CallLogEntry contact;

  saveToFav() async {
    await Hive.openBox("favourites");
    Hive.box("favourites").add({"name": "test"});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 20),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_outlined, size: 26),
                  Text("Video Call",
                      style: Theme.of(context).textTheme.labelLarge),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.message_outlined, size: 24),
                  Text("Message",
                      style: Theme.of(context).textTheme.labelLarge),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.history_outlined, size: 24),
                  Text("History",
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {},
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.star_outline_rounded, size: 24),
                  Text("Favorite",
                      style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

class Head extends StatelessWidget {
  const Head({
    super.key,
    required this.colors,
    required this.recents,
  });

  final Color colors;
  final CallLogEntry recents;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // LEADING

        Container(
          height: 50,
          width: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors,
            shape: BoxShape.circle,
          ),
          child: Text(
            recents.name?.isNotEmpty == true
                ? recents.name![0].toUpperCase()
                : "U",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        // CENTER

        const SizedBox(width: 15),

        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recents.name?.isNotEmpty == true
                    ? recents.name!.toString()
                    : recents.cachedMatchedNumber.toString(),
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  recents.callType == CallType.incoming
                      ? const Icon(
                          Icons.call_received,
                          size: 18,
                        )
                      : recents.callType == CallType.missed
                          ? const Icon(
                              Icons.call_missed,
                              size: 18,
                              color: Colors.red,
                            )
                          : recents.callType == CallType.outgoing
                              ? const Icon(
                                  Icons.call_made,
                                  size: 18,
                                )
                              : const Icon(
                                  Icons.call_missed,
                                  size: 18,
                                  color: Colors.red,
                                ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('E hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            recents.timestamp!.toInt())),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        ),

        //   TRAILING

        const Spacer(),

        Transform.flip(
          flipX: true,
          child: IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
