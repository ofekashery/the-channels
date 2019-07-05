import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../model/channel.dart';
import './views/channel.dart';

class ChannelItem extends StatelessWidget {

  const ChannelItem(this.channel);
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 90,
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: <Widget>[
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: channel.logoUrl,
                  fadeOutDuration: Duration(milliseconds: 0),
                  placeholder: (BuildContext context, String url) => Container(
                    color: Color(0x0D000000),
                    width: 65,
                  )
                )
              ),
              height: 65,
              margin: EdgeInsets.only(bottom: 8)
            ),
            Text(channel.name, style: TextStyle(fontSize: 14), textAlign: TextAlign.center)
          ]
        )
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (c) {
                  return ChannelPage(channel);
                }
            )
        );
      },
    );
  }
}