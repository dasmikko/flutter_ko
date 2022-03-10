import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:knocky/helpers/twitterApi.dart';
import 'package:knocky/widgets/CachedSizeWidget.dart';
import 'package:tweet_ui/models/api/entieties/tweet_entities.dart';
import 'package:tweet_ui/models/api/tweet.dart';
import 'package:tweet_ui/tweet_ui.dart';

class TwitterCardNew extends StatefulWidget {
  final Key key;
  final String tweetUrl;
  final Function onTapImage;

  TwitterCardNew({this.key, this.tweetUrl, this.onTapImage}) : super(key: key);

  @override
  _TwitterCardState createState() => _TwitterCardState();
}

class _TwitterCardState extends State<TwitterCardNew>
    with AfterLayoutMixin<TwitterCardNew> {
  bool _isLoading = true;
  bool _failed = false;
  Map _twitterJson = null;
  Tweet _tweet = null;

  @override
  void afterFirstLayout(BuildContext context) {
    print(_tweet);
    if (_tweet == null) fetchTwitterJson();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchTwitterJson() async {
    Uri url = Uri.parse(this.widget.tweetUrl);
    int tweetId = int.parse(url.pathSegments.last);
    Map<String, dynamic> twitterJson = await TwitterHelper().getTweet(tweetId);
    print(twitterJson);
    Tweet tweet = Tweet.fromJson(twitterJson);

    if (twitterJson['errors'] != null) {
      if (this.mounted) {
        setState(() {
          _isLoading = false;
          _failed = true;
          _twitterJson = twitterJson;
          _tweet = tweet;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          _isLoading = false;
          _twitterJson = twitterJson;
          _tweet = tweet;
        });
      }
    }
  }

  Widget twitterMedia(TweetEntities entityList) {
    return Container(
      child: Text('show media here!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    if (_failed) return Text('failed to load tweet');
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 600,
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.grey[800],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 6),
                    child: ExtendedImage.network(
                      _tweet.user.profileImageUrlHttps,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_tweet.user.name),
                      Text("@" + _tweet.user.screenName)
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 6),
              child: Text(_tweet.text),
            ),
            twitterMedia(_tweet.entities),
          ],
        ),
      ),
    );
  }
}
