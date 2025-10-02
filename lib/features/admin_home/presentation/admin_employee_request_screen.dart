

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/admin_employee_view.dart';
import 'package:koji/features/admin_home/presentation/widget/hotizontal_list.dart';

class AdminEmployeeRequestScreen extends StatefulWidget {
  const AdminEmployeeRequestScreen({super.key});

  @override
  State<AdminEmployeeRequestScreen> createState() => _AdminEmployeeRequestScreenState();
}

class _AdminEmployeeRequestScreenState extends State<AdminEmployeeRequestScreen> {
  final List<Map<String, dynamic>> users = const [
    {
      "name": "John Doe",
      "subtitle": "Software Engineer",
      "image":
      "https://www.w3schools.com/howto/img_avatar.png", // network image
    },
    {
      "name": "Jane Smith",
      "subtitle": "Product Manager",
      "image":
      "https://www.w3schools.com/howto/img_avatar2.png",
    },
    {
      "name": "Mike Johnson",
      "subtitle": "UX Designer",
      "image":
      "https://www.w3schools.com/howto/img_avatar.png",
    },
    {
      "name": "Mike Johnson",
      "subtitle": "UX Designer",
      "image":
      "https://www.w3schools.com/howto/img_avatar.png",
    },
    {
      "name": "Mike Johnson",
      "subtitle": "UX Designer",
      "image":
      "https://www.w3schools.com/howto/img_avatar.png",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee"), centerTitle: true),
      body: Padding(padding: EdgeInsets.all(10.sp),
      child: Column(
        children: [
          HorizontalListExample(
            items: [
              {"id": 1, "title": "All Shift"},
              {"id": 2, "title": "Morning Shift"},
              {"id": 3, "title": "Evening Shift"},
              {"id": 3, "title": "Night Shift"},

            ],
            onItemSelected: (selectedItem) {
              print("You clicked: ${selectedItem["title"]}, ID: ${selectedItem["id"]}");
            },
          ),
      ListView.builder(
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(user['image']),
              ),
              title: Text(user['name']),
              subtitle: Text(user['subtitle']),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  // Return the map data on button click
                  print('Clicked user data: $user');
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdminEmployeeView()));

                },
                child: const Text('View'),
              ),
            ),
          );
        },
      ),

        ],
      ),
      ),
    );
  }
}
