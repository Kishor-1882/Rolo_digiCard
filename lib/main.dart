import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/sidebar.dart';
import 'package:rolo_digi_card/views/home_page/home_page.dart';
import 'package:rolo_digi_card/views/login_page/login_page.dart';
import 'package:rolo_digi_card/views/organization/analytics_view.dart';
import 'package:rolo_digi_card/views/organization/organization_cards_view.dart';
import 'package:rolo_digi_card/views/organization/organization_dashboard_view.dart';
import 'package:rolo_digi_card/views/organization/organization_groups_view.dart';
import 'package:rolo_digi_card/views/organization/organization_saved_view.dart';
import 'package:rolo_digi_card/views/splash_screen/splash_screen.dart';

import 'views/home_page/create_new_card.dart';
import 'views/my_cards_page/widget/business_card_details.dart';
import 'views/scan_screen/scan_screen.dart';


void main() {
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rolo Digi Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: "/splash",
      getPages: [
        // GetPage(name: "/splash", page: () =>  OrganizationDashboardView()),
      //  GetPage(name: "/splash", page: () =>  OrganizationSavedView()),
         // GetPage(name: "/splash", page: () =>  OrganizationCardsView()),
        //  GetPage(name: "/splash", page: () =>  OrganizationGroupsView()),
        // GetPage(name: "/splash", page: () =>  AnalyticsView()),
        GetPage(name: "/splash", page: () => const SplashScreen()),
        GetPage(name: "/login", page: () => LoginPage()),
        GetPage(name: "/home", page: () => DashboardPage()),
        GetPage(name: "/sidebar", page: () => SideBar()),
        GetPage(name: "/create-card", page: () => CreateNewCard()),
        GetPage(name: "/scan-card", page: () => QRScannerPage()),
        // GetPage(name: "/card-profile", page: () => BusinessCardProfilePage()),
      ],
    );
  }
}

