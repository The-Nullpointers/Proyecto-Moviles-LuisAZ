//Codigo generado por https://app.quicktype.io
import 'dart:convert';

CourseResponse courseResponseFromJson(String str) => CourseResponse.fromJson(json.decode(str));

String courseResponseToJson(CourseResponse data) => json.encode(data.toJson());

class CourseResponse {
    List<CourseResponseDatum> data;
    Meta meta;

    CourseResponse({
        required this.data,
        required this.meta,
    });

    factory CourseResponse.fromJson(Map<String, dynamic> json) => CourseResponse(
        data: List<CourseResponseDatum>.from(json["data"].map((x) => CourseResponseDatum.fromJson(x))),
        meta: Meta.fromJson(json["meta"]),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta.toJson(),
    };
}

class CourseResponseDatum {
    int id;
    PurpleAttributes attributes;

    CourseResponseDatum({
        required this.id,
        required this.attributes,
    });

    factory CourseResponseDatum.fromJson(Map<String, dynamic> json) => CourseResponseDatum(
        id: json["id"],
        attributes: PurpleAttributes.fromJson(json["attributes"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "attributes": attributes.toJson(),
    };
}

class PurpleAttributes {
    String courseId;
    String name;
    int capacity;
    DateTime createdAt;
    DateTime updatedAt;
    DateTime publishedAt;
    DateTime schedule;
    Users users;

    PurpleAttributes({
        required this.courseId,
        required this.name,
        required this.capacity,
        required this.createdAt,
        required this.updatedAt,
        required this.publishedAt,
        required this.schedule,
        required this.users,
    });

    factory PurpleAttributes.fromJson(Map<String, dynamic> json) => PurpleAttributes(
        courseId: json["courseId"],
        name: json["name"],
        capacity: json["capacity"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        publishedAt: DateTime.parse(json["publishedAt"]),
        schedule: DateTime.parse(json["schedule"]),
        users: Users.fromJson(json["users"]),
    );

    Map<String, dynamic> toJson() => {
        "courseId": courseId,
        "name": name,
        "capacity": capacity,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "publishedAt": publishedAt.toIso8601String(),
        "schedule": schedule.toIso8601String(),
        "users": users.toJson(),
    };
}

class Users {
    List<UsersDatum> data;

    Users({
        required this.data,
    });

    factory Users.fromJson(Map<String, dynamic> json) => Users(
        data: List<UsersDatum>.from(json["data"].map((x) => UsersDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class UsersDatum {
    int id;
    FluffyAttributes attributes;

    UsersDatum({
        required this.id,
        required this.attributes,
    });

    factory UsersDatum.fromJson(Map<String, dynamic> json) => UsersDatum(
        id: json["id"],
        attributes: FluffyAttributes.fromJson(json["attributes"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "attributes": attributes.toJson(),
    };
}

class FluffyAttributes {
    String username;
    String email;
    String provider;
    bool confirmed;
    bool blocked;
    DateTime createdAt;
    DateTime updatedAt;
    String cedula;

    FluffyAttributes({
        required this.username,
        required this.email,
        required this.provider,
        required this.confirmed,
        required this.blocked,
        required this.createdAt,
        required this.updatedAt,
        required this.cedula,
    });

    factory FluffyAttributes.fromJson(Map<String, dynamic> json) => FluffyAttributes(
        username: json["username"],
        email: json["email"],
        provider: json["provider"],
        confirmed: json["confirmed"],
        blocked: json["blocked"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        cedula: json["cedula"],
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "email": email,
        "provider": provider,
        "confirmed": confirmed,
        "blocked": blocked,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "cedula": cedula,
    };
}

class Meta {
    Pagination pagination;

    Meta({
        required this.pagination,
    });

    factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        pagination: Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "pagination": pagination.toJson(),
    };
}

class Pagination {
    int page;
    int pageSize;
    int pageCount;
    int total;

    Pagination({
        required this.page,
        required this.pageSize,
        required this.pageCount,
        required this.total,
    });

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"],
        pageSize: json["pageSize"],
        pageCount: json["pageCount"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "pageSize": pageSize,
        "pageCount": pageCount,
        "total": total,
    };
}
