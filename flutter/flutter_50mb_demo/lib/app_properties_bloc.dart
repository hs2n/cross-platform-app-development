import 'dart:async';

final appBloc = AppPropertiesBloc();

class AppPropertiesBloc {
  StreamController<String> _title = StreamController<String>();

  Stream<String> get titleStream => _title.stream;

  String fullSubredditName = "r/all";
  String user;
  String token;

  updateTitle(String newTitle) {
    _title.sink.add(newTitle);
  }

  dispose() {
    _title.close();
  }
}
