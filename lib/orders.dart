import 'package:flutter/material.dart';

import '../shared/services/firebase_helper.dart';

class Orders extends StatefulWidget {
  final String title;
  final String subTitle;
  const Orders({super.key, required this.title, required this.subTitle});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    final FirebaseHelper _firebaseHelper = FirebaseHelper();
    ColorScheme color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color.onPrimary,
                ),
              ),
              Text(
                widget.subTitle,
                style: TextStyle(
                  fontSize: 14,
                  color: color.onPrimary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),

                    //Tabel Data
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth - 100),
                                child: StreamBuilder(
                                  stream: _firebaseHelper
                                      .getCollection(collection: 'orders')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    var docs = snapshot.data?.docs ?? [];

                                    return DataTable(
                                      columnSpacing:
                                          (constraints.maxWidth / 10),
                                      headingRowColor: WidgetStateProperty.all(
                                          color.primary.withOpacity(0.3)),
                                      columns: const [
                                        DataColumn(label: Text('ORDER ID')),
                                        DataColumn(
                                            label: Text('CUSTOMER NAME')),
                                        DataColumn(label: Text('TOTAL')),
                                        DataColumn(label: Text('STATUS')),
                                      ],
                                      rows: docs.map((doc) {
                                        final data = doc.data();
                                        print('${data['Status'] ?? 0}');
                                        return dataRow(
                                          context,
                                          id: doc.id,
                                          customerName:
                                              data['Customer name'] ?? 'N/A',
                                          total: '\$${data['Total'] ?? 0}',
                                          status: '${data['Status'] ?? 0}',
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow dataRow(
    BuildContext context, {
    required String id,
    required String customerName,
    required String total,
    required String status,
  }) {
    final color = Theme.of(context).colorScheme;
    bool isPending = status == 'Pending';
    bool isAccepted = status == 'Accepted';

    return DataRow(
      cells: [
        // 1. ID Cell
        DataCell(Text(id.toString(), style: TextStyle(color: color.onSurface))),

        // Customer Name
        DataCell(
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     // Container(
          //     //   width: 40,
          //     //   height: 40,
          //     //   decoration: BoxDecoration(
          //     //     color: const Color(0xFF0F1113),
          //     //     borderRadius: BorderRadius.circular(8),
          //     //     border: Border.all(color: const Color(0xFF2E3035)),
          //     //   ),
          //     //   // child: imageUrl != null
          //     //   //     ? Image.asset(imageUrl, fit: BoxFit.contain)
          //     //   //     : const Icon(Icons.image, size: 18, color: Colors.grey),
          //     // ),
          //     // const SizedBox(width: 12),
          //   ],
          // ),

          Text(customerName,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color.onSurface)),
        ),

        //  Total Cell
        DataCell(Text(total,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color.onSurface))),

        //  Actions Cell
        DataCell(
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isPending
                    ? Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                  color: color.onSecondary,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text('Pending')
                                ],
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    color.secondary.withOpacity(0.2),
                                foregroundColor: color.secondary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                side: BorderSide(color: color.secondary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Accept',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color.error.withOpacity(0.2),
                                foregroundColor: color.error,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                side: BorderSide(color: color.error),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Row(
                          children: [
                            const Spacer(),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: isAccepted
                                            ? color.secondary
                                            : color.error),
                                    color: isAccepted
                                        ? color.secondary.withOpacity(0.2)
                                        : color.error.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(50)),
                                // child: Row(
                                //   children: [
                                // Container(
                                //   width: 8,
                                //   height: 8,
                                //   decoration: const BoxDecoration(
                                //       color: Colors.amber,
                                //       shape: BoxShape.circle),
                                // ),
                                // const SizedBox(width: 5),
                                child: isAccepted
                                    ? Text('Accepted',
                                        style:
                                            TextStyle(color: color.secondary))
                                    : Text('Cancelled',
                                        style: TextStyle(color: color.error))
                                //   ],
                                // ),
                                ),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
