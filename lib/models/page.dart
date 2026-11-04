import "package:flutter_inappwebview/flutter_inappwebview.dart";

class Page {
  WebUri? url;
  String? title;
  String? favicon;

  Page({this.url, this.title, this.favicon});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json["url"] = url!.toString();
    if (title != null) json["title"] = title;
    if (favicon != null) json["favicon"] = favicon;
    return json;
  }

  Page.fromJson(Map<String, dynamic> json)
    : url = .new(json["url"] as String),
      title = json["title"] as String?,
      favicon = json["favicon"] as String?;
}
