library convex_bottom_navigation;

import 'package:convex_bottom_navigation/internal/tab_item.dart';
import 'package:convex_bottom_navigation/paint/half_clipper.dart';
import 'package:convex_bottom_navigation/paint/half_painter.dart';
import 'package:flutter/material.dart';

const double CIRCLE_SIZE = 60;
const double ARC_HEIGHT = 70;
const double ARC_WIDTH = 90;
const double CIRCLE_OUTLINE = 10;
const double SHADOW_ALLOWANCE = 20;
const double BAR_HEIGHT = 60;

/// Class ConvexBottomNavigation
/// Can be used when you need to create convex items of bottom menu
/// Recommended for material 2.0
class ConvexBottomNavigation extends StatefulWidget {
  ///Constructor
  ///Requires [tabs] (can not be null) and [onTabChangedListener] (can not be null)
  ///[tabs] count should be in range of [2..4]
  ///You can customize [circleColor], [activeIconColor], [inactiveIconColor], [textColor], [barBackgroundColor],
  ///[smallIconPadding], [bigIconPadding] and [initialSelection]
  ConvexBottomNavigation(
      {@required this.tabs,
      @required this.onTabChangedListener,
      this.key,
      this.initialSelection = 0,
      this.circleColor,
      this.activeIconColor,
      this.inactiveIconColor,
      this.textColor,
      this.barBackgroundColor,
      this.smallIconPadding,
      this.bigIconPadding})
      : assert(onTabChangedListener != null),
        assert(tabs != null),
        assert(tabs.length > 1 && tabs.length < 5);

  final Function(int position) onTabChangedListener;
  final Color circleColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color textColor;
  final Color barBackgroundColor;
  final List<TabData> tabs;
  final int initialSelection;
  final double smallIconPadding;
  final double bigIconPadding;
  final Key key;

  @override
  ConvexBottomNavigationState createState() => ConvexBottomNavigationState();
}

///Class ConvexBottomNavigationState
///It controls the ConvexBottomNavigation state
class ConvexBottomNavigationState extends State<ConvexBottomNavigation>
    with TickerProviderStateMixin, RouteAware {
  Widget nextIcon = Icon(Icons.home);
  Widget activeIcon = Icon(Icons.menu);

  int currentSelected = 0;
  double _circleAlignX = 0;
  double _circleIconAlpha = 1;

  Color circleColor;
  Color activeIconColor;
  Color inactiveIconColor;
  Color barBackgroundColor;
  Color textColor;

  double smallIconPadding;
  double bigIconPadding;


  /// There are default values in this method
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    activeIcon = widget.tabs[currentSelected].icon;

    circleColor ??= (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : Theme.of(context).primaryColor;

    activeIconColor ??= (Theme.of(context).brightness == Brightness.dark)
        ? Colors.black54
        : Colors.white;

    barBackgroundColor ??= (Theme.of(context).brightness == Brightness.dark)
        ? Color(0xFF212121)
        : Colors.white;
    textColor ??= (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : Colors.black54;
    inactiveIconColor ??= (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : Theme.of(context).primaryColor;

    smallIconPadding ??= 6.0;
    bigIconPadding ??= 5.0;
  }

  @override
  void initState() {
    super.initState();
    _setSelected(widget.tabs[widget.initialSelection].key);
  }

  _setSelected(UniqueKey key) {
    int selected = widget.tabs.indexWhere((tabData) => tabData.key == key);

    if (mounted) {
      setState(() {
        currentSelected = selected;
        _circleAlignX = -1 + (2 / (widget.tabs.length - 1) * selected);
        nextIcon = widget.tabs[selected].icon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          height: BAR_HEIGHT,
          decoration: BoxDecoration(color: barBackgroundColor, boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(0, -1), blurRadius: 8)
          ]),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.tabs
                .map((t) => TabItem(
                    uniqueKey: t.key,
                    selected: t.key == widget.tabs[currentSelected].key,
                    icon: t.icon,
                    title: t.title,
                    activeIconColor: activeIconColor,
                    inactiveIconColor: inactiveIconColor,
                    textColor: textColor,
                    iconPadding: smallIconPadding,
                    callbackFunction: (uniqueKey) {
                      int selected = widget.tabs
                          .indexWhere((tabData) => tabData.key == uniqueKey);
                      widget.onTabChangedListener(selected);
                      _setSelected(uniqueKey);
                      _initAnimationAndStart(_circleAlignX, 1);
                    }))
                .toList(),
          ),
        ),
        Positioned.fill(
          top: -(CIRCLE_SIZE + CIRCLE_OUTLINE + SHADOW_ALLOWANCE) / 2,
          child: Container(
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeOut,
              alignment: Alignment(_circleAlignX, 1),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: FractionallySizedBox(
                  widthFactor: 1 / widget.tabs.length,
                  child: GestureDetector(
                    onTap: widget.tabs[currentSelected].onclick,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height:
                              CIRCLE_SIZE + CIRCLE_OUTLINE + SHADOW_ALLOWANCE,
                          width:
                              CIRCLE_SIZE + CIRCLE_OUTLINE + SHADOW_ALLOWANCE,
                          child: ClipRect(
                              clipper: HalfClipper(),
                              child: Container(
                                child: Center(
                                  child: Container(
                                      width: CIRCLE_SIZE + CIRCLE_OUTLINE,
                                      height: CIRCLE_SIZE + CIRCLE_OUTLINE,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 8)
                                          ])),
                                ),
                              )),
                        ),
                        SizedBox(
                            height: ARC_HEIGHT,
                            width: ARC_WIDTH,
                            child: CustomPaint(
                              painter: HalfPainter(barBackgroundColor),
                            )),
                        SizedBox(
                          height: CIRCLE_SIZE,
                          width: CIRCLE_SIZE,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: circleColor),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: AnimatedOpacity(
                                  duration: Duration(
                                      milliseconds: ANIM_DURATION ~/ 5),
                                  opacity: _circleIconAlpha,
                                  child: Padding(
                                    padding: EdgeInsets.all(bigIconPadding),
                                    child: activeIcon,
                                  )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _initAnimationAndStart(double from, double to) {
    _circleIconAlpha = 0;

    Future.delayed(Duration(milliseconds: ANIM_DURATION ~/ 5), () {
      setState(() {
        activeIcon = nextIcon;
      });
    }).then((_) {
      Future.delayed(Duration(milliseconds: (ANIM_DURATION ~/ 5 * 3)), () {
        setState(() {
          _circleIconAlpha = 1;
        });
      });
    });
  }

  void setPage(int page) {
    widget.onTabChangedListener(page);
    _setSelected(widget.tabs[page].key);
    _initAnimationAndStart(_circleAlignX, 1);

    setState(() {
      currentSelected = page;
    });
  }
}


/// Class for setting tabs info
class TabData {
  /// Constructor
  /// Requires [icon], [title]
  /// Also you can set onClick method
  TabData({@required this.icon, @required this.title, this.onclick});

  Widget icon;
  String title;
  Function onclick;
  final UniqueKey key = UniqueKey();
}