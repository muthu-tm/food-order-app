enum OrderStatus {
  Ordered,
  Confirmed,
  CancelledByUser,
  CancelledByStore,
  DisPatched,
  Delivered,
  Returned
}

extension OrderStatusExtension on OrderStatus {
  int get name {
    switch (this) {
      case OrderStatus.Ordered:
        return 0;
        break;
      case OrderStatus.Confirmed:
        return 1;
        break;
      case OrderStatus.CancelledByUser:
        return 2;
        break;
      case OrderStatus.CancelledByStore:
        return 3;
        break;
      case OrderStatus.DisPatched:
        return 4;
        break;
      case OrderStatus.Delivered:
        return 5;
        break;
      case OrderStatus.Returned:
        return 6;
        break;
      default:
        return 0;
    }
  }
}
