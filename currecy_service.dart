import 'package:http/http.dart' as http;
import 'package:vccm/utils/constants.dart';

class CurrencyService {
  static const _exchangeRateApi = 'https://open.er-api.com/v6/latest/MWK';

  Future<double> getUsdExchangeRate() async {
    try {
      final response = await http.get(Uri.parse(_exchangeRateApi));
      if (response.statusCode == 200) {
        final rates = jsonDecode(response.body)['rates'];
        return rates['USD'] ?? 0.00058; // Fallback rate
      }
      return 0.00058;
    } catch (e) {
      return 0.00058;
    }
  }

  double convertToUsd(double mwkAmount, double rate) {
    return mwkAmount * rate;
  }

  double convertToMwk(double usdAmount, double rate) {
    return usdAmount / rate;
  }
}