import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knocky/helpers/colors.dart';
import 'package:knocky/models/thread.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:scoped_model/scoped_model.dart';
import 'package:knocky/state/authentication.dart';

class PostHeader extends StatelessWidget {
  final BuildContext context;
  final int userId;
  final int userGroup;
  final String username;
  final String avatarUrl;
  final String backgroundUrl;
  final ThreadPost threadPost;

  PostHeader(
      {this.avatarUrl, this.backgroundUrl, this.username, this.userId, this.userGroup, this.threadPost, this.context});

  @override
  Widget build(BuildContext context) {
    print(userGroup);
    //print('avatar: ' +  avatarUrl);
    //print('background : ' + backgroundUrl);
    final int ownUserId =
        ScopedModel.of<AuthenticationModel>(context, rebuildOnChange: true)
            .userId;

    bool hasBg = (backgroundUrl != null ||
        backgroundUrl != '' ||
        backgroundUrl != 'none.webp');
    bool hasAvatar = (avatarUrl != null || avatarUrl != '');

    Color userColor = AppColors(context).normalUserColor(); // User
    if (userGroup == 2) userColor = AppColors(context).goldUserColor(); // Gold
    if (userGroup == 3) userColor = AppColors(context).modUserColor(); // Mod
    if (userGroup == 4) userColor = AppColors(context).adminUserColor(); // Admin

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: ownUserId == userId ? Border(left: BorderSide(color: Color.fromRGBO(255, 216, 23, 1), width: 2)) : null,
              image: hasBg != null
                  ? DecorationImage(
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.dstATop),
                      image: CachedNetworkImageProvider(
                          'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                              backgroundUrl))
                  : null),
          child: Row(
            children: <Widget>[
              if (hasAvatar)
                Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 40,
                  height: 40,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://knockout-production-assets.nyc3.digitaloceanspaces.com/image/' +
                            avatarUrl,
                  ),
                ),
              Text(
                username,
                style: TextStyle(fontWeight: FontWeight.bold, color: userColor),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
          color: Theme.of(context).brightness == Brightness.dark ? Color.fromRGBO(45, 45, 48, 1) : Color.fromRGBO(230, 230, 230, 1),
          child: Row(
            children: <Widget>[Text(timeago.format(threadPost.createdAt))],
          ),
        )
      ],
    );
  }
}
