import 'package:flutter/material.dart';
import 'package:kinclongin/screen/customer/booking_page.dart';
import 'package:kinclongin/screen/customer/checlist_page.dart';
import 'package:kinclongin/screen/customer/order_history_page.dart';
import 'package:kinclongin/screen/customer/view_details_page.dart';


class HomeCustomerPage extends StatelessWidget {
  const HomeCustomerPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor:  Color(0xFFF8FBF8),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_blue.png',
              width: 70,
              height: 70,
              ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Jefta Nala Putra", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                Text("Customer", style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Tombol navigasi utama
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Booking()),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/booking.png',
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Booking",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Checklist()),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/checklist.png',
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            "Checklist",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderHistory()),
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/orderhistory.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            "Order History",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Text("Available Service", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
              SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item 1: Shoe Wash
                  Row(
                    children: [
                      // Lingkaran dengan gambar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/images/shoe_wash.png',
                          fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shoe Wash", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Rp 10.000 - 25.000"),
                        ],
                      ),
                    ],
                  ),

                  Divider(),

                  // Item 2: Bag Wash
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/images/bag_wash.png', fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Bag Wash", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Rp 15.000 - 35.000"),
                        ],
                      ),
                    ],
                  ),
                  Divider(),

                  // Item 3: Service
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/images/service_v2.png', fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Service", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Rp 15.000"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),

              SizedBox(height: 20),

              // Promosi
              Text("Promotions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              Container(
                width: 362,
                height: 97,
                decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                child: Padding(
                  padding: EdgeInsets.all(11),
                  child: Row(
                    children: [
                    Image.asset("assets/images/promotion.png",
                    width: 77,
                    height: 77,
                    ),

                    SizedBox(width: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Special Offer!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        ),
                        Text("Get 20% off on Repaint service this week!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal
                        ),
                        ),

                        SizedBox(height: 3),

                      Row(
                        children: [
                          Image.asset("assets/images/check.png",
                          width: 17,
                          height: 17,
                          ),

                          SizedBox(width: 7),

                          Text("CleanStep",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      ],
                    ),
                  ],
                  ),
                ),
              ),

              SizedBox(height: 19),

              Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    GestureDetector(
      onTap: () {
        // Arahkan ke halaman View Details
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewDetailsPage()),
        );
      },
      child: Container(
        width: 174,
        height: 33,
        decoration: BoxDecoration(
          color: Colors.blue, // Warna default
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            "View Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
    GestureDetector(
      onTap: () {
        // Arahkan ke halaman Book Now
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Booking()),
        );
      },
      child: Container(
        width: 174,
        height: 33,
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            "Book Now!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  ],
),

            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notif"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
