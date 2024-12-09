import 'package:flutter/material.dart';
import 'dart:math';

class EvenSimplerCustomLoader extends StatefulWidget {
  final Color color;
  final double size;

  const EvenSimplerCustomLoader({
    super.key,
    this.color = Colors.blue,
    this.size = 25,
  });

  @override
  State<EvenSimplerCustomLoader> createState() => _EvenSimplerCustomLoaderState();
}

class _EvenSimplerCustomLoaderState extends State<EvenSimplerCustomLoader>
    with TickerProviderStateMixin {
  late Animation<double> animation1;

  late AnimationController controller1;

  @override
  void initState() {
    super.initState();
    controller1 = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);

    animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller1, curve: const Interval(0.0, 1.0, curve: Curves.bounceIn)));

    controller1.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          RotationTransition(
            turns: animation1,
            child: CustomPaint(
              painter: Arc1Painter(widget.color),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    super.dispose();
  }
}

class Arc1Painter extends CustomPainter {
  final Color color;

  Arc1Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p1 = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect1 = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    canvas.drawArc(rect1, 0.0, 0.3 * pi, false, p1);
    canvas.drawArc(rect1, 0.5 * pi, 0.3 * pi, false, p1);
    canvas.drawArc(rect1, 1.0 * pi, 0.3 * pi, false, p1);
    canvas.drawArc(rect1, 1.5 * pi, 0.3 * pi, false, p1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
