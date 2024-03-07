import 'package:flutter/material.dart';

class ToggleCountScreen extends StatelessWidget {
  final List<List<int>> toggleCount;

  ToggleCountScreen({required this.toggleCount});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Solution Matrix'),
      content: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6, // Adjust the height as needed
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: List.generate(
                toggleCount.length,
                    (index) => DataColumn(
                  label: Text(''),
                ),
              ),
              rows: List.generate(
                toggleCount.length,
                    (i) {
                      return DataRow(
                        cells: List.generate(
                          toggleCount[i].length,
                              (j) {
                            int value = toggleCount[i][j];
                            if (value != 0) {
                              value = 3 - value;
                            }
                            return DataCell(
                              Text(
                                value.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      );

                    },
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
