import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:valet_mobile_app/views/business/statistics/statistics_controller.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({Key? key}) : super(key: key);

  // Blue theme colors
  static const Color primaryBlue = Color(0xFF1A73E8);
  static const Color lightBlue = Color(0xFFE8F0FE);
  static const Color mediumBlue = Color(0xFF4285F4);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF34A853);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatisticsController>(
      init: StatisticsController(),
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        appBar: AppBar(
          title: const Text(
            'Statistics',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryBlue,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                controller.fetchAllStatistics();
                Get.snackbar(
                  'Refreshing',
                  'Statistics are being updated...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: mediumBlue,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailyVisitsCard(),
                  const SizedBox(height: 20),
                  _buildPeakHoursCard(),
                  const SizedBox(height: 20),
                  _buildPeakDaysCard(),
                  const SizedBox(height: 20),
                  _buildMoneyGainedCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyVisitsCard() {
    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, lightBlue],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.getDailyVisitsTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.calendar_today, color: primaryBlue),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: Get.context!,
                          initialDate: controller.selectedDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: primaryBlue,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          controller.onDateChanged(picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              controller.isLoadingDailyVisits.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    )
                  : TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Center(
                              child: Text(
                                '${controller.dailyVisits.value}',
                                style: TextStyle(
                                  fontSize: 70 * value,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: primaryBlue.withOpacity(0.3),
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  'Visits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPeakHoursCard() {
    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, lightBlue],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hourly Visit Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              controller.isLoadingPeakHours.value || controller.isLoadingVisitCountByHours.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    )
                  : controller.peakHours.isEmpty && controller.visitCountByHours.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 48,
                                  color: primaryBlue.withOpacity(0.5),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'No hourly visit data available yet',
                                  style: TextStyle(
                                    color: Color(0xFF5F6368),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 240,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _calculateMaxY(),
                              minY: 0,
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: _calculateGridInterval(),
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: const Color(0xFFE0E0E0),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value % 6 == 0 || value == 23) {
                                        // Show only 0, 6, 12, 18, 23 hours
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            controller.formatHour(value.toInt()),
                                            style: const TextStyle(
                                              color: Color(0xFF5F6368),
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: _calculateGridInterval(),
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0) return const SizedBox.shrink();

                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF5F6368),
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: controller.barGroups,
                            ),
                            swapAnimationDuration: const Duration(milliseconds: 500),
                          ),
                        ),
              const SizedBox(height: 20),
              const Text(
                'Peak Hours:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: controller.peakHours
                    .map((hour) => Chip(
                          label: Text('${hour}:00'),
                          backgroundColor: primaryBlue.withOpacity(0.1),
                          side: const BorderSide(color: primaryBlue, width: 0.5),
                          labelStyle: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  double _calculateMaxY() {
    double maxValue = 10.0; // Default for peak hours

    if (controller.visitCountByHours.isNotEmpty) {
      final maxVisit = controller.visitCountByHours.values.reduce((max, value) => max > value ? max : value).toDouble();
      maxValue = maxVisit > maxValue ? maxVisit : maxValue;
    }

    // Round up to next multiple of 5 for cleaner grid
    return ((maxValue / 5).ceil() * 5).toDouble();
  }

  double _calculateGridInterval() {
    final maxY = _calculateMaxY();
    // Aim for 4-5 grid lines
    return (maxY / 5).ceilToDouble();
  }

  Widget _buildPeakDaysCard() {
    final Map<String, IconData> dayIcons = {
      'Monday': Icons.looks_one,
      'Tuesday': Icons.looks_two,
      'Wednesday': Icons.looks_3,
      'Thursday': Icons.looks_4,
      'Friday': Icons.looks_5,
      'Saturday': Icons.looks_6,
      'Sunday': Icons.calendar_today,
    };

    final Map<String, String> dayTranslations = {
      'Monday': 'Monday',
      'Tuesday': 'Tuesday',
      'Wednesday': 'Wednesday',
      'Thursday': 'Thursday',
      'Friday': 'Friday',
      'Saturday': 'Saturday',
      'Sunday': 'Sunday',
    };

    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, lightBlue],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Peak Days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              controller.isLoadingPeakDays.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    )
                  : controller.peakDays.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 48,
                                  color: primaryBlue.withOpacity(0.5),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'No peak day data found',
                                  style: TextStyle(
                                    color: Color(0xFF5F6368),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => Divider(
                            color: primaryBlue.withOpacity(0.1),
                            height: 1,
                          ),
                          itemCount: controller.peakDays.length,
                          itemBuilder: (context, index) {
                            final day = controller.peakDays[index];
                            final translatedDay = dayTranslations[day] ?? day;
                            final icon = dayIcons[day] ?? Icons.calendar_today;

                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(50 * (1 - value), 0),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: primaryBlue.withOpacity(0.1),
                                          child: Icon(icon, color: primaryBlue),
                                        ),
                                        title: Text(
                                          translatedDay,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: darkBlue,
                                          ),
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: accentColor.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.trending_up,
                                                color: accentColor,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Peak',
                                                style: TextStyle(
                                                  color: accentColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMoneyGainedCard() {
    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, lightBlue],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.getMoneyGainedTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.date_range, color: primaryBlue),
                      onPressed: () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: Get.context!,
                          initialDateRange: DateTimeRange(
                            start: controller.startDate.value,
                            end: controller.endDate.value,
                          ),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: primaryBlue,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          controller.onDateRangeChanged(picked.start, picked.end);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              controller.isLoadingMoneyGained.value
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    )
                  : TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Center(
                              child: Text(
                                controller.getMoneyGainedAmount(),
                                style: TextStyle(
                                  fontSize: 40 * value,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: accentColor.withOpacity(0.3),
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  'Total Income',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
