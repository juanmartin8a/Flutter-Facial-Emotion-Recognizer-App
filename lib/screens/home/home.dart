import 'package:flutter/material.dart';
import 'camera/cameraMain.dart';
import 'main/main_screen.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
  TabController tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Computer Vision',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[50]
            ),
          ),
          backgroundColor: Colors.amber[800],
          elevation: 0.0,
          actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: GestureDetector(
                onTap: tabIndex == 2 
                ? () async {
                  //await _auth.signOut();
                }
                : () {},
                child: tabIndex == 2 
                ? Icon(Icons.logout, color: Colors.white, size: 28,)
                : Container()
              )
            )
          ],
        )
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: Container(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    Container(
                      child: MainScreen()
                    ),
                    Container(
                      child: CameraScreen()
                    ),
                    Container(
                      child: MainScreen()
                    )
                  ],
                )
              )
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor, //Colors.grey[50]
                  border: Border(
                    top: BorderSide(color: Colors.grey[400], width: 0.3)
                  )
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(),
                  indicatorColor: Colors.transparent,
                  onTap: (index) {
                    //tabController.animateTo(index, duration: Duration(milliseconds: 250));
                    print(index);
                    setState(() {
                      tabIndex = tabController.index;
                    });
                  },
                  tabs: [
                    Tab(icon: Icon(
                      Icons.home_outlined, 
                      size: tabIndex == 0 ? 34 : 32, 
                      color: tabIndex == 0 ? Colors.black : Colors.grey[800]
                    )),
                    Tab(icon: Icon(
                      Icons.camera_alt_outlined, 
                      size: tabIndex == 1 ? 34 : 32, 
                      color: tabIndex == 1 ? Colors.black : Colors.grey[800]
                    )),
                    Tab(icon: Icon(
                      Icons.person_outline_rounded, 
                      size: tabIndex == 2 ? 34 : 32, 
                      color: tabIndex == 2 ? Colors.black : Colors.grey[800]
                    )),
                  ],
                )
              )
            )
          ],
        )
      )
    );
  }
}
