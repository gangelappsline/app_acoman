import 'package:acoman/pages/HomePage.dart';
import 'package:acoman/pages/ManeuversPage.dart';
import 'package:acoman/pages/ProfilePage.dart';
import 'package:acoman/pages/SettingsPage.dart';
import 'package:acoman/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TabContainerPage extends StatefulWidget {
  const TabContainerPage({super.key});

  @override
  State<TabContainerPage> createState() => _TabContainerPageState();
}

class _TabContainerPageState extends State<TabContainerPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late TextTheme textTheme;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 4,
        child: Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              //ExplorePage(),
              const HomePage(),
              const ManeuversPage(),
              const ProfilePage(),
              const SettingsPage()
            ],
          ),
          bottomNavigationBar: TabBar(
            labelStyle: const TextStyle(fontSize: 9.0),
            indicatorColor: const Color(0xFF000000),
            padding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            indicator: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      width: 2, color: ColorConstants.kPrimaryColorBlueDark)),
            ),
            tabs: [
              const Tab(
                icon: Icon(LucideIcons.home, size: 30.0),
                iconMargin: EdgeInsets.only(bottom: 2.0),
                text: "Inicio",
              ),
              const Tab(
                icon: Icon(LucideIcons.truck, size: 30.0),
                iconMargin: EdgeInsets.only(bottom: 2.0),
                text: "Maniobras",
              ),
              const Tab(
                icon: Icon(LucideIcons.user, size: 30.0),
                iconMargin: EdgeInsets.only(bottom: 2.0),
                text: "Perfil",
              ),
              const Tab(
                icon: Icon(LucideIcons.settings, size: 30.0),
                iconMargin: EdgeInsets.only(bottom: 2.0),
                text: "Configuración",
              ),
            ],
          ),
        ));
  }
}
