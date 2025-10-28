import 'dart:typed_data';

import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sdk_provider.dart';

/// Provider for company accounts state
final companyAccountsProvider =
    StateNotifierProvider<CompanyAccountsNotifier, CompanyAccountsState>((ref) {
  final sdk = ref.watch(sdkProvider);
  return CompanyAccountsNotifier(sdk);
});

/// Company Accounts State
class CompanyAccountsState {
  final List<CompanyAccount> accounts;
  final bool isLoading;
  final String? error;
  final CompanyAccount? selectedAccount;
  final bool isCreatingAccount;
  final bool isUploadingAvatar;
  final bool isDeletingAccount;
  final Uint8List? selectedImageBytes;
  final String? selectedImageMimeType;

  const CompanyAccountsState({
    this.accounts = const [],
    this.isLoading = false,
    this.error,
    this.selectedAccount,
    this.isCreatingAccount = false,
    this.isUploadingAvatar = false,
    this.isDeletingAccount = false,
    this.selectedImageBytes,
    this.selectedImageMimeType,
  });

  CompanyAccountsState copyWith({
    List<CompanyAccount>? accounts,
    bool? isLoading,
    String? error,
    CompanyAccount? selectedAccount,
    bool? isCreatingAccount,
    bool? isUploadingAvatar,
    bool? isDeletingAccount,
    Uint8List? selectedImageBytes,
    String? selectedImageMimeType,
  }) {
    return CompanyAccountsState(
      accounts: accounts ?? this.accounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      isCreatingAccount: isCreatingAccount ?? this.isCreatingAccount,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      selectedImageBytes: selectedImageBytes ?? this.selectedImageBytes,
      selectedImageMimeType:
          selectedImageMimeType ?? this.selectedImageMimeType,
    );
  }
}

/// Company Accounts Notifier
class CompanyAccountsNotifier extends StateNotifier<CompanyAccountsState> {
  final BeansMerchantSdk _sdk;

  CompanyAccountsNotifier(this._sdk) : super(const CompanyAccountsState());

  Future<void> loadAccounts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _sdk.getCompanyAccounts();
      final accounts = response.accounts;

      state = state.copyWith(
        accounts: accounts,
        isLoading: false,
        selectedAccount: accounts.isNotEmpty ? accounts.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectAccount(CompanyAccount? account) {
    state = state.copyWith(selectedAccount: account);
  }

  void setImageSelection(Uint8List? bytes, String? mimeType) {
    state = state.copyWith(
      selectedImageBytes: bytes,
      selectedImageMimeType: mimeType,
    );
  }

  void clearImageSelection() {
    state = state.copyWith(
      selectedImageBytes: null,
      selectedImageMimeType: null,
    );
  }

  Future<void> createAccount({
    required String stellarAccountId,
    required LanguageString name,
  }) async {
    state = state.copyWith(isCreatingAccount: true, error: null);

    try {
      await _sdk.createCompanyAccount(stellarAccountId, name);

      // Upload avatar if selected
      if (state.selectedImageBytes != null &&
          state.selectedImageMimeType != null) {
        await _uploadAvatarForNewAccount(stellarAccountId);
      }

      // Clear form data and reload accounts
      state = state.copyWith(
        isCreatingAccount: false,
      );

      // Reload accounts
      await loadAccounts();
    } catch (e) {
      state = state.copyWith(
        isCreatingAccount: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _uploadAvatarForNewAccount(String stellarAccountId) async {
    if (state.selectedImageBytes == null ||
        state.selectedImageMimeType == null) {
      return;
    }

    state = state.copyWith(isUploadingAvatar: true);

    try {
      String mimeType = state.selectedImageMimeType!;

      // Fix common MIME type issues
      if (mimeType == 'image/jpg') {
        mimeType = 'image/jpeg';
      }

      // Validate MIME type format
      if (!mimeType.startsWith('image/')) {
        throw Exception('Invalid image format. Please select a valid image.');
      }

      await _sdk.uploadCompanyAccountAvatar(
        'me',
        stellarAccountId,
        state.selectedImageBytes!,
        mimeType,
      );

      state = state.copyWith(isUploadingAvatar: false);
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteAccount(String stellarAccountId) async {
    state = state.copyWith(isDeletingAccount: true, error: null);

    try {
      await _sdk.deleteCompanyAccount(stellarAccountId);
      state = state.copyWith(isDeletingAccount: false);
      await loadAccounts();
    } catch (e) {
      state = state.copyWith(
        isDeletingAccount: false,
        error: e.toString(),
      );
    }
  }

  void refresh() {
    loadAccounts();
  }
}
