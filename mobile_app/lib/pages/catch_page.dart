import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:mobile_app/models/models.dart';
import 'dart:convert';
import 'package:mobile_app/l10n/app_localizations.dart';

class CatchPage extends StatefulWidget {
  const CatchPage({super.key});

  @override
  State<CatchPage> createState() => _CatchPageState();
}

class _CatchPageState extends State<CatchPage> {
  final _controller = ScrollController();
  bool _showBottomBar = true;
  late Future<void> _fetchCatchesFuture;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
    _fetchCatchesFuture = _fetchCatches();
  }

  void _scrollListener() {
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;

    final atBottom = (currentScroll >= maxScroll - 10);
    if (_showBottomBar == atBottom) {
      setState(() {
        _showBottomBar = !atBottom;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<String> dates = const [
    'March 13, 2025',
    'March 14, 2025',
    'March 15, 2025',
    'March 16, 2025',
    'March 17, 2025',
    'March 18, 2025',
  ];

  // var _catches = <FishingModel>[
  //   FishingModel(
  //     id: 1,
  //     startTime: '2025-03-13T08:00:00',
  //     endTime: '2025-03-13T08:30:00',
  //     userEmail: 'i.ivanov@example.com',
  //     water: WaterModel(id: 1, x: 0.1, y: 0.2),
  //     caughtFish: [
  //       CaughtFishModel(
  //         id: 1,
  //         fisher: 'i.ivanov@example.com',
  //         avgWeight: 3.0,
  //         fish: FishModel(
  //           id: 1,
  //           name: 'CARP',
  //           photo: 'https://example.com/carp.jpg',
  //         ),
  //       ),
  //       CaughtFishModel(
  //         id: 3,
  //         fisher: 'j.smith@example.com',
  //         avgWeight: 1.8,
  //         fish: FishModel(
  //           id: 3,
  //           name: 'PIKE',
  //           photo: 'https://example.com/pike.jpg',
  //         ),
  //       ),
  //       CaughtFishModel(
  //         id: 4,
  //         fisher: 'a.jones@example.com',
  //         avgWeight: 2.2,
  //         fish: FishModel(
  //           id: 4,
  //           name: 'PERCH',
  //           photo: 'https://example.com/perch.jpg',
  //         ),
  //       ),
  //       CaughtFishModel(
  //         id: 5,
  //         fisher: 'm.brown@example.com',
  //         avgWeight: 2.9,
  //         fish: FishModel(
  //           id: 5,
  //           name: 'BREAM',
  //           photo: 'https://example.com/bream.jpg',
  //         ),
  //       ),
  //       CaughtFishModel(
  //         id: 6,
  //         fisher: 'm.brown@example.com',
  //         avgWeight: 2.9,
  //         fish: FishModel(
  //           id: 5,
  //           name: 'BREAM',
  //           photo: 'https://example.com/bream.jpg',
  //         ),
  //       ),
  //     ],
  //   ),
  //   FishingModel(
  //     id: 2,
  //     userEmail: 'b.ivanov',
  //     startTime: '2025-03-14T09:00:00',
  //     endTime: '2025-03-14T15:00:00',
  //     caughtFish: [
  //       CaughtFishModel(
  //         id: 2,
  //         fisher: 'sadfasj',
  //         avgWeight: 2.5,
  //         fish: FishModel(
  //           id: 2,
  //           name: 'STURGEON',
  //           photo: 'https://example.com/sturgeon.jpg',
  //         ),
  //       ),
  //     ],
  //     water: WaterModel(id: 2, x: 0.3, y: 0.4),
  //   ),
  // ];

  var _catches = <FishingModel>[];

  Future<void> _fetchCatches() async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    final box = Hive.box('settings');
    final email = box.get('email', defaultValue: '');
    try {
      final response = await http.get(
        Uri.parse('https://capstone.aquaf1na.fun/api/fishing/email/$email'),
      );
      debugPrint('Fetching catches for $email');
      if (response.statusCode == 200) {
        debugPrint(response.body);
        final List<dynamic> data = response.body.isNotEmpty
            ? (jsonDecode(response.body) as List)
            : [];
        _catches = data
            .map((e) => FishingModel.fromJson(e as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
        debugPrint('Fetched ${_catches.length} catches');
      } else {
        throw Exception('Failed to load catches ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching catches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.myCatchText),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: _fetchCatchesFuture,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                controller: _controller,
                itemCount: _catches.length,
                itemBuilder: (context, index) {
                  var date = _catches[index].startTime.split('T')[0];
                  if (date.isEmpty) {
                    date = 'Unknown Date';
                  }
                  // Show ongoing fishing event if endTime is null
                  var duration = _catches[index].endTime != null
                      ? DateTime.parse(_catches[index].endTime!)
                            .difference(
                              DateTime.parse(_catches[index].startTime),
                            )
                            .inHours
                      : -1; // Use -1 to indicate ongoing session
                  var fishCount = _catches[index].caughtFish.length;
                  var caughtFish = _catches[index].caughtFish;
                  final fishCounts = <String, int>{};
                  for (var fish in caughtFish) {
                    final name = fish.fish.name;
                    fishCounts[name] = (fishCounts[name] ?? 0) + 1;
                  }
                  final sortedFish = fishCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final uniqueFishList = sortedFish.map((e) => e.key).toList();
                  return CatchItem(
                    date: date,
                    duration: duration,
                    fishCount: fishCount,
                    fishNames: uniqueFishList,
                  );
                },
              );
            },
          ),

          if (_showBottomBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Builder(
                builder: (context) {
                  final bottomInset = MediaQuery.of(context).viewPadding.bottom;

                  return Container(
                    color: colorScheme.secondary,
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom: bottomInset > 0 ? 0 : 16,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
