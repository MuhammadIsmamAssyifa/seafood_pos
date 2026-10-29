class ApiEndpoint {
  // Auth
  static const String user = '/user';
  static const String login = '/v1/login';
  static const String staffLogin = '/v1/staff-login';
  static const String logout = '/v1/logout';
  static const String logoutAll = '/v1/logout-all';

  // Dashboard
  static const String dashboardSummary = '/v1/dashboard/summary';

  // Catalog
  static const String menus = '/v1/catalog/menus';
  static const String stations = '/v1/catalog/stations';

  // Tables
  static const String tables = '/v1/tables';
  static String tableDetail(dynamic id) => '/v1/tables/$id';

  // Orders
  static const String orders = '/v1/orders';
  static String orderDetail(dynamic id) => '/v1/orders/$id';
  static String orderItems(dynamic orderId) => '/v1/orders/$orderId/items';
  static String orderPayments(dynamic orderId) => '/v1/orders/$orderId/payments';
  static String paymentSummary(dynamic orderId) => '/v1/orders/$orderId/payments/summary';

  // Order Items & Changes
  static String orderItemDetail(dynamic id) => '/v1/order-items/$id';
  static String orderItemChanges(dynamic orderItemId) => '/v1/order-items/$orderItemId/changes';
  static String orderItemReplace(dynamic orderItemId) => '/v1/order-items/$orderItemId/replace';
  static String approveItemChange(dynamic changeId) => '/v1/order-item-changes/$changeId/approve';
  static String rejectItemChange(dynamic changeId) => '/v1/order-item-changes/$changeId/reject';

  // Order Batches
  static String submitBatch(dynamic batchId) => '/v1/order-batches/$batchId/submit';

  // Kitchen
  static const String kitchenOrders = '/v1/kitchen/orders';
  static String acceptBatch(dynamic batchId) => '/v1/kitchen/batches/$batchId/accept';
  static String prepareKitchenItem(dynamic itemId) => '/v1/kitchen/items/$itemId/prepare';
  static String readyKitchenItem(dynamic itemId) => '/v1/kitchen/items/$itemId/ready';
  static String serveKitchenItem(dynamic itemId) => '/v1/kitchen/items/$itemId/serve';

  // Reports
  static const String salesReport = '/v1/reports/sales';
}

