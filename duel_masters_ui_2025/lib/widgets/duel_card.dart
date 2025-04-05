import 'package:flutter/material.dart';

class DuelCard extends StatefulWidget {
  final String frontImage;
  final String cardName;

  DuelCard({required this.frontImage, required this.cardName});

  @override
  _DuelCardState createState() => _DuelCardState();
}

class _DuelCardState extends State<DuelCard> {
  bool revealed = false;
  bool isTapped = false;

  void _handleTap() {
    if (!revealed) {
      setState(() {
        revealed = true;
      });
    } else {
      _showOptionsDialog();
    }
  }

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.cardName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isTapped = !isTapped;
                  });
                  Navigator.pop(context);
                },
                child: Text(isTapped ? "Untap" : "Tap"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sent to mana zone")),
                  );
                },
                child: Text("Send to Mana Zone"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Attacked opponent!")),
                  );
                },
                child: Text("Attack"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardImage = revealed
        ? widget.frontImage
        : 'assets/cards/0.jpg';

    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: 200, // enough for rotated card
        height: 200,
        child: Center( // centers the rotating card
          child: AnimatedRotation(
            turns: isTapped ? 0.25 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 6)],
                image: DecorationImage(
                  image: AssetImage(cardImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
