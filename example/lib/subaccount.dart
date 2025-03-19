import 'dart:io';
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

  @override
  void dispose() {
    _stellarAccountIdController.dispose();
    _nameEnController.dispose();
    _nameViController.dispose();
    super.dispose();
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
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.companyApiKey);
      
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
    if (_createdAccount == null || _selectedImageBytes == null || _selectedImageMimeType == null) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.companyApiKey);
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
      final sdk = BeansMerchantSdk.staging(apiKey: Constants.companyApiKey);
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
            const Text(
              'Create new sub-account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Form to create sub-account
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
            // Avatar selection part
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
              // Create sub-account button
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
            // Display information of created sub-account
            if (_createdAccount != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Information of created sub-account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('ID:', _createdAccount!.id),
              _buildInfoRow('Company ID:', _createdAccount!.companyId),
              _buildInfoRow('Stellar Account ID:', _createdAccount!.stellarAccountId),
              _buildInfoRow('Name (EN):', _createdAccount!.name.en ?? 'N/A'),
              _buildInfoRow('Name (VI):', _createdAccount!.name.vi ?? 'N/A'),
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