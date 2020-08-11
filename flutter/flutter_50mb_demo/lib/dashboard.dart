import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_50mb_demo/app_properties_bloc.dart';

import 'package:http/http.dart' as http;

String baseUrl;

class Dashboard extends StatefulWidget {
  State<StatefulWidget> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List<RedditPost> _postList = List<RedditPost>();
  String _after;

  bool _isLoading = true;

  /// Loads new posts from the url specified above
  /// if boolean previous is false, will automatically load posts after
  void _loadPosts() async {
    _isLoading = true;
    String url = baseUrl + (_after != null ? "?after=$_after" : "");

    // TODO; This should throw an exception when no internet connection is available
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body)['data'];
      int itemCount = jsonData['dist'];
      for (int i = 0; i < itemCount; i++) {
        _postList.add(RedditPost.fromJson(jsonData['children'][i]['data']));
      }
      print("After is ${jsonData['after']}");
      setState(() {
        _after = jsonData['after'];
        _isLoading = false;
      });
    } else {
      // TODO: User message
      print("Error while fetching data!");
      setState(() {
        _isLoading = false;
      });
    }
    print("Not loading anymore!");
  }

  @override
  void initState() {
    baseUrl =
        "https://www.reddit.com/" + appBloc.fullSubredditName + "/hot.json";
    print("Changed baseUrl to $baseUrl");

    _loadPosts();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();

    print("Amount of posts loaded: ${_postList.length}");
    return _createInifiniteScrollList();
  }

  Widget _createInifiniteScrollList() {
    ScrollController _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        if (_isLoading == false) {
          _isLoading = !_isLoading;
          _loadPosts();
        }
      }
    });

    return ListView.builder(
        controller: _scrollController,
        itemCount: _postList.length + 1,
        itemBuilder: (context, idx) {
          if (idx + 1 == _postList.length + 1)
            return Center(
              child: Padding(
                padding: EdgeInsets.all(6.0),
                child: CircularProgressIndicator(),
              ),
            );

          RedditPost currentPost = _postList[idx];
          return Card(
            child: (currentPost == null)
                ? Text('Something went wrong. Could not access post in list.')
                : ListTile(
                    title: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${currentPost.subreddit} by ${currentPost.author}",
                                style: TextStyle(fontSize: 12.5),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 6.0),
                                child: Text(
                                  currentPost.title,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: currentPost.urlThumbnail != null
                              ? Padding(
                                  child:
                                      Image.network(currentPost.urlThumbnail),
                                  padding: EdgeInsets.all(5),
                                )
                              : null,
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 12.0, bottom: 8.0),
                          child: Text(
                            currentPost.getSelftextPreview(),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14.0),
                          ),
                        ),
                        Text(
                            "#${idx + 1} / ${currentPost.votes} Upvotes / ${currentPost.comments} Comments "),
                      ],
                    )),
          );
        });
  }
}

class RedditPost {
  static final int previewLength = 256;

  int id;
  int votes;
  int comments;
  double upvoteRatio;
  String subreddit;
  String title;
  String selftext;
  String author;
  String urlThumbnail;

  String getSelftextPreview() {
    if (selftext.length < previewLength) return selftext;
    return selftext.substring(0, previewLength) + '...';
  }

  static RedditPost fromJson(var postData) {
    RedditPost post = RedditPost();
    post.title = postData['title'];
    post.selftext = postData['selftext'];
    post.subreddit = postData['subreddit_name_prefixed'];
    post.author = "u/" + postData['author'];
    if (postData['author_premium'] != null) post.author += " (premium)";

    post.upvoteRatio = postData['upvoteRatio'];
    post.comments = postData['num_comments'];
    post.votes = postData['ups'] == 0 ? postData['downs'] : postData['ups'];
    post.urlThumbnail = postData['thumbnail'];
    return post;
  }
}
