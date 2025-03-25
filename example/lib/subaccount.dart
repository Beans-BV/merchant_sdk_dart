import 'dart:typed_data';

import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:example/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SubAccountScreen extends StatefulWidget {
  const SubAccountScreen({super.key});

  @override
  State<SubAccountScreen> createState() => _SubAccountScreenState();
}

class _SubAccountScreenState extends State<SubAccountScreen> {
  final TextEditingController _stellarAccountIdController =
      TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _nameViController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _selectedImageMimeType;
  CompanyAccount? _createdAccount;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _deleteStatus;
  List<CompanyAccount> _subaccounts = [];
  bool _isLoadingSubaccounts = false;

  @override
  void initState() {
    super.initState();
    _loadSubaccounts();
  }

  @override
  void dispose() {
    _stellarAccountIdController.dispose();
    _nameEnController.dispose();
    _nameViController.dispose();
    super.dispose();
  }

  Future<void> _loadSubaccounts() async {
    setState(() {
      _isLoadingSubaccounts = true;
      _errorMessage = null;
    });

    try {
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.beansApiKey);
      final accounts = await sdk.getMerchantAccounts();
      setState(() {
        _subaccounts = accounts;
        _isLoadingSubaccounts = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading subaccounts: $e';
        _isLoadingSubaccounts = false;
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

  Future<void> _createSubAccount() async {
    final stellarAccountId = _stellarAccountIdController.text.trim();
    final nameEn = _nameEnController.text.trim();
    final nameVi = _nameViController.text.trim();

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

      if (nameVi.isNotEmpty) {
        name['vi'] = nameVi;
      }

      final response = await sdk.createCompanyAccount(
        stellarAccountId,
        name,
      );

      setState(() {
        _createdAccount = response.account;
        _isLoading = false;
      });

      // Refresh subaccounts list
      await _loadSubaccounts();

      // Upload avatar if an image is selected
      if (_selectedImageBytes != null && _selectedImageMimeType != null) {
        _uploadAvatar();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error when creating sub-account: $e';
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

  Future<void> _deleteSubAccount() async {
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
            'Sub-account deleted successfully. Status: ${response.status}';
        _isDeleting = false;
      });

      // Refresh subaccounts list
      await _loadSubaccounts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error when deleting sub-account: $e';
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sub-account management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subaccounts List Section
            const Text(
              'Existing Sub-accounts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoadingSubaccounts)
              const Center(child: CircularProgressIndicator())
            else if (_subaccounts.isEmpty)
              const Text('No sub-accounts found')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subaccounts.length,
                itemBuilder: (context, index) {
                  final account = _subaccounts[index];
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
                                  title: const Text('Delete Sub-account'),
                                  content: const Text(
                                    'Are you sure you want to delete this sub-account? This action cannot be undone.',
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
                            await _deleteSubAccount();
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

            // Create New Sub-account Section
            const Text(
              'Create new sub-account',
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
              controller: _nameViController,
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
                onPressed: _isLoading ? null : _createSubAccount,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create sub-account'),
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
                    'Information of created sub-account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _deleteSubAccount,
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
              _buildInfoRow('Name (VI):', _createdAccount!.name['vi'] ?? 'N/A'),
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
