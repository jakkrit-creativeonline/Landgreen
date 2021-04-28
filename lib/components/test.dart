import 'package:flutter/material.dart';

class LocalGalleryTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocalGalleryState();
  }
}

class _LocalGalleryState extends State<LocalGalleryTab> {
  var refresh = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          child: Center(
        child: RefreshIndicator(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(color: Colors.orange,width : double.infinity,height : size.height,child: Center(child: Text('Refresh : $refresh'))),
          ),
          onRefresh: _refreshLocalGallery,
        ),
      )),
    );
  }

  Future<Null> _refreshLocalGallery() async {
    setState(() {
      print('Refresh state');
      refresh += 1;
    });
  }
}
