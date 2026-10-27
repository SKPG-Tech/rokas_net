class Page {
  Uri? uri;
  String? title;
  String? favicon;

  Page({this.uri, this.title, this.favicon});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json["uri"] = uri!.toString();
    if (title != null) json["title"] = title;
    if (favicon != null) json["favicon"] = favicon;
    return json;
  }

  Page.fromJson(Map<String, dynamic> json)
    : uri = .parse(json["uri"] as String),
      title = json["title"] as String?,
      favicon = json["favicon"] as String?;
}
