import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

void registerIframeViewFactory(String videoUrl) {
  ui.platformViewRegistry.registerViewFactory(
    'iframeElement',
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = videoUrl
        ..style.border = 'none'
        ..height = '100%'
        ..width = '100%';
      return iframe;
    },
  );
}

class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 600,
      child: HtmlElementView(viewType: 'iframeElement'),
    );
  }
}
