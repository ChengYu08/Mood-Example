import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

///
import 'package:moodexample/app_theme.dart';
import 'package:moodexample/common/utils.dart';
import 'package:moodexample/widgets/empty/empty.dart';

///
import 'package:moodexample/view_models/statistic/statistic_view_model.dart';
import 'package:moodexample/services/statistic/statistic_service.dart';

/// 统计
class StatisticPage extends StatefulWidget {
  const StatisticPage({Key? key}) : super(key: key);

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage>
    with AutomaticKeepAliveClientMixin {
  /// AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// AutomaticKeepAliveClientMixin
    super.build(context);
    // 屏幕自适应 设置尺寸（填写设计中设备的屏幕尺寸）如果设计基于360dp * 690dp的屏幕
    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: const Size(AppTheme.wdp, AppTheme.hdp),
      orientation: Orientation.landscape,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(
        child: StatisticBody(),
      ),
    );
  }
}

/// 初始化
init(BuildContext context) {
  StatisticViewModel _statisticViewModel =
      Provider.of<StatisticViewModel>(context, listen: false);

  /// 统计的天数
  final int _moodDays = _statisticViewModel.moodDays;

  /// 统计-APP累计使用天数
  StatisticService.getAPPUsageDays(_statisticViewModel);

  /// 统计-APP累计记录条数
  StatisticService.getAPPMoodCount(_statisticViewModel);

  /// 统计-平均情绪波动
  StatisticService.getMoodScoreAverage(_statisticViewModel);

  /// 统计-近日情绪波动
  StatisticService.getMoodScoreAverageRecently(_statisticViewModel,
      days: _moodDays);

  /// 统计-近日心情数量统计
  StatisticService.getDateMoodCount(_statisticViewModel, days: _moodDays);
}

class StatisticBody extends StatefulWidget {
  const StatisticBody({Key? key}) : super(key: key);

  @override
  _StatisticBodyState createState() => _StatisticBodyState();
}

class _StatisticBodyState extends State<StatisticBody> {
  late int _filterValue = 7;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      primary: false,
      shrinkWrap: false,
      slivers: [
        SliverAppBar(
          pinned: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Align(
            child: Container(
              margin: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "统计",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      FilterBottom(
                        "7日",
                        checked: _filterValue == 7,
                        onTap: () {
                          if (_filterValue == 7) return;
                          setState(() {
                            _filterValue = 7;
                          });
                          Provider.of<StatisticViewModel>(context,
                                  listen: false)
                              .setMoodDays(7);
                          init(context);
                        },
                      ),
                      FilterBottom(
                        "15日",
                        checked: _filterValue == 15,
                        onTap: () {
                          if (_filterValue == 15) return;
                          setState(() {
                            _filterValue = 15;
                          });
                          Provider.of<StatisticViewModel>(context,
                                  listen: false)
                              .setMoodDays(15);
                          init(context);
                        },
                      ),
                      FilterBottom(
                        "30日",
                        checked: _filterValue == 30,
                        onTap: () {
                          if (_filterValue == 30) return;
                          setState(() {
                            _filterValue = 30;
                          });
                          Provider.of<StatisticViewModel>(context,
                                  listen: false)
                              .setMoodDays(30);
                          init(context);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          collapsedHeight: 100.w,
          expandedHeight: 100.w,
        ),

        /// 下拉加载
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            print("下拉刷新");
            vibrate();
            init(context);
          },
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: EdgeInsets.only(top: 0.w, bottom: 48.h),
                child: Column(
                  children: [
                    /// 总体统计
                    const OverallStatistics(),

                    /// 情绪波动（线）
                    Padding(
                      padding: EdgeInsets.only(
                        top: 12.w,
                        left: 24.w,
                        right: 24.w,
                      ),
                      child: const StatisticMoodLine(),
                    ),

                    /// 情绪波动
                    Padding(
                      padding: EdgeInsets.only(
                        top: 12.w,
                        left: 24.w,
                        right: 24.w,
                      ),
                      child: Consumer<StatisticViewModel>(
                        builder: (_, statisticViewModel, child) {
                          return StatisticLayout(
                            title: "情绪波动",
                            subTitle: "近${statisticViewModel.moodDays}日情绪波动",
                            height: 180.w,
                            statistic: const StatisticWeekMood(),
                          );
                        },
                      ),
                    ),

                    /// 心情统计
                    Padding(
                      padding: EdgeInsets.only(
                        top: 12.w,
                        left: 24.w,
                        right: 24.w,
                      ),
                      child: Consumer<StatisticViewModel>(
                        builder: (_, statisticViewModel, child) {
                          return StatisticLayout(
                            title: "心情统计",
                            subTitle: "近${statisticViewModel.moodDays}日心情数量统计",
                            height: 320.w,
                            statistic: const StatisticCategoryMood(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }
}

/// 统计-情绪波动（线）
class StatisticMoodLine extends StatefulWidget {
  const StatisticMoodLine({Key? key}) : super(key: key);

  @override
  _StatisticMoodLineState createState() => _StatisticMoodLineState();
}

class _StatisticMoodLineState extends State<StatisticMoodLine> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticViewModel>(
      builder: (_, statisticViewModel, child) {
        /// 获取数据 计算近日平均
        List<Map<String, dynamic>> _listData =
            statisticViewModel.moodScoreAverageRecently;
        double moodScoreAverage = 0;
        double moodScoreSum = 0;
        for (int i = 0; i < _listData.length; i++) {
          moodScoreSum += _listData[i]["score"];
        }
        moodScoreAverage = double.parse(
            (moodScoreSum / statisticViewModel.moodDays).toStringAsFixed(1));
        return StatisticLayout(
          title: "平均" + moodScoreAverage.toString(),
          subTitle: "按${statisticViewModel.moodDays}日计算情绪波动",
          height: 240.w,
          statistic: const StatisticWeekMoodLine(),
        );
      },
    );
  }
}

/// 周情绪波动统计（线）-数据
class StatisticWeekMoodLine extends StatefulWidget {
  const StatisticWeekMoodLine({Key? key}) : super(key: key);

  @override
  _StatisticWeekMoodLineState createState() => _StatisticWeekMoodLineState();
}

class _StatisticWeekMoodLineState extends State<StatisticWeekMoodLine> {
  List<Color> gradientColors = [
    AppTheme.primaryColor.withOpacity(0.1),
    AppTheme.primaryColor.withOpacity(0.4),
    AppTheme.primaryColor.withOpacity(0.6),
    AppTheme.primaryColor,
    AppTheme.primaryColor,
    AppTheme.primaryColor,
    AppTheme.primaryColor,
    AppTheme.primaryColor,
    AppTheme.primaryColor.withOpacity(0.6),
    AppTheme.primaryColor.withOpacity(0.4),
    AppTheme.primaryColor.withOpacity(0.1),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticViewModel>(
      builder: (_, statisticViewModel, child) {
        /// 获取数据
        late List<Map<String, dynamic>> _listData =
            statisticViewModel.moodScoreAverageRecently;

        /// 统计的天数
        final int _moodDays = statisticViewModel.moodDays;

        /// 数据数量
        final int _moodCount = _listData.length;

        /// 数据是否为空
        final bool _moodEmpty = _listData.isEmpty;

        /// 启用的数据数量（如果数据为空则启用固定天数）
        final int _days = _moodEmpty ? _moodDays : _moodCount;

        /// 数据为空的占位
        if (_moodEmpty) {
          _listData = List.generate((_days), (i) {
            return {
              "datetime": "",
              "score": 0,
            };
          });
        }

        /// 为了数据效果展示首尾填充占位数据
        List<Map<String, dynamic>> _listFlSpot = [
          {"datetime": "", "score": _listData.first["score"]},
          ..._listData,
          {"datetime": "", "score": _listData.last["score"]},
        ];

        ///
        return LineChart(
          LineChartData(
            clipData: FlClipData.vertical(),
            maxX: (_days + 1),
            minY: -50,
            maxY: 120,
            lineBarsData: [
              LineChartBarData(
                spots: List<FlSpot>.generate(_listFlSpot.length, (i) {
                  return FlSpot(
                    double.parse((i).toString()),
                    double.parse(_listFlSpot[i]["score"].toString()),
                  );
                }),
                isCurved: true,
                curveSmoothness: 0.4,
                preventCurveOverShooting: true,
                colors: gradientColors,
                barWidth: 2.sp,
                // shadow: Shadow(
                //   color: AppTheme.primaryColor.withOpacity(0.4),
                //   blurRadius: 4,
                //   offset: Offset.fromDirection(0, 0),
                // ),
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradientTo: Offset.fromDirection(1.56, 1.8),
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    Colors.white,
                    Colors.white,
                  ],
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                tooltipRoundedRadius: 24.sp,
                tooltipMargin: 24.w,
                tooltipBgColor: AppTheme.primaryColor,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final flSpot = barSpot;
                    final i = flSpot.x.toInt();
                    if (i == 0 || i == (_days + 1)) {
                      return null;
                    }
                    return LineTooltipItem(
                      "",
                      const TextStyle(),
                      children: [
                        TextSpan(
                          text: _listFlSpot[i]["score"].toString() + " ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: (_listFlSpot[i]["datetime"].toString() != ""
                              ? _listFlSpot[i]["datetime"]
                                  .toString()
                                  .substring(5, 10)
                              : ""),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.black.withOpacity(0.1),
                  strokeWidth: 0.6,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.black12,
                  strokeWidth: 0,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: SideTitles(showTitles: false),
              rightTitles: SideTitles(showTitles: false),
              topTitles: SideTitles(showTitles: false),
              bottomTitles: SideTitles(
                showTitles: true,
                reservedSize: 12.w,
                interval: _days > 7 ? ((_days / 7) + 1) : (_days / 7),
                getTextStyles: (context, value) {
                  return TextStyle(
                    color: AppTheme.subColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 12.sp,
                  );
                },
                getTitles: (index) {
                  final _nowListDate = _listFlSpot[(index).toInt()]['datetime'];
                  return (_nowListDate.toString() != ""
                      ? _nowListDate.toString().substring(8, 10) + "日"
                      : "");
                },
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
                width: 0.2,
              ),
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 450),
          swapAnimationCurve: Curves.linearToEaseOut,
        );
      },
    );
  }
}

/// 总体统计
class OverallStatistics extends StatelessWidget {
  const OverallStatistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164.w,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 24.w,
              left: 24.w,
              right: 24.w,
            ),
            child: Consumer<StatisticViewModel>(
              builder: (_, statisticViewModel, child) {
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 0.w,
                  children: [
                    StatisticsCard(
                      icon: Remix.time_line,
                      title: "${statisticViewModel.daysCount}天",
                      subTitle: "累计记录天数",
                    ),
                    StatisticsCard(
                      icon: Remix.file_list_2_line,
                      title: "${statisticViewModel.moodCount}条",
                      subTitle: "累计记录心情",
                    ),
                    StatisticsCard(
                      icon: Remix.pulse_line,
                      title: "${statisticViewModel.moodScoreAverage}",
                      subTitle: "平均全部波动",
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 周情绪波动统计-数据
class StatisticWeekMood extends StatefulWidget {
  const StatisticWeekMood({Key? key}) : super(key: key);

  @override
  _StatisticWeekMoodState createState() => _StatisticWeekMoodState();
}

class _StatisticWeekMoodState extends State<StatisticWeekMood> {
  /// 当前选择的下标
  late int _touchedIndex = -1;

  /// 每条数据
  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    List<int> showTooltips = const [],
    double? width,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          colors: isTouched
              ? [
                  AppTheme.primaryColor.withOpacity(0.4),
                  AppTheme.primaryColor,
                ]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.4),
                ],
          width: width ?? 14.w,
          borderRadius: BorderRadius.circular(14.w),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            colors: [
              AppTheme.backgroundColor1,
            ],
            y: 100,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticViewModel>(
      builder: (_, statisticViewModel, child) {
        /// 获取数据
        List<Map<String, dynamic>> _listData =
            statisticViewModel.moodScoreAverageRecently;

        /// 统计的天数
        final int _moodDays = statisticViewModel.moodDays;

        /// 数据为空的占位
        if (_listData.isEmpty) {
          _listData = List.generate(_moodDays, (i) {
            return {
              "datetime": "---------- --------",
              "score": 0,
            };
          });
        }

        /// 根据数据适应每条数据宽度
        late double _barWidth = 14.w;
        switch (_moodDays) {
          case 7:
            _barWidth = 14.w;
            break;
          case 15:
            _barWidth = 10.w;
            break;
          case 30:
            _barWidth = 4.w;
            break;
          default:
            _barWidth = 14.w;
            break;
        }

        ///
        return BarChart(
          BarChartData(
            barGroups: List<BarChartGroupData>.generate(_listData.length, (i) {
              return makeGroupData(
                i,
                double.parse(_listData[i]['score'].toString()),
                isTouched: i == _touchedIndex,
                width: _barWidth,
              );
            }),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 12.sp,
                tooltipBgColor: AppTheme.primaryColor,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    "",
                    const TextStyle(),
                    children: [
                      TextSpan(
                        text: (rod.y).toString() + "\n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: (_listData[group.x]['datetime'].toString() != ""
                            ? _listData[group.x]['datetime']
                                .toString()
                                .substring(5, 10)
                            : ""),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                });
              },
            ),
            maxY: 100,
            titlesData: FlTitlesData(
              topTitles: SideTitles(showTitles: false),
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (index) {
                  return "";
                },
                getTextStyles: (_, value) {
                  return TextStyle(fontSize: 12.sp);
                },
              ),
              leftTitles: SideTitles(showTitles: false),
              rightTitles: SideTitles(showTitles: false),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
          swapAnimationDuration: const Duration(milliseconds: 1000), // Optional
          swapAnimationCurve: Curves.linearToEaseOut, // Optional
        );
      },
    );
  }
}

/// 心情统计-数据
class StatisticCategoryMood extends StatefulWidget {
  const StatisticCategoryMood({Key? key}) : super(key: key);

  @override
  _StatisticCategoryMoodState createState() => _StatisticCategoryMoodState();
}

class _StatisticCategoryMoodState extends State<StatisticCategoryMood> {
  /// 当前选择的下标
  late int _touchedIndex = -1;

  /// 每条数据
  PieChartSectionData makeSectionData(
    double? value, {
    String? title,
    double? radius,
    double? fontSize,
    Color? color,
    double? badgeFontSize,
    double? badgeWidth,
    double? badgeHeight,
  }) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: value?.toInt().toString(),
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: AnimatedContainer(
        duration: PieChart.defaultDuration,
        width: badgeWidth,
        height: badgeHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2),
              offset: const Offset(0, 0),
              blurRadius: 4,
            ),
          ],
        ),
        padding: EdgeInsets.all(1.w),
        child: Center(
          child: Text(
            title ?? '',
            style: TextStyle(
              fontSize: badgeFontSize,
            ),
          ),
        ),
      ),
      badgePositionPercentageOffset: 0.9.w,
      titlePositionPercentageOffset: 0.6.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticViewModel>(
      builder: (_, statisticViewModel, child) {
        late List _listData = [];

        /// 获取数据
        _listData = statisticViewModel.dateMoodCount;

        /// 空占位
        if (_listData.isEmpty) {
          return Empty(
            padding: EdgeInsets.only(top: 48.w),
            width: 120.w,
            height: 100.w,
          );
        }

        return PieChart(
          PieChartData(
            sections: List<PieChartSectionData>.generate(_listData.length, (i) {
              /// 数据
              final _item = _listData[i];

              /// 样式
              final isTouched = i == _touchedIndex;
              final fontSize = isTouched ? 20.sp : 14.sp;
              final radius = isTouched ? 120.w : 100.w;

              return makeSectionData(
                double.parse(_item['count'].toString()),
                title: _item['icon'],
                radius: radius,
                fontSize: fontSize,
                color: statisticColors[i],
                badgeFontSize: 16.sp,
                badgeHeight: 28.w,
                badgeWidth: 28.w,
              );
            }),
            pieTouchData: PieTouchData(
              /// 触摸回调
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  /// 赋值当前触摸项
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
          ),

          swapAnimationDuration: const Duration(milliseconds: 250), // Optional
          swapAnimationCurve: Curves.linearToEaseOut, // Optional
        );
      },
    );
  }
}

/// 统计Card
class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subTitle,
  }) : super(key: key);

  /// Icon
  final IconData icon;

  /// 标题内容
  final String title;

  /// 副标题
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
      color: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 72.w,
          minHeight: 110.w,
        ),
        margin: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
          top: 12.w,
          bottom: 12.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black],
                ),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 36.w,
                height: 36.w,
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 20.w,
                bottom: 10.w,
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Text(
              subTitle,
              style: TextStyle(
                color: AppTheme.subColor,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 统计-布局
class StatisticLayout extends StatelessWidget {
  const StatisticLayout({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.height,
    required this.statistic,
  }) : super(key: key);

  /// 标题
  final String title;

  /// 副标题
  final String subTitle;

  /// 高度
  final double height;

  /// 统计图
  final Widget statistic;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
      color: Colors.white,
      child: Container(
        height: height,
        margin: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 24.w,
          bottom: 24.w,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4.w,
                ),
                Text(
                  subTitle,
                  style: TextStyle(
                    color: AppTheme.subColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(
                  height: 38.w,
                ),
                Expanded(
                  child: statistic,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 筛选选择项
class FilterBottom extends StatelessWidget {
  const FilterBottom(
    this.text, {
    Key? key,
    required this.checked,
    this.onTap,
  }) : super(key: key);

  /// 是否选中
  final bool checked;

  /// 内容
  final String text;

  /// onTap
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = AppTheme.primaryColor;
    return InkWell(
      child: Container(
        width: 40.w,
        height: 40.w,
        margin: EdgeInsets.only(left: 6.w, right: 6.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: checked
                ? [
                    primaryColor,
                    primaryColor,
                  ]
                : [
                    Colors.white,
                    Colors.white,
                  ],
          ),
          borderRadius: BorderRadius.circular(14.sp),
          boxShadow: checked
              ? [
                  BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 6)
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02), blurRadius: 6)
                ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: checked ? Colors.white : Colors.black87,
            fontSize: 12.sp,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}