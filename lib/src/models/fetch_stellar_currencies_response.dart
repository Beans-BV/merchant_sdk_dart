import 'stellar_currency.dart';

class FetchStellarCurrenciesResponse {
  FetchStellarCurrenciesResponse({
    required this.stellarCurrencies,
  });

  final List<StellarCurrency> stellarCurrencies;

  factory FetchStellarCurrenciesResponse.fromJson(Map<String, dynamic> json) {
    return FetchStellarCurrenciesResponse(
      stellarCurrencies: List<StellarCurrency>.from(
          json['stellarCurrencies'].map((x) => StellarCurrency.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stellarCurrencies': stellarCurrencies.map((x) => x.toJson()).toList(),
    };
  }
}
