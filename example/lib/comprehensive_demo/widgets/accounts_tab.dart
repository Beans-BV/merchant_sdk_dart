import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/company_accounts_provider.dart';
import '../providers/sdk_provider.dart';

class AccountsTab extends ConsumerStatefulWidget {
  const AccountsTab({super.key});

  @override
  ConsumerState<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends ConsumerState<AccountsTab> {
  final _newStellarAccountIdController = TextEditingController();
  final _accountNameEnController = TextEditingController();
  final _accountNameVnController = TextEditingController();

  // Local state to track if we should show the avatar preview
  bool _showAvatarPreview = false;

  @override
  void dispose() {
    _newStellarAccountIdController.dispose();
    _accountNameEnController.dispose();
    _accountNameVnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(companyAccountsProvider);
    final sdk = ref.watch(sdkProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing Accounts
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Existing Accounts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: accountsState.isLoading
                            ? null
                            : () => ref
                                .read(companyAccountsProvider.notifier)
                                .refresh(),
                        icon: accountsState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (accountsState.error != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error: ${accountsState.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (accountsState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (accountsState.accounts.isEmpty)
                    const Text('No accounts found')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: accountsState.accounts.length,
                      itemBuilder: (context, index) {
                        final account = accountsState.accounts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: account.avatarUrl != null
                                ? FutureBuilder<Uint8List?>(
                                    future: sdk.getAvatarUrlBytes(
                                      account.avatarUrl!,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return CircleAvatar(
                                          backgroundImage:
                                              MemoryImage(snapshot.data!),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return const CircleAvatar(
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.error,
                                              color: Colors.white),
                                        );
                                      }
                                      return const CircleAvatar(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.account_circle),
                                  ),
                            title:
                                Text(account.name['en'] ?? 'Unnamed Account'),
                            subtitle: Text(account.stellarAccountId),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAccount(account),
                              tooltip: 'Delete Account',
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Create New Account
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Account',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newStellarAccountIdController,
                    decoration: const InputDecoration(
                        labelText: 'New Stellar Account ID'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _accountNameEnController,
                    decoration: const InputDecoration(
                        labelText: 'Account Name (English)'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _accountNameVnController,
                    decoration: const InputDecoration(
                        labelText: 'Account Name (Vietnamese - Optional)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (kIsWeb)
                        FilledButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Select Avatar'),
                        )
                      else
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Select Avatar'),
                          ),
                        ),
                      const SizedBox(width: 16),
                      if (_showAvatarPreview &&
                          accountsState.selectedImageBytes != null)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Image.memory(accountsState.selectedImageBytes!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (kIsWeb)
                        FilledButton.icon(
                          onPressed: accountsState.isCreatingAccount
                              ? null
                              : _createCompanyAccount,
                          icon: accountsState.isCreatingAccount
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.add),
                          label: const Text('Create Account'),
                        )
                      else
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: accountsState.isCreatingAccount
                                ? null
                                : _createCompanyAccount,
                            icon: accountsState.isCreatingAccount
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.add),
                            label: const Text('Create Account'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        // Get file extension and determine proper MIME type
        final extension = pickedFile.path.split('.').last.toLowerCase();
        String mimeType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            mimeType = 'image/jpeg'; // Default fallback
        }

        ref
            .read(companyAccountsProvider.notifier)
            .setImageSelection(bytes, mimeType);
        setState(() {
          _showAvatarPreview = true;
        });
      }
    } catch (e) {
      _showSnackBar('Error selecting image: $e', isError: true);
    }
  }

  Future<void> _createCompanyAccount() async {
    if (_newStellarAccountIdController.text.isEmpty ||
        _accountNameEnController.text.isEmpty) {
      _showSnackBar('Please fill in Stellar Account ID and English name',
          isError: true);
      return;
    }

    try {
      final name = LanguageString.from({
        'en': _accountNameEnController.text,
      });

      if (_accountNameVnController.text.isNotEmpty) {
        name['vn'] = _accountNameVnController.text;
      }

      await ref.read(companyAccountsProvider.notifier).createAccount(
            stellarAccountId: _newStellarAccountIdController.text,
            name: name,
          );

      _showSnackBar('Company account created successfully!');

      // Clear the form fields after successful creation
      _newStellarAccountIdController.clear();
      _accountNameEnController.clear();
      _accountNameVnController.clear();

      // Clear both provider state and local state
      ref.read(companyAccountsProvider.notifier).clearImageSelection();
      setState(() {
        _showAvatarPreview = false;
      });
    } catch (e) {
      _showSnackBar('Failed to create company account: $e', isError: true);
    }
  }

  Future<void> _deleteAccount(CompanyAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
            'Are you sure you want to delete account "${account.name['en']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(companyAccountsProvider.notifier)
          .deleteAccount(account.stellarAccountId);
      _showSnackBar('Account deleted successfully!');
    } catch (e) {
      _showSnackBar('Failed to delete account: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
