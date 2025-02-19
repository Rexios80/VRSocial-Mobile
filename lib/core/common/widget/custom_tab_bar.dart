import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTabBarMenu extends StatefulWidget {
  @override
  _CustomTabBarMenuState createState() => _CustomTabBarMenuState();
}

class _CustomTabBarMenuState extends State<CustomTabBarMenu>
    with SingleTickerProviderStateMixin{

  TabController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            //This is responsible for the background of the tabbar, does the magic
              decoration: BoxDecoration(
                //This is for background color
                  color: Colors.white.withOpacity(0.0),
                  //This is for bottom border that is needed
                  border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.8))),
              child: TabBar(
                  controller: _controller,
                  tabs: [

                  ]
              )
          ),
          Container(
              height: MediaQuery.of(context).size.height/2.3,
              child: new TabBarView(
                controller: _controller,
                children: <Widget>[],
              )
          )
        ]
    );
}