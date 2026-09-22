import 'package:get/get.dart';
import 'package:yogo_pos/app/services/base/base_model.dart';
import 'package:yogo_pos/app/services/controller/base_controller.dart';
import 'package:yogo_pos/app/utils/urls.dart';
import '../../../utils/logger.dart';
import '../models/transaction_model.dart';


class TransactionController extends GetxController {
  var transactions = <Transaction>[].obs;
  var meta = Rxn<Meta>();

  // var response = Rxn<Meta>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;



// get user/ all transaction
  Future<void> fetchTransactions({String? cardSearch,String? tcnNo,String? invNo,String? page}) async {
    try {
      isLoading(true);

      Map<String, dynamic> queryParameters = {
        if (cardSearch != null) "CID": cardSearch,
        if (tcnNo != null) "TCN": tcnNo,
        if (invNo != null) "INV": invNo,
        if (page != null) "page": page,
        "limit": 4
      };

      BaseModel response = await BaseController.to.apiService.makeGetRequest(URLS.getAllCardTransaction,queryParameters:  queryParameters);
      // final response = await _dio.get(
      //   '{{API_URL}}/datacandy/pos/transection/restaurant?search=6360879999997164549',
      // );


      if (response.statusCode == 200) {
       final  transactionResponse = TransactionResponse.fromJson(response.data);
        // this.response.value=transactionResponse.meta;

        // transactions.assignAll(transactionResponse.data ?? []);
        kLogger.e("${transactionResponse.data.length}");
        transactions.assignAll(transactionResponse.data );
        meta.value = transactionResponse.meta;
        kLogger.e(meta.value?.toJson());
        for(int i=0; i<=transactions.length; i++){
          // print(transactions[i].amt);
        }



        update();
        // transactions[0].operation;
      } else {
        errorMessage('Failed to load transactions');
      }
    } catch (e) {
      errorMessage('Error: $e');
    } finally {
      isLoading(false);
    }
  }


  // @override
  // void onInit() {
  //   fetchTransactions();
  //   super.onInit();
  // }
}