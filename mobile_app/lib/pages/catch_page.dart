import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:mobile_app/models/models.dart';

class CatchPage extends StatefulWidget {
  const CatchPage({super.key});

  @override
  State<CatchPage> createState() => _CatchPageState();
}

class _CatchPageState extends State<CatchPage> {
  final _controller = ScrollController();
  bool _showBottomBar = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
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

  var _catches = <FishingModel>[
    FishingModel(
      id: 1,
      startTime: '2025-03-13T08:00:00',
      endTime: '2025-03-13T14:00:00',
      userEmail: 'i.ivanov@example.com',
      water: WaterModel(id: 1, x: 0.1, y: 0.2),
      caughtFish: [
        CaughtFishModel(
          id: 1,
          fisher: 'i.ivanov@example.com',
          avgWeight: 3.0,
          fish: FishModel(
            id: 1,
            name: 'CARP',
            photo: 'https://example.com/carp.jpg',
          ),
        ),
      ],
    ),
    FishingModel(
      id: 2,
      userEmail: 'b.ivanov',
      startTime: '2025-03-14T09:00:00',
      endTime: '2025-03-14T15:00:00',
      caughtFish: [
        CaughtFishModel(
          id: 2,
          fisher: 'sadfasj',
          avgWeight: 2.5,
          fish: FishModel(
            id: 2,
            name: 'STURGEON',
            photo: 'https://example.com/sturgeon.jpg',
          ),
        ),
      ],
      water: WaterModel(id: 2, x: 0.3, y: 0.4),
    ),
  ];

  Future<void> _fetchCatches() async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    final box = Hive.box('settings');
    final email = box.get('email', defaultValue: '');
    try {
      final response = await http.get(
        Uri.parse('https://capstone.aquaf1na.fun/api/fishing/$email'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body.isNotEmpty
            ? (response.body as List)
            : [];
        _catches = data.map((e) => FishingModel.fromJson(e)).toList();
        debugPrint('Fetched ${_catches.length} catches');
      } else {
        throw Exception('Failed to load catches');
      }
    } catch (e) {
      debugPrint('Error fetching catches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Catch'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: _fetchCatches(),
            builder: (context, asyncSnapshot) {
              return ListView.builder(
                controller: _controller,
                itemCount: _catches.length,
                itemBuilder: (context, index) {
                  var date = _catches[index].startTime.split('T')[0];
                  if (date.isEmpty) {
                    date = 'Unknown Date';
                  }
                  return CatchItem(date: date);
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
