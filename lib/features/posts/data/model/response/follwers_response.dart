// To parse this JSON data, do
//
//     final followersResponse = followersResponseFromJson(jsonString);

import 'dart:convert';

FollowersResponse followersResponseFromJson(String str) => FollowersResponse.fromJson(json.decode(str));

String followersResponseToJson(FollowersResponse data) => json.encode(data.toJson());

class FollowersResponse {
  FollowersResponse({
    this.code,
    this.valid,
    this.message,
    this.data,
  });

  int code;
  bool valid;
  String message;
  List<FollowerResponseModel> data;

  factory FollowersResponse.fromJson(Map<String, dynamic> json) => FollowersResponse(
    code: json["code"] == null ? null : json["code"],
    valid: json["valid"] == null ? null : json["valid"],
    message: json["message"] == null ? null : json["message"],
    data: json["data"] == null ? null : List<FollowerResponseModel>.from(json["data"].map((x) => FollowerResponseModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "code": code == null ? null : code,
    "valid": valid == null ? null : valid,
    "message": message == null ? null : message,
    "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FollowerResponseModel {
  FollowerResponseModel({
    this.offsetId,
    this.id,
    this.about,
    this.followers,
    this.posts,
    this.avatar,
    this.lastActive,
    this.username,
    this.fname,
    this.lname,
    this.email,
    this.verified,
    this.name,
    this.url,
    this.isFollowing,
    this.isUser,
  });

  int offsetId;
  int id;
  String about;
  int followers;
  int posts;
  String avatar;
  String lastActive;
  String username;
  String fname;
  String lname;
  String email;
  String verified;
  String name;
  String url;
  bool isFollowing;
  bool isUser;

  factory FollowerResponseModel.fromJson(Map<String, dynamic> json) => FollowerResponseModel(
    offsetId: json["offset_id"] == null ? null : json["offset_id"],
    id: json["id"] == null ? null : json["id"],
    about: json["about"] == null ? null : json["about"],
    followers: json["followers"] == null ? null : json["followers"],
    posts: json["posts"] == null ? null : json["posts"],
    avatar: json["avatar"] == null ? null : json["avatar"],
    lastActive: json["last_active"] == null ? null : json["last_active"],
    username: json["username"] == null ? null : json["username"],
    fname: json["fname"] == null ? null : json["fname"],
    lname: json["lname"] == null ? null : json["lname"],
    email: json["email"] == null ? null : json["email"],
    verified: json["verified"] == null ? null : json["verified"],
    name: json["name"] == null ? null : json["name"],
    url: json["url"] == null ? null : json["url"],
    isFollowing: json["is_following"] == null ? null : json["is_following"],
    isUser: json["is_user"] == null ? null : json["is_user"],
  );

  Map<String, dynamic> toJson() => {
    "offset_id": offsetId == null ? null : offsetId,
    "id": id == null ? null : id,
    "about": about == null ? null : about,
    "followers": followers == null ? null : followers,
    "posts": posts == null ? null : posts,
    "avatar": avatar == null ? null : avatar,
    "last_active": lastActive == null ? null : lastActive,
    "username": username == null ? null : username,
    "fname": fname == null ? null : fname,
    "lname": lname == null ? null : lname,
    "email": email == null ? null : email,
    "verified": verified == null ? null : verified,
    "name": name == null ? null : name,
    "url": url == null ? null : url,
    "is_following": isFollowing == null ? null : isFollowing,
    "is_user": isUser == null ? null : isUser,
  };
}
