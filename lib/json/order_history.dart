class OrderHistory {
  String id;
  String orderId;
  String historyTime;
  String historyEvent;

  OrderHistory.fromJson(Map<String, dynamic> map)
      : id = map['history_id'],
        orderId = map['order_id'],
        historyTime = map['history_time'],
        historyEvent = map['history_event'];
}
