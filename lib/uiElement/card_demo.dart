import 'package:flutter/material.dart';
import 'card.dart';
import 'button.dart';
import '../constants/app_colors.dart';


class CardDemo extends StatelessWidget {
  final bool showAppBar;
  
  const CardDemo({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Card Demo'),
        backgroundColor: AppColors.cardBorder,
        foregroundColor: AppColors.white,
      ) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Default Cards', [
              MeowCard(
                title: 'Default Card',
                description: 'This is a default card with title and description',
                content: const Text('This is the content area of the card. You can put any widget here.'),
                onTap: () => _showSnackBar(context, 'Default card tapped'),
              ),
              const SizedBox(height: 16),
              MeowCard(
                title: 'Card with Leading Icon',
                description: 'Card with an icon on the left side',
                leading: const Icon(Icons.star, color: AppColors.amber, size: 24),
                content: const Text('This card has a leading icon.'),
                onTap: () => _showSnackBar(context, 'Card with leading icon tapped'),
              ),
              const SizedBox(height: 16),
              MeowCard(
                title: 'Card with Actions',
                description: 'Card with action buttons at the bottom',
                content: const Text('This card has action buttons.'),
                actions: [
                  GhostButton(
                    text: 'Cancel',
                    size: ButtonSize.small,
                    onPressed: () => _showSnackBar(context, 'Cancel pressed'),
                  ),
                  PrimaryButton(
                    text: 'Save',
                    size: ButtonSize.small,
                    onPressed: () => _showSnackBar(context, 'Save pressed'),
                  ),
                ],
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Elevated Cards', [
              ElevatedMeowCard(
                title: 'Elevated Card',
                description: 'This card has elevation and shadow',
                content: const Text('Elevated cards have a shadow effect.'),
                onTap: () => _showSnackBar(context, 'Elevated card tapped'),
              ),
              const SizedBox(height: 16),
              ElevatedMeowCard(
                title: 'Elevated Card with Trailing',
                description: 'Card with trailing widget on the right',
                trailing: const Icon(Icons.more_vert, color: AppColors.primary),
                content: const Text('This card has a trailing icon.'),
                onTap: () => _showSnackBar(context, 'Elevated card with trailing tapped'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Outlined Cards', [
              OutlinedMeowCard(
                title: 'Outlined Card',
                description: 'This card has a border outline',
                content: const Text('Outlined cards have a visible border.'),
                onTap: () => _showSnackBar(context, 'Outlined card tapped'),
              ),
              const SizedBox(height: 16),
              OutlinedMeowCard(
                title: 'Custom Border Color',
                description: 'Card with custom border color',
                borderColor: AppColors.cardBorder,
                content: const Text('This card has a green border.'),
                onTap: () => _showSnackBar(context, 'Custom border card tapped'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Filled Cards', [
              FilledMeowCard(
                title: 'Filled Card',
                description: 'This card has a filled background',
                content: const Text('Filled cards have a background color.'),
                onTap: () => _showSnackBar(context, 'Filled card tapped'),
              ),
              const SizedBox(height: 16),
              FilledMeowCard(
                title: 'Custom Background',
                description: 'Card with custom background color',
                backgroundColor: AppColors.primaryLight,
                content: const Text('This card has a light green background.'),
                onTap: () => _showSnackBar(context, 'Custom background card tapped'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Card Sizes', [
              MeowCard(
                title: 'Small Card',
                description: 'Small size card',
                size: CardSize.small,
                content: const Text('This is a small card.'),
                onTap: () => _showSnackBar(context, 'Small card tapped'),
              ),
              const SizedBox(height: 16),
              MeowCard(
                title: 'Medium Card',
                description: 'Medium size card (default)',
                size: CardSize.medium,
                content: const Text('This is a medium card.'),
                onTap: () => _showSnackBar(context, 'Medium card tapped'),
              ),
              const SizedBox(height: 16),
              MeowCard(
                title: 'Large Card',
                description: 'Large size card',
                size: CardSize.large,
                content: const Text('This is a large card.'),
                onTap: () => _showSnackBar(context, 'Large card tapped'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Complex Cards', [
              MeowCard(
                title: 'Product Card',
                description: 'Premium Product',
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag, color: AppColors.white, size: 30),
                ),
                trailing: const Text(
                  '\$99.99',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Features:'),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Text('Feature 1'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Text('Feature 2'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check, color: AppColors.primary, size: 16),
                        SizedBox(width: 8),
                        Text('Feature 3'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  OutlineButton(
                    text: 'Details',
                    size: ButtonSize.small,
                    onPressed: () => _showSnackBar(context, 'Details pressed'),
                  ),
                  PrimaryButton(
                    text: 'Buy Now',
                    size: ButtonSize.small,
                    onPressed: () => _showSnackBar(context, 'Buy Now pressed'),
                  ),
                ],
                onTap: () => _showSnackBar(context, 'Product card tapped'),
              ),
              const SizedBox(height: 16),
              MeowCard(
                title: 'Article Card',
                description: 'Published on March 15, 2024',
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.article, color: AppColors.white),
                ),
                trailing: const Icon(Icons.bookmark_border, color: AppColors.primary),
                content: const Text(
                  'This is a sample article content. It can contain a longer text that describes the article or provides a preview of the content. The text can span multiple lines and provide rich information to the user.',
                  style: TextStyle(height: 1.5),
                ),
                actions: [
                  GhostButton(
                    text: 'Share',
                    size: ButtonSize.small,
                    icon: Icons.share,
                    onPressed: () => _showSnackBar(context, 'Share pressed'),
                  ),
                  PrimaryButton(
                    text: 'Read More',
                    size: ButtonSize.small,
                    onPressed: () => _showSnackBar(context, 'Read More pressed'),
                  ),
                ],
                onTap: () => _showSnackBar(context, 'Article card tapped'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Cards without Divider', [
              MeowCard(
                title: 'No Divider Card',
                description: 'This card has no divider between header and content',
                content: const Text('The divider is hidden in this card.'),
                showDivider: false,
                onTap: () => _showSnackBar(context, 'No divider card tapped'),
              ),
            ]),
            
            const SizedBox(height: 24),
            _buildSection('Custom Styled Cards', [
              MeowCard(
                title: 'Custom Styled Card',
                description: 'Card with custom colors and border radius',
                backgroundColor: AppColors.cardBackground,
                borderColor: AppColors.cardBorder,
                borderRadius: 16,
                content: const Text('This card has custom styling.'),
                onTap: () => _showSnackBar(context, 'Custom styled card tapped'),
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardBorder,
        duration: const Duration(seconds: 1),
      ),
    );
  }
} 
