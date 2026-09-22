class CashoutModel {
  CashoutModel({
    required this.title,
    required this.date,
    required this.day,
    required this.time,
    required this.todayDate,
    required this.open,
    required this.close,
    required this.totalPay,
    required this.totalTips,
    required this.totalCategorySales,
    required this.discountCheck,
    required this.discountItems,

    required this.totalDiscount,
    required this.totalGratuity,
    required this.totalTipAmount,
    required this.totalPackagingCost,
    required this.employeesReport,
    required this.orders,
    required this.totalGst,
    required this.totalPst,
    required this.totalPst2,
    required this.totalMaintenanceFee,
    required this.totalDeliveryFee,
    required this.grandTotal,
  });

  final String title;
  final String date;
  final String day;
  final String time;
  final String todayDate;
  final String open;
  final String close;
  final List<TotalPay> totalPay;
  final List<TotalTip> totalTips;
  final List<TotalCategorySale> totalCategorySales;
  final num discountCheck;
  final num discountItems;
  final num totalDiscount;
  final num totalGratuity;
  final num totalTipAmount;
  final num totalPackagingCost;
  final List<EmployeeReport> employeesReport;

  final num orders;
  final num totalGst;
  final num totalPst;
  final num totalPst2;
  final num totalMaintenanceFee;
  final num totalDeliveryFee;
  final num grandTotal;

  factory CashoutModel.fromJson(Map<String, dynamic> json) {
    return CashoutModel(
      title: json["title"] ?? "",
      date: json["date"] ?? "",
      day: json["day"] ?? "",
      time: json["time"] ?? "",
      todayDate: json["todayDate"] ?? "",
      open: json["open"] ?? "",
      close: json["close"] ?? "",
      totalPay: json["totalPay"] == null
          ? []
          : List<TotalPay>.from(
              json["totalPay"]!.map((x) => TotalPay.fromJson(x)),
            ),
      totalTips: json["totalTips"] == null
          ? []
          : List<TotalTip>.from(
              json["totalTips"]!.map((x) => TotalTip.fromJson(x)),
            ),
      totalCategorySales: json["totalCategorySales"] == null
          ? []
          : List<TotalCategorySale>.from(
              json["totalCategorySales"]!.map(
                (x) => TotalCategorySale.fromJson(x),
              ),
            ),
      discountCheck: json["discountCheck"] ?? 0,
      discountItems: json["discountItems"] ?? 0,
      totalDiscount: json["totalDiscount"] ?? 0,
      totalGratuity: json["totalGratuity"] ?? 0,
      totalTipAmount: json["totalTipAmount"] ?? 0,
      totalPackagingCost: json["totalPackagingCost"] ?? 0,
      employeesReport: json["employeesReport"] == null
          ? []
          : List<EmployeeReport>.from(
              json["employeesReport"]!.map((x) => EmployeeReport.fromJson(x)),
            ),
      orders: json["orders"] ?? 0,
      totalGst: json["totalGst"] ?? 0,
      totalPst: json["totalPst"] ?? 0,
      totalPst2: json["totalPst2"] ?? 0,
      totalMaintenanceFee: json["totalMaintenanceFee"] ?? 0,
      totalDeliveryFee: json["totalDeliveryFee"] ?? 0,
      grandTotal: json["grandTotal"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "date": date,
    "day": day,
    "time": time,
    "todayDate": todayDate,
    "open": open,
    "close": close,
    "totalPay": totalPay.map((x) => x.toJson()).toList(),
    "totalTips": totalTips.map((x) => x.toJson()).toList(),
    "totalCategorySales": totalCategorySales.map((x) => x.toJson()).toList(),
    "discountCheck": discountCheck,
    "discountItems": discountItems,
    "totalDiscount": totalDiscount,
    "totalGratuity": totalGratuity,
    "totalTipAmount": totalTipAmount,
    "totalPackagingCost": totalPackagingCost,
    "employeesReport": employeesReport.map((x) => x.toJson()).toList(),
    "orders": orders,
    "grandTotal": grandTotal,
  };
}

class TotalCategorySale {
  TotalCategorySale({
    required this.title,
    required this.sales,
    required this.gratuity,
    required this.discount,
    required this.tip,
  });

  final String title;
  final num sales;
  final num gratuity;
  final num discount;

  final num tip;

  factory TotalCategorySale.fromJson(Map<String, dynamic> json) {
    return TotalCategorySale(
      title: json["title"] ?? "",
      sales: json["sales"] ?? 0,
      gratuity: json["gratuity"] ?? 0,
      tip: json["tip"] ?? 0,
      discount: json["discount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "sales": sales,
    "gratuity": gratuity,
    "tip": tip,
    "discount": discount,
  };
}

class TotalPay {
  TotalPay({
    required this.title,
    required this.pay,
    required this.tips,
    required this.gratuity,
    required this.discount,
  });

  final String title;
  final num pay;
  final num tips;
  final num gratuity;
  final num discount;

  factory TotalPay.fromJson(Map<String, dynamic> json) {
    return TotalPay(
      title: json["title"] ?? "",
      pay: json["pay"] ?? 0,
      tips: json["tips"] ?? 0,
      gratuity: json["gratuity"] ?? 0,
      discount: json["discount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "pay": pay,
    "tips": tips,
    "gratuity": gratuity,
    "discount": discount,
  };
}

class TotalTip {
  TotalTip({required this.title, required this.total});

  final String title;
  final num total;

  factory TotalTip.fromJson(Map<String, dynamic> json) {
    return TotalTip(title: json["title"] ?? "", total: json["total"] ?? 0);
  }

  Map<String, dynamic> toJson() => {"title": title, "total": total};
}

class EmployeeReport {
  EmployeeReport({
    required this.employeeId,
    required this.employeeName,
    required this.serverSales,
    required this.serverCashTips,
    required this.serverCardTips,
    required this.serverTotalGratuity,
    required this.serverCheckout,
  });

  final String employeeId;
  final String employeeName;
  final num serverSales;
  final num serverCashTips;
  final num serverCardTips;
  final num serverTotalGratuity;
  final num serverCheckout;

  factory EmployeeReport.fromJson(Map<String, dynamic> json) {
    return EmployeeReport(
      employeeId: json["employeeId"] ?? "",
      employeeName: json["employeeName"] ?? "",
      serverSales: json["serverSales"] ?? 0,
      serverCashTips: json["serverCashTips"] ?? 0,
      serverCardTips: json["serverCardTips"] ?? 0,
      serverTotalGratuity: json["serverTotalGratuity"] ?? 0,
      serverCheckout: json["serverCheckout"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "employeeId": employeeId,
    "employeeName": employeeName,
    "serverSales": serverSales,
    "serverCashTips": serverCashTips,
    "serverCardTips": serverCardTips,
    "serverTotalGratuity": serverTotalGratuity,
    "serverCheckout": serverCheckout,
  };
}
