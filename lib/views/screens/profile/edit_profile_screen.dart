import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/auth_viewmodel.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _avatarUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.user != null) {
        _avatarUrlController.text = authVM.user!.avatarUrl ?? '';
      }
    });
  }

  Future<void> _saveProfile(AuthViewModel authVM) async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = authVM.user!.copyWith(
        avatarUrl: _avatarUrlController.text.trim().isEmpty
            ? null
            : _avatarUrlController.text.trim(),
        updatedAt: DateTime.now(),
      );
      final success = await authVM.updateUser(updatedUser);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Update failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _avatarUrlController,
                label: 'Avatar URL',
                hintText: 'https://example.com/avatar.png',
              ),
              const SizedBox(height: 16),
              Consumer<AuthViewModel>(
                builder: (context, authVM, _) => CustomTextField(
                  controller:
                      TextEditingController(text: authVM.user?.email ?? ''),
                  label: 'Email',
                  hintText: 'email@example.com',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, _) => CustomButton(
                    text: 'Save Changes',
                    isLoading: authVM.isLoading,
                    onPressed: () => _saveProfile(authVM),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _avatarUrlController.dispose();
    super.dispose();
  }
}
