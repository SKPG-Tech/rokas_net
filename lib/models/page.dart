class Page {
  Uri? uri;
  String? title;

  Page({this.uri, this.title});

  String? get favicon => uri != null
      ? "https://www.google.com/s2/favicons?domain=${uri!.host}&sz=32"
      : null;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json["uri"] = uri!.toString();
    if (title != null) json["title"] = title;
    return json;
  }

  Page.fromJson(Map<String, dynamic> json)
    : uri = .parse(json["uri"] as String),
      title = json["title"] as String?;
}
