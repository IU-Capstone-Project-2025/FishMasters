import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

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

  //

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
        // TODO: Parse the response and update the UI
      } else {
        throw Exception('Failed to load catches');
      }
    } catch (e) {
      // Handle error
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
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  return CatchItem(date: dates[index]);
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
