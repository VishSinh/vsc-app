import 'package:flutter/material.dart';

Widget buildOrderInfoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey),
      const SizedBox(width: 8),
      SizedBox(
        width: 75,
        child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ),
      Expanded(
        child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    ],
  );
}

Widget buildJobsBadges({
  required bool showBox,
  required bool showPrint,
  required bool boxMissing,
  required bool printOrTracingMissing,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (showBox)
        Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Text(
                'Box',
                style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              if (boxMissing) ...[
                const SizedBox(width: 3),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      if (showBox && showPrint) const SizedBox(width: 4),
      if (showPrint)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Text(
                'Print',
                style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              if (printOrTracingMissing) ...[
                const SizedBox(width: 3),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
    ],
  );
}
