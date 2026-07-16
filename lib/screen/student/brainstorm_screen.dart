import 'package:flutter/material.dart';

// ---------------------------------------------------
// 1. Model สำหรับเก็บข้อมูลเส้น
// ---------------------------------------------------
class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;

  DrawnLine({required this.path, required this.color, required this.width});
}

// ---------------------------------------------------
// 2. หน้า Page หลัก (เรียกใช้ผ่าน Navigator ได้เลย)
// ---------------------------------------------------
class BrainstormPage extends StatefulWidget {
  const BrainstormPage({super.key});

  @override
  State<BrainstormPage> createState() => _BrainstormPageState();
}

class _BrainstormPageState extends State<BrainstormPage> {
  List<DrawnLine> lines = [];
  List<DrawnLine> undoHistory = [];

  DrawnLine? currentLine;
  Color selectedColor = Colors.black;
  double selectedWidth = 3.0;

  void onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    setState(() {
      currentLine = DrawnLine(
        path: [point],
        color: selectedColor,
        width: selectedWidth,
      );
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    setState(() {
      currentLine?.path.add(point);
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (currentLine != null) {
      setState(() {
        lines.add(currentLine!);
        currentLine = null;
        undoHistory.clear();
      });
    }
  }

  void undo() {
    if (lines.isNotEmpty) {
      setState(() {
        undoHistory.add(lines.removeLast());
      });
    }
  }

  void redo() {
    if (undoHistory.isNotEmpty) {
      setState(() {
        lines.add(undoHistory.removeLast());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F8F6,
      ), // สีพื้นหลังกระดาษถนอมสายตาแบบ Goodnotes
      body: SafeArea(
        child: Column(
          children: [
            _buildGoodnotesToolbar(context),
            Expanded(
              child: Stack(
                children: [
                  // เลเยอร์ 1: กระดาษลายตาราง (Grid Paper)
                  CustomPaint(size: Size.infinite, painter: GridPaperPainter()),
                  // เลเยอร์ 2: พื้นที่สำหรับวาดเขียน
                  GestureDetector(
                    onPanStart: onPanStart,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanEnd,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: DrawingPainter(
                        lines: lines,
                        currentLine: currentLine,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // 3. UI ส่วนแถบเครื่องมือ
  // ---------------------------------------------------
  Widget _buildGoodnotesToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ชื่อหน้า (เอาปุ่มย้อนกลับออก เพราะจัดการโดย AppBar ใน Dashboard)
              const Text(
                "Brainstorming",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // ปุ่มเมนูจัดการ (Undo, Redo)
              Row(
                children: [
                  IconButton(
                    onPressed: undo,
                    icon: const Icon(Icons.undo, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: redo,
                    icon: const Icon(Icons.redo, color: Colors.blue),
                  ),
                  const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.more_horiz, color: Colors.blue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // กลุ่มเครื่องมือวาด
              Row(
                children: [
                  _buildToolIcon(Icons.edit, isActive: true),
                  _buildToolIcon(Icons.phonelink_erase),
                  _buildToolIcon(Icons.border_color),
                  _buildToolIcon(Icons.category_outlined),
                  _buildToolIcon(Icons.pan_tool),
                ],
              ),
              // กลุ่มเลือกสี และขนาดเส้น
              Row(
                children: [
                  _buildColorDot(Colors.black),
                  _buildColorDot(const Color(0xFFE53935)), // สีแดงแบบนุ่มๆ
                  _buildColorDot(const Color(0xFF1E88E5)), // สีน้ำเงินแบบนุ่มๆ
                  const SizedBox(width: 16),
                  _buildStrokeWidth(2.0),
                  _buildStrokeWidth(4.0),
                  _buildStrokeWidth(6.0),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey.shade600,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.blue.shade200, width: 2)
              : null,
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrokeWidth(double width) {
    bool isSelected = selectedWidth == width;
    return GestureDetector(
      onTap: () => setState(() => selectedWidth = width),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade300 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          width: 14,
          height: width,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// 4. Custom Painters (ส่วนเครื่องยนต์การวาด)
// ---------------------------------------------------

// วาดลายตารางสมุด
class GridPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    const double step = 28.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// วาดเส้นลายมือ
class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  DrawingPainter({required this.lines, this.currentLine});

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      _drawLine(canvas, line);
    }
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (line.path.isNotEmpty) {
      path.moveTo(line.path.first.dx, line.path.first.dy);
      for (int i = 1; i < line.path.length; i++) {
        path.lineTo(line.path[i].dx, line.path[i].dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
