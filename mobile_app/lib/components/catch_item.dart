import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'package:mobile_app/models/models.dart';
import 'dart:convert';
import 'dart:math';
import 'package:mobile_app/l10n/app_localizations.dart';

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
          radius: 20,
          child: Icon(Icons.image_not_supported, color: Colors.grey.shade600),
        );
      }
    } else {
      return CircleAvatar(
        backgroundColor: Colors.grey.shade300,
        radius: 20,
        child: Icon(Icons.image_not_supported, color: Colors.grey.shade600),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var colorTheme = Theme.of(context).colorScheme;
    var localizations = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Date header with new design
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
            topLeft: Radius.circular(19),
            topRight: Radius.circular(19),
          ),
          child: Container(
            width: double.infinity,
            height: 32,
            decoration: BoxDecoration(
              color: colorTheme.secondary,
              border: Border(
                top: BorderSide(color: colorTheme.outline, width: 1.0),
                left: BorderSide(color: colorTheme.outline, width: 1.0),
                right: BorderSide(color: colorTheme.outline, width: 1.0),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: Text(
                widget.date,
                textAlign: TextAlign.center,
                style: textTheme.labelLarge?.copyWith(
                  color: colorTheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Main content container with new design
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorTheme.surface,
            border: Border.all(color: colorTheme.outline, width: 1.0),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Duration and fish count section
                Row(
                  children: [
                    Icon(
                      widget.duration == -1
                          ? Icons.radio_button_checked
                          : Icons.access_time,
                      color: widget.duration == -1
                          ? Colors.green
                          : colorTheme.onSurface,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.duration == -1
                          ? "${localizations?.ongoingSession} - ${widget.fishCount} ${localizations?.fishNameLabel}"
                          : "${widget.duration != 0 ? widget.duration : localizations?.lessThan} ${localizations?.hour}"
                                "${widget.duration < 2 ? '' : 's'} - ${widget.fishCount} ${localizations?.fishNameLabel}",
                      style: textTheme.titleMedium?.copyWith(
                        letterSpacing: 0.1,
                        color: widget.duration == -1
                            ? Colors.green
                            : colorTheme.onSurface,
                        fontWeight: widget.duration == -1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Fish list section
                if (widget.fishNames.isNotEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FishItem(name: widget.fishNames[0], highlighted: true),
                        if (widget.fishNames.length > 1)
                          for (
                            var i = 1;
                            i < min(widget.fishNames.length, 3);
                            i++
                          )
                            FishItem(name: widget.fishNames[i]),
                      ],
                    ),
                  ),
                if (widget.fishNames.isEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                    child: Text(
                      localizations!.noFishCaught,
                      style: textTheme.bodyLarge?.copyWith(
                        letterSpacing: 0.1,
                        color: colorTheme.onSurface,
                      ),
                    ),
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
                        '${localizations!.allCaughtFish} (${widget.caughtFish.length})',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
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
                                          localizations.noFishCaughtYet,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey.shade600,
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
                                          widget.caughtFish[i].fishName;
                                      fishTypeCounts[fishName] =
                                          (fishTypeCounts[fishName] ?? 0) + 1;
                                      if (i <= index &&
                                          widget.caughtFish[i].fishName ==
                                              caughtFish.fishName) {
                                        fishTypeCurrentIndex[fishName] =
                                            (fishTypeCurrentIndex[fishName] ??
                                                0) +
                                            1;
                                      }
                                    }

                                    final currentFishIndex =
                                        fishTypeCurrentIndex[caughtFish
                                            .fishName] ??
                                        1;
                                    final totalFishCount =
                                        fishTypeCounts[caughtFish.fishName] ??
                                        1;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: ListTile(
                                        leading: _buildFishPhoto(caughtFish),
                                        title: Text(
                                          totalFishCount > 1
                                              ? '${caughtFish.fishName} ($currentFishIndex)'
                                              : caughtFish.fishName,
                                          style: textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${localizations.weight}: ${caughtFish.avgWeight.toStringAsFixed(1)} ${localizations.kg}',
                                              style: textTheme.labelLarge,
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
                  Center(
                    child: TextButton.icon(
                      onPressed: _toggleExpansion,
                      icon: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: colorTheme.onPrimary,
                        ),
                      ),
                      label: Text(
                        _isExpanded
                            ? localizations.showLess
                            : localizations.viewDetails,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorTheme.onPrimary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colorTheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
