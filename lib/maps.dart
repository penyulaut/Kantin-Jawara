import 'package:flutter/material.dart';
import 'kantin_list_page.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  void navigateToKantinList(BuildContext context, String seat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KantinListPage(seat: seat),
      ),
    );
  }

  Widget seatBox(BuildContext context, String label) {
    return GestureDetector(
      onTap: () => navigateToKantinList(context, label),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.yellow[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Kantin Jawara',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text('Dimana Tempat duduk kamu?'),
              const SizedBox(height: 20),
              SizedBox(
                height: 350,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        seatBox(context, 'A'),
                        seatBox(context, 'B'),
                        seatBox(context, 'C'),
                        seatBox(context, 'D'),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        seatBox(context, 'E'),
                        seatBox(context, 'F'),
                        seatBox(context, 'G'),
                        seatBox(context, 'H'),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotatedBox(
                          quarterTurns: 1,
                          child: Container(
                            color: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: const Text(
                              'Danau FT',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                color: Colors.blue[900],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  'Lapangan T-rex',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
