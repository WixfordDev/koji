

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:koji/features/admin_home/presentation/widget/hotizontal_list.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});
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
      appBar: AppBar(title: Text("Attandance"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(10.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                shrinkWrap: true, // Important for scrollable parent
                physics: NeverScrollableScrollPhysics(),
                children: [
                  DashboardCard(
                    title: "Users",
                    subtitle: "1,200",
                    icon: Icons.people,
                    color: Colors.purple,
                    onTap: () => print("Users card tapped"),
                  ),
                  DashboardCard(
                    title: "Revenue",
                    subtitle: "\$25,000",
                    icon: Icons.attach_money,
                    color: Colors.green,
                    onTap: () => print("Revenue card tapped"),
                  ),
                  DashboardCard(
                    title: "Orders",
                    subtitle: "320",
                    icon: Icons.shopping_cart,
                    color: Colors.orange,
                    onTap: () => print("Orders card tapped"),
                  ),
                  DashboardCard(
                    title: "Messages",
                    subtitle: "15",
                    icon: Icons.message,
                    color: Colors.blue,
                    onTap: () => print("Messages card tapped"),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              HorizontalListExample(
                items: [
                  {"id": 1, "title": "Pending"},
                  {"id": 2, "title": "Approval"},
                  {"id": 3, "title": "Rejected"},
                ],
                onItemSelected: (selectedItem) {
                  print("You clicked: ${selectedItem["title"]}, ID: ${selectedItem["id"]}");
                },
              ),

              SizedBox(height: 10.h),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                      trailing: Icon(Icons.person),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

    );
  }
}



class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = Colors.blue,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(1),
          width: 160, // Fixed width for grid/list
          height: 120, // Fixed height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   title,
                  //   style: const TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

