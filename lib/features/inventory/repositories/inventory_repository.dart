import '../../../core/api/api_endpoint.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/dio_client.dart';
import '../models/stock_info_model.dart';

class InventoryRepository {
  final DioClient dioClient;

  InventoryRepository({required this.dioClient});

  /// Fetch menus and extract stock information
  Future<ApiResponse<List<StockInfoModel>>> getMenuInventory({bool forceRefresh = false}) async {
    final response = await dioClient.get(
      ApiEndpoint.menus,
      queryParameters: forceRefresh ? {'refresh': 1} : null,
    );

    final responseData = response.data;
    List<dynamic> list = [];

    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final dataField = responseData['data'];
      if (dataField is List) {
        list = dataField;
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final List<StockInfoModel> stockItems = [];

    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final menuStock = StockInfoModel.fromMenuJson(item);
        stockItems.add(menuStock);

        final variants = item['variants'];
        if (variants is List) {
          for (final v in variants) {
            if (v is Map<String, dynamic>) {
              stockItems.add(
                StockInfoModel.fromVariantJson(
                  v,
                  menuId: menuStock.menuId,
                  menuName: menuStock.menuName,
                ),
              );
            }
          }
        }
      }
    }

    return ApiResponse<List<StockInfoModel>>.success(
      data: stockItems,
      statusCode: response.statusCode,
    );
  }

  /// Refreshes inventory data by busting cache
  Future<ApiResponse<List<StockInfoModel>>> refreshInventory() {
    return getMenuInventory(forceRefresh: true);
  }
}

