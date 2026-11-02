class Page {
  Uri? url;
  String? title;

  Page({this.url, this.title});

  String? get favicon => url != null
      ? "https://www.google.com/s2/favicons?domain=${url!.host}&sz=32"
      : null;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json["url"] = url!.toString();
    if (title != null) json["title"] = title;
    return json;
  }

  Page.fromJson(Map<String, dynamic> json)
    : url = .parse(json["url"] as String),
      title = json["title"] as String?;
}
