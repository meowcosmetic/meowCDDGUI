import 'package:flutter/material.dart';
import 'button.dart';
import '../constants/app_colors.dart';


class ButtonDemo extends StatefulWidget {
  final bool showAppBar;
  
  const ButtonDemo({super.key, this.showAppBar = true});

  @override
  State<ButtonDemo> createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  bool _isLoading = false;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Button Demo'),
        backgroundColor: AppColors.cardBorder,
        foregroundColor: AppColors.white,
      ) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Primary Buttons', [
              PrimaryButton(
                text: 'Primary Small',
                size: ButtonSize.small,
                onPressed: () => _showSnackBar('Primary Small pressed'),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'Primary Medium',
                size: ButtonSize.medium,
                onPressed: () => _showSnackBar('Primary Medium pressed'),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'Primary Large',
                size: ButtonSize.large,
                onPressed: () => _showSnackBar('Primary Large pressed'),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'Primary with Icon',
                icon: Icons.add,
                onPressed: () => _showSnackBar('Primary with Icon pressed'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Secondary Buttons', [
              SecondaryButton(
                text: 'Secondary Small',
                size: ButtonSize.small,
                onPressed: () => _showSnackBar('Secondary Small pressed'),
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                text: 'Secondary Medium',
                size: ButtonSize.medium,
                onPressed: () => _showSnackBar('Secondary Medium pressed'),
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                text: 'Secondary Large',
                size: ButtonSize.large,
                onPressed: () => _showSnackBar('Secondary Large pressed'),
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                text: 'Secondary with Icon',
                icon: Icons.edit,
                onPressed: () => _showSnackBar('Secondary with Icon pressed'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Outline Buttons', [
              OutlineButton(
                text: 'Outline Small',
                size: ButtonSize.small,
                onPressed: () => _showSnackBar('Outline Small pressed'),
              ),
              const SizedBox(height: 8),
              OutlineButton(
                text: 'Outline Medium',
                size: ButtonSize.medium,
                onPressed: () => _showSnackBar('Outline Medium pressed'),
              ),
              const SizedBox(height: 8),
              OutlineButton(
                text: 'Outline Large',
                size: ButtonSize.large,
                onPressed: () => _showSnackBar('Outline Large pressed'),
              ),
              const SizedBox(height: 8),
              OutlineButton(
                text: 'Outline with Icon',
                icon: Icons.download,
                onPressed: () => _showSnackBar('Outline with Icon pressed'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Ghost Buttons', [
              GhostButton(
                text: 'Ghost Small',
                size: ButtonSize.small,
                onPressed: () => _showSnackBar('Ghost Small pressed'),
              ),
              const SizedBox(height: 8),
              GhostButton(
                text: 'Ghost Medium',
                size: ButtonSize.medium,
                onPressed: () => _showSnackBar('Ghost Medium pressed'),
              ),
              const SizedBox(height: 8),
              GhostButton(
                text: 'Ghost Large',
                size: ButtonSize.large,
                onPressed: () => _showSnackBar('Ghost Large pressed'),
              ),
              const SizedBox(height: 8),
              GhostButton(
                text: 'Ghost with Icon',
                icon: Icons.info,
                onPressed: () => _showSnackBar('Ghost with Icon pressed'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Destructive Buttons', [
              DestructiveButton(
                text: 'Delete Small',
                size: ButtonSize.small,
                onPressed: () => _showSnackBar('Delete Small pressed'),
              ),
              const SizedBox(height: 8),
              DestructiveButton(
                text: 'Delete Medium',
                size: ButtonSize.medium,
                onPressed: () => _showSnackBar('Delete Medium pressed'),
              ),
              const SizedBox(height: 8),
              DestructiveButton(
                text: 'Delete Large',
                size: ButtonSize.large,
                onPressed: () => _showSnackBar('Delete Large pressed'),
              ),
              const SizedBox(height: 8),
              DestructiveButton(
                text: 'Delete with Icon',
                icon: Icons.delete,
                onPressed: () => _showSnackBar('Delete with Icon pressed'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Loading States', [
              PrimaryButton(
                text: 'Loading Button',
                isLoading: _isLoading,
                onPressed: _toggleLoading,
              ),
              const SizedBox(height: 8),
              OutlineButton(
                text: 'Loading Outline',
                isLoading: _isLoading,
                onPressed: _toggleLoading,
              ),
              const SizedBox(height: 8),
              DestructiveButton(
                text: 'Loading Destructive',
                isLoading: _isLoading,
                onPressed: _toggleLoading,
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Disabled States', [
              PrimaryButton(
                text: 'Disabled Primary',
                disabled: true,
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                text: 'Disabled Secondary',
                disabled: true,
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              OutlineButton(
                text: 'Disabled Outline',
                disabled: true,
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              GhostButton(
                text: 'Disabled Ghost',
                disabled: true,
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              DestructiveButton(
                text: 'Disabled Destructive',
                disabled: true,
                onPressed: () {},
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Custom Width', [
              PrimaryButton(
                text: 'Full Width Button',
                width: double.infinity,
                onPressed: () => _showSnackBar('Full Width Button pressed'),
              ),
              const SizedBox(height: 8),
              OutlineButton(
                text: 'Half Width Button',
                width: 200,
                onPressed: () => _showSnackBar('Half Width Button pressed'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                 Text(
           title,
           style: const TextStyle(
             fontSize: 18,
             fontWeight: FontWeight.bold,
             color: AppColors.primary,
           ),
         ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardBorder,
        duration: const Duration(seconds: 1),
      ),
    );
  }
} 
