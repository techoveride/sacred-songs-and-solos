class ComposeHymns {
  String? author;
  int? id;
  String? lyric;
  String? title;
  String? tune;

  ComposeHymns({this.author, this.id, this.lyric, this.title, this.tune});

  factory ComposeHymns.fromJson(Map<String, dynamic> json) {
    return ComposeHymns(
      author: json['author'],
      id: json['id'],
      lyric: json['lyric'],
      title: json['title'],
      tune: json['tune'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['author'] = author;
    data['id'] = id;
    data['lyric'] = lyric;
    data['title'] = title;
    data['tune'] = tune;
    return data;
  }
}
