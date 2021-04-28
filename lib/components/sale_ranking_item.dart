import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:system/configs/constants.dart';

class SaleRankingItem extends StatelessWidget {
  final String imgUrl;
  final String name;
  final int sumqty;
  final int rank;

  const SaleRankingItem({
    Key key,
    this.imgUrl,
    this.name,
    this.rank,
    this.sumqty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var _widthImg = size.width * 0.16;
    var _heightImg = size.width * 0.16;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // color: Colors.red,
          width: _widthImg,
          height: _heightImg,
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (imgUrl != null && imgUrl != 'null')
                  ? CachedNetworkImage(
                      placeholder: (context, url) => ShimmerLoading(
                        type: 'imageSquare',
                      ),
                      imageUrl:
                          'https://landgreen.ml/system/storage/app/${imgUrl}',
                      errorWidget: (context, url, error) {
                        // print(rank);
                        // print(error);
                        return Image.asset('assets/avatar.png');
                      },
                    )
                  : Image.asset('assets/avatar.png'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 15,
                  height: 15,
                  color: kPrimaryColor,
                  child: Center(
                    child: Text(
                      '${rank}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            // Container(
            //
            //   width: 15,
            //   height: 15,
            //   color: kPrimaryColor,
            //   child: Center(
            //     child: Text('${rank}',style: TextStyle(fontSize: 11,color: Colors.white),),
            //   ),
            // )
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            name,
            style: TextStyle(fontSize: 16, height: 1),
          ),
        ),
        Text(
          '${sumqty} กส.',
          style: TextStyle(fontSize: 15, height: 1),
        ),
      ],
    );
  }
}
