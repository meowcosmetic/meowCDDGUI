import 'package:flutter/material.dart';
import 'loading.dart';
import '../constants/app_colors.dart';

class LoadingDemo extends StatelessWidget {
  final bool showAppBar;

  const LoadingDemo({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Loading Components Demo'),
              backgroundColor: AppColors.cardBorder,
              foregroundColor: AppColors.white,
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Circular Loading',
              'Các kiểu loading tròn với kích thước khác nhau',
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CircularLoading(size: LoadingSize.small),
                    const CircularLoading(size: LoadingSize.medium),
                    const CircularLoading(size: LoadingSize.large),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircularLoading(
                      size: LoadingSize.medium,
                      color: AppColors.cardBorder,
                      text: 'Loading...',
                      showText: true,
                    ),
                    CircularLoading(
                      size: LoadingSize.medium,
                      color: AppColors.green,
                      text: 'Processing...',
                      showText: true,
                    ),
                    CircularLoading(
                      size: LoadingSize.medium,
                      color: AppColors.orange,
                      text: 'Please wait...',
                      showText: true,
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(
              context,
              'Linear Loading',
              'Loading dạng thanh ngang',
              [
                const LinearLoading(
                  size: LoadingSize.small,
                  text: 'Uploading...',
                  showText: true,
                ),
                const SizedBox(height: 16),
                const LinearLoading(
                  size: LoadingSize.medium,
                  text: 'Downloading...',
                  showText: true,
                ),
                const SizedBox(height: 16),
                LinearLoading(
                  size: LoadingSize.large,
                  color: AppColors.purple,
                  text: 'Installing...',
                  showText: true,
                ),
              ],
            ),
            _buildSection(
              context,
              'Skeleton Loading',
              'Loading dạng skeleton cho content',
              [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SkeletonLoading(
                            size: LoadingSize.small,
                            width: double.infinity,
                            height: 20,
                          ),
                          const SizedBox(height: 8),
                          SkeletonLoading(
                            size: LoadingSize.medium,
                            width: double.infinity,
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SkeletonLoading(
                      size: LoadingSize.large,
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(
              context,
              'Dots Loading',
              'Loading dạng chấm nhấp nháy',
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const DotsLoading(size: LoadingSize.small),
                    const DotsLoading(size: LoadingSize.medium),
                    const DotsLoading(size: LoadingSize.large),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DotsLoading(
                      size: LoadingSize.medium,
                      color: AppColors.red,
                      text: 'Connecting...',
                      showText: true,
                    ),
                    DotsLoading(
                      size: LoadingSize.medium,
                      color: AppColors.cardBorder,
                      text: 'Syncing...',
                      showText: true,
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(context, 'Pulse Loading', 'Loading dạng xung động', [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const PulseLoading(size: LoadingSize.small),
                  const PulseLoading(size: LoadingSize.medium),
                  const PulseLoading(size: LoadingSize.large),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PulseLoading(
                    size: LoadingSize.medium,
                    color: AppColors.teal,
                    text: 'Searching...',
                    showText: true,
                  ),
                  PulseLoading(
                    size: LoadingSize.medium,
                    color: AppColors.indigo,
                    text: 'Analyzing...',
                    showText: true,
                  ),
                ],
              ),
            ]),
            _buildSection(
              context,
              'Custom Loading',
              'Loading với màu sắc và kích thước tùy chỉnh',
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Loading(
                      type: LoadingType.circular,
                      size: LoadingSize.medium,
                      color: AppColors.deepPurple,
                      width: 40,
                      height: 40,
                    ),
                    Loading(
                      type: LoadingType.dots,
                      size: LoadingSize.large,
                      color: AppColors.amber,
                      width: 80,
                      height: 40,
                    ),
                    Loading(
                      type: LoadingType.pulse,
                      size: LoadingSize.small,
                      color: AppColors.pink,
                      width: 30,
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
            _buildSection(
              context,
              'Loading trong Container',
              'Loading được đặt trong container có background',
              [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const CircularLoading(
                        size: LoadingSize.medium,
                        text: 'Loading data...',
                        showText: true,
                      ),
                      const SizedBox(height: 16),
                      const LinearLoading(
                        size: LoadingSize.medium,
                        text: 'Progress: 45%',
                        showText: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.cardBorder),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardBorder.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
