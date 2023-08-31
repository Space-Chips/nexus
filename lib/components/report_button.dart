import 'package:flutter/material.dart';

class DotsMenue extends StatelessWidget {
  final void Function()? onTap;
  const DotsMenue({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: Icon(Icons.more_vert, color: Colors.grey[500]), // add this line
        itemBuilder: (_) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                value: 'report',
                child: SizedBox(
                  width: 100,
                  // height: 30,

                  child: Text(
                    "Report",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: SizedBox(
                  width: 100,
                  // height: 30,
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
        onSelected: (index) async {
          switch (index) {
            case 'report':
              // showDialog(
              //     barrierDismissible: true,
              //     context: context,
              //     builder: (context) => ReportUser(
              //       currentUser: widget.sender,
              //       seconduser: widget.second,
              //     )).then((value) => Navigator.pop(ct))
              break;
          }
        });
  }
}
