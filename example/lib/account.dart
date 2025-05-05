import 'dart:typed_data';

import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:example/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _stellarAccountIdController =
      TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameVnController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _selectedImageMimeType;
  CompanyAccount? _createdAccount;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _deleteStatus;
  List<CompanyAccount> _accounts = [];
  bool _isLoadingAccounts = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _stellarAccountIdController.dispose();
    _nameEnController.dispose();
    _nameVnController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
      _errorMessage = null;
    });

    try {
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.beansApiKey);
      final accounts = await sdk.getCompanyAccounts();
      setState(() {
        _accounts = accounts;
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading accounts: $e';
        _isLoadingAccounts = false;
      });
    }
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
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageMimeType = 'image/${pickedFile.path.split('.').last}';
          if (_selectedImageMimeType == 'image/jpg') {
            _selectedImageMimeType = 'image/jpeg';
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error when selecting image: $e';
      });
    }
  }

  Future<void> _createAccount() async {
    final stellarAccountId = _stellarAccountIdController.text.trim();
    final nameEn = _nameEnController.text.trim();
    final nameVn = _nameVnController.text.trim();

    if (stellarAccountId.isEmpty || nameEn.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in Stellar Account ID and English name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.beansApiKey);

      final Map<String, String> name = {
        'en': nameEn,
      };

      if (nameVn.isNotEmpty) {
        name['vn'] = nameVn;
      }

      final response = await sdk.createCompanyAccount(
        stellarAccountId,
        name,
      );

      setState(() {
        _createdAccount = response.account;
        _isLoading = false;
      });

      // Refresh accounts list
      await _loadAccounts();

      // Upload avatar if an image is selected
      if (_selectedImageBytes != null && _selectedImageMimeType != null) {
        _uploadAvatar();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error when creating account: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadAvatar() async {
    if (_createdAccount == null ||
        _selectedImageBytes == null ||
        _selectedImageMimeType == null) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.beansApiKey);
      final updatedAccount = await sdk.uploadCompanyAccountAvatar(
        'me',
        _createdAccount!.stellarAccountId,
        _selectedImageBytes!,
        _selectedImageMimeType!,
      );
      setState(() {
        _createdAccount = updatedAccount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error when uploading avatar: $e';
        _isLoading = false;
      });
    }
  }

  Future<Uint8List?> _getAvatar() async {
    if (_createdAccount?.avatarId == null) {
      return null;
    }
    try {
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.beansApiKey);
      return await sdk.getCompanyAccountAvatar(
        'me',
        _createdAccount!.id,
        _createdAccount!.avatarId!,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error when getting avatar: $e';
      });
      return null;
    }
  }

  Future<void> _deleteAccount() async {
    if (_createdAccount == null) {
      setState(() {
        _errorMessage = 'No account to delete';
      });
      return;
    }

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
      _deleteStatus = null;
    });

    try {
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.beansApiKey);
      final response = await sdk.deleteCompanyAccount(
        _createdAccount!.stellarAccountId,
      );

      setState(() {
        _deleteStatus =
            'account deleted successfully. Status: ${response.status}';
        _isDeleting = false;
      });

      // Refresh accounts list
      await _loadAccounts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error when deleting account: $e';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('account management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accounts List Section
            const Text(
              'Existing accounts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoadingAccounts)
              const Center(child: CircularProgressIndicator())
            else if (_accounts.isEmpty)
              const Text('No accounts found')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _accounts.length,
                itemBuilder: (context, index) {
                  final account = _accounts[index];
                  return Card(
                    child: ListTile(
                      leading: account.avatarId != null
                          ? FutureBuilder<Uint8List?>(
                              future: BeansMerchantSdk.staging(
                                      apiKey: Constants.beansApiKey)
                                  .getCompanyAccountAvatar(
                                'me',
                                account.id,
                                account.avatarId!,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return CircleAvatar(
                                    backgroundImage:
                                        MemoryImage(snapshot.data!),
                                  );
                                }
                                return const CircleAvatar(
                                  child: Icon(Icons.account_circle),
                                );
                              },
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.account_circle),
                            ),
                      title: Text(account.name['en'] ?? 'Unnamed Account'),
                      subtitle: Text(account.stellarAccountId),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          if (await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete account'),
                                  content: const Text(
                                    'Are you sure you want to delete this account? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false) {
                            setState(() {
                              _createdAccount = account;
                            });
                            await _deleteAccount();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Create New account Section
            const Text(
              'Create new account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stellarAccountIdController,
              decoration: const InputDecoration(
                labelText: 'Stellar Account ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameEnController,
              decoration: const InputDecoration(
                labelText: 'Name (English)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameVnController,
              decoration: const InputDecoration(
                labelText: 'Name (Vietnamese - Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Select avatar'),
                ),
                const SizedBox(width: 16),
                if (_selectedImageBytes != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(_selectedImageBytes!),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _createAccount,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create an account'),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withOpacity(0.1),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
            if (_createdAccount != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Information of created an account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _deleteAccount,
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_deleteStatus != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.green.withOpacity(0.1),
                  child: Text(
                    _deleteStatus!,
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildInfoRow('ID:', _createdAccount!.id),
              _buildInfoRow('Company ID:', _createdAccount!.companyId),
              _buildInfoRow(
                  'Stellar Account ID:', _createdAccount!.stellarAccountId),
              _buildInfoRow('Name (EN):', _createdAccount!.name['en'] ?? 'N/A'),
              _buildInfoRow('Name (VN):', _createdAccount!.name['vn'] ?? 'N/A'),
              if (_createdAccount!.avatarId != null) ...[
                const SizedBox(height: 16),
                const Text('Avatar:'),
                const SizedBox(height: 8),
                FutureBuilder<Uint8List?>(
                  future: _getAvatar(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Text('Unable to load avatar');
                    }
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.memory(snapshot.data!),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
