import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

enum IndicatorPosition { topLeft, topRight, bottomLeft, bottomRight }

class PDFViewer extends StatefulWidget {
  final PDFDocument document;
  final Color indicatorText;
  final Color indicatorBackground;
  final IndicatorPosition indicatorPosition;
  final bool showIndicator;
  final bool enableSwipeNavigation;
  final Axis scrollDirection;
  final int zoomSteps;
  final double minScale;
  final double maxScale;
  final double panLimit;

  PDFViewer({
    Key key,
    @required this.document,
    this.scrollDirection,
    this.indicatorText = Colors.white,
    this.indicatorBackground = Colors.black54,
    this.showIndicator = true,
    this.enableSwipeNavigation = true,
    this.indicatorPosition = IndicatorPosition.topRight,
    this.zoomSteps,
    this.minScale,
    this.maxScale,
    this.panLimit,
  }) : super(key: key);

  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  bool _isLoading = true;
  int _pageNumber;
  bool _swipeEnabled = true;
  List<PDFPage> _pages;
  PageController _pageController;
  final Duration animationDuration = Duration(milliseconds: 200);
  final Curve animationCurve = Curves.easeIn;

  @override
  void initState() {
    super.initState();
    _pages = List(widget.document.count);
    _pageController = PageController();
    _pageNumber = _pageController.initialPage + 1;
    widget.document.preloadPages(
      onZoomChanged: onZoomChanged,
      zoomSteps: widget.zoomSteps,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      panLimit: widget.panLimit,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageNumber = _pageController.initialPage + 1;
    _isLoading = true;
    _pages = List(widget.document.count);
    // _loadAllPages();
    _loadPage();
  }

  @override
  void didUpdateWidget(PDFViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  onZoomChanged(double scale) {
    if (scale != 1.0) {
      setState(() {
        _swipeEnabled = false;
      });
    } else {
      setState(() {
        _swipeEnabled = true;
      });
    }
  }

  _loadPage() async {
    if (_pages[_pageNumber - 1] != null) return;
    setState(() {
      _isLoading = true;
    });
    final data = await widget.document.get(
      page: _pageNumber,
      onZoomChanged: onZoomChanged,
      zoomSteps: widget.zoomSteps,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      panLimit: widget.panLimit,
    );
    _pages[_pageNumber - 1] = data;
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            physics: _swipeEnabled && widget.enableSwipeNavigation
                ? null
                : NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              setState(() {
                _pageNumber = page + 1;
              });
              _loadPage();
            },
            scrollDirection: widget.scrollDirection ?? Axis.horizontal,
            controller: _pageController,
            itemCount: _pages?.length ?? 0,
            itemBuilder: (context, index) => _pages[index] == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _pages[index],
          ),
        ],
      ),
    );
  }
}
