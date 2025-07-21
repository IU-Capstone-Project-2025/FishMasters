import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'package:mobile_app/models/models.dart';
import 'dart:convert';
import 'dart:math';

class CatchItem extends StatefulWidget {
  const CatchItem({
    super.key,
    required this.date,
    required this.duration,
    required this.fishCount,
    required this.fishNames,
    required this.caughtFish,
  });

  final String date;
  final int duration;
  final int fishCount;
  final List<String> fishNames;
  final List<CaughtFishModel> caughtFish;

  @override
  State<CatchItem> createState() => _CatchItemState();
}

class _CatchItemState extends State<CatchItem> with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late AnimationController _contentController;
  late Animation<double> _expandAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleExpansion() async {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      // Opening: expand first, then show content
      _expandController.forward();
      await Future.delayed(const Duration(milliseconds: 150));
      _contentController.forward();
    } else {
      // Closing: hide content first, then collapse
      _contentController.reverse();
      await Future.delayed(const Duration(milliseconds: 100));
      _expandController.reverse();
    }
  }

  Widget _buildFishPhoto(CaughtFishModel caughtFish) {
    if (caughtFish.photo != null && caughtFish.photo!.isNotEmpty) {
      try {
        return CircleAvatar(
          backgroundImage: MemoryImage(base64Decode(caughtFish.photo!)),
          radius: 20,
          onBackgroundImageError: (exception, stackTrace) {
            // Handle image loading error - fallback handled by parent
          },
        );
      } catch (e) {
        // If base64 decoding fails, show default icon
        return CircleAvatar(
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade600),
          radius: 20,
        );
      }
    } else {
      return CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        child: Icon(Icons.image_not_supported, color: Colors.grey.shade600),
        radius: 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(
            widget.date,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.duration == -1
                          ? Icons.radio_button_checked
                          : Icons.access_time,
                      color: widget.duration == -1 ? Colors.green : null,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.duration == -1
                          ? "Ongoing session - ${widget.fishCount} fish"
                          : "${widget.duration != 0 ? widget.duration : 'Less than an'} hour"
                                "${widget.duration < 2 ? '' : 's'} - ${widget.fishCount} fish",
                      style: TextStyle(
                        color: widget.duration == -1 ? Colors.green : null,
                        fontWeight: widget.duration == -1
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.fishNames.isEmpty)
                          const Text('No fish caught'),
                        if (widget.fishNames.isNotEmpty)
                          FishItem(
                            name: widget.fishNames[0],
                            highlighted: true,
                          ),
                        if (widget.fishNames.length > 1)
                          for (
                            var i = 1;
                            i < min(widget.fishNames.length, 3);
                            i++
                          )
                            FishItem(name: widget.fishNames[i]),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Expandable details section with staggered animation
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'All Caught Fish (${widget.caughtFish.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _contentAnimation,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: widget.caughtFish.isEmpty
                              ? SizedBox(
                                  height: 120,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.set_meal,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No fish caught yet',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.caughtFish.length,
                                  itemBuilder: (context, index) {
                                    final caughtFish = widget.caughtFish[index];

                                    // Count how many of this fish type we have
                                    final fishTypeCounts = <String, int>{};
                                    final fishTypeCurrentIndex =
                                        <String, int>{};

                                    for (
                                      int i = 0;
                                      i < widget.caughtFish.length;
                                      i++
                                    ) {
                                      final fishName =
                                          widget.caughtFish[i].fish.name;
                                      fishTypeCounts[fishName] =
                                          (fishTypeCounts[fishName] ?? 0) + 1;
                                      if (i <= index &&
                                          widget.caughtFish[i].fish.name ==
                                              caughtFish.fish.name) {
                                        fishTypeCurrentIndex[fishName] =
                                            (fishTypeCurrentIndex[fishName] ??
                                                0) +
                                            1;
                                      }
                                    }

                                    final currentFishIndex =
                                        fishTypeCurrentIndex[caughtFish
                                            .fish
                                            .name] ??
                                        1;
                                    final totalFishCount =
                                        fishTypeCounts[caughtFish.fish.name] ??
                                        1;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: ListTile(
                                        leading: _buildFishPhoto(caughtFish),
                                        title: Text(
                                          totalFishCount > 1
                                              ? '${caughtFish.fish.name} ($currentFishIndex)'
                                              : caughtFish.fish.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Weight: ${caughtFish.avgWeight.toStringAsFixed(1)} kg',
                                            ),
                                            Text(
                                              'Fisher: ${caughtFish.fisher}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.caughtFish.isNotEmpty)
                  TextButton.icon(
                    onPressed: _toggleExpansion,
                    icon: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.expand_more),
                    ),
                    label: Text(_isExpanded ? 'Show Less' : 'View Details'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
