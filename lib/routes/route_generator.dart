import 'package:ca_tech/screens/Dashbord/dashbord_screen.dart';
import 'package:flutter/material.dart';
import '../screens/Account/account_screen.dart';
import '../screens/EmployeeManagement/employee_management.dart';
import '../screens/Feature/feature_screen.dart';
import '../screens/HomePage/Newhome_screen.dart';
import '../screens/PartnerManagement/CreatePartner/createPartner.dart';
import '../screens/PartnerManagement/ViewPartners/viewPartners.dart';
import '../screens/PartnerManagement/partnerManagement.dart';
import '../screens/Register/register_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/signup/signup_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => SignUpTab());
      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => AuthScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginTab());
      case AppRoutes.account:
        return MaterialPageRoute(builder: (_) => AccountPage());
      case AppRoutes.feature:
        return MaterialPageRoute(builder: (_) => FeaturesPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case AppRoutes.dashbord:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case AppRoutes.employeeManagement:
        return MaterialPageRoute(builder: (_) => EmployeeManagementScreen());
      case AppRoutes.partnerManagement:
        return MaterialPageRoute(builder: (_) => PartnerManagementScreen());
      case AppRoutes.viewpartner:
        return MaterialPageRoute(builder: (_) => ViewPartnersTab());
      case AppRoutes.createpartner:
        return MaterialPageRoute(builder: (_) => CreatePartnerTab());
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('Page not found'))));
    }
  }
}
