class TableReservationsModel {
    TableReservationsModel({
        required this.data,
        required this.meta,
    });

    final List<Reservations> data;
    final Meta? meta;

    factory TableReservationsModel.fromJson(Map<String, dynamic> json){ 
        return TableReservationsModel(
            data: json["data"] == null ? [] : List<Reservations>.from(json["data"]!.map((x) => Reservations.fromJson(x))),
            meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
        );
    }

    Map<String, dynamic> toJson() => {
        "data": data.map((x) => x.toJson()).toList(),
        "meta": meta?.toJson(),
    };

}

class Reservations {
    Reservations({
        required this.tableBookId,
        required this.fullName,
        required this.email,
        required this.numberOfGuests,
        required this.phoneNumber,
        required this.notes,
        required this.selectedTable,
        required this.bookingTime,
        required this.status,
        required this.createdAt,
        required this.bookingDate,
        required this.id,
    });

    final String tableBookId;
    final String fullName;
    final String email;
    final int numberOfGuests;
    final String phoneNumber;
    final String notes;
    final String selectedTable;
    final String bookingTime;
    final String status;
    final DateTime createdAt;
    final DateTime bookingDate;
    final String id;

    factory Reservations.fromJson(Map<String, dynamic> json){ 
        return Reservations(
            tableBookId: json["tableBookId"] ?? "",
            fullName: json["fullName"] ?? "",
            email: json["email"] ?? "",
            numberOfGuests: json["numberOfGuests"] ?? 0,
            phoneNumber: json["phoneNumber"] ?? "",
            notes: json["notes"] ?? "",
            selectedTable: json["selectedTable"] ?? "",
            bookingTime: json["bookingTime"] ?? "",
            status: json["status"] ?? "",
            createdAt: DateTime.parse(json["createdAt"] ),
            bookingDate: DateTime.parse(json["bookingDate"] ),
            id: json["id"] ?? "",
        );
    }

    Map<String, dynamic> toJson() => {
        "tableBookId": tableBookId,
        "fullName": fullName,
        "email": email,
        "numberOfGuests": numberOfGuests,
        "phoneNumber": phoneNumber,
        "notes": notes,
        "selectedTable": selectedTable,
        "bookingTime": bookingTime,
        "status": status,
        // "createdAt": createdAt?.toIso8601String(),
        "id": id,
    };

}

class Meta {
    Meta({
        required this.total,
        required this.limit,
        required this.currentPage,
        required this.totalPages,
        required this.hasNextPage,
        required this.hasPreviousPage,
    });

    final int total;
    final int limit;
    final int currentPage;
    final int totalPages;
    final bool hasNextPage;
    final bool hasPreviousPage;

    factory Meta.fromJson(Map<String, dynamic> json){ 
        return Meta(
            total: json["total"] ?? 0,
            limit: json["limit"] ?? 0,
            currentPage: json["currentPage"] ?? 0,
            totalPages: json["totalPages"] ?? 0,
            hasNextPage: json["hasNextPage"] ?? false,
            hasPreviousPage: json["hasPreviousPage"] ?? false,
        );
    }

    Map<String, dynamic> toJson() => {
        "total": total,
        "limit": limit,
        "currentPage": currentPage,
        "totalPages": totalPages,
        "hasNextPage": hasNextPage,
        "hasPreviousPage": hasPreviousPage,
    };

}