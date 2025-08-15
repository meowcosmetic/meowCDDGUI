#!/usr/bin/env python3
"""
Script để thay thế các màu hardcode bằng AppColors
Sử dụng: python scripts/replace_colors.py
"""

import os
import re
import glob
from pathlib import Path

# Định nghĩa các mapping màu
COLOR_MAPPINGS = {
    # Primary colors
    r'const Color\(0xFF4CAF50\)': 'AppColors.primary',
    r'Color\(0xFF4CAF50\)': 'AppColors.primary',
    
    # Opacity variants
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.1\)': 'AppColors.primaryWithOpacity10',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.2\)': 'AppColors.primaryWithOpacity20',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.3\)': 'AppColors.primaryWithOpacity30',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.4\)': 'AppColors.primaryWithOpacity40',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.5\)': 'AppColors.primaryWithOpacity50',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.6\)': 'AppColors.primaryWithOpacity60',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.7\)': 'AppColors.primaryWithOpacity70',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.8\)': 'AppColors.primaryWithOpacity80',
    r'const Color\(0xFF4CAF50\)\.withOpacity\(0\.9\)': 'AppColors.primaryWithOpacity90',
    
    # Custom colors
    r'const Color\(0xFFE8F5E8\)': 'AppColors.primaryLight',
    r'const Color\(0xFFF0F8F0\)': 'AppColors.primaryLighter',
    r'const Color\(0xFFF0F8F0\)': 'AppColors.cardBackground',
    r'const Color\(0xFF4CAF50\)': 'AppColors.cardBorder',
    
    # Material colors
    r'Colors\.white': 'AppColors.white',
    r'Colors\.black': 'AppColors.black',
    r'Colors\.transparent': 'AppColors.transparent',
    r'Colors\.grey\[50\]': 'AppColors.grey50',
    r'Colors\.grey\[100\]': 'AppColors.grey100',
    r'Colors\.grey\[200\]': 'AppColors.grey200',
    r'Colors\.grey\[300\]': 'AppColors.grey300',
    r'Colors\.grey\[400\]': 'AppColors.grey400',
    r'Colors\.grey\[500\]': 'AppColors.grey500',
    r'Colors\.grey\[600\]': 'AppColors.grey600',
    r'Colors\.grey\[700\]': 'AppColors.grey700',
    r'Colors\.grey\[800\]': 'AppColors.grey800',
    r'Colors\.grey\[900\]': 'AppColors.grey900',
    r'Colors\.grey': 'AppColors.materialGrey',
    
    # Text colors
    r'Colors\.black87': 'AppColors.textPrimary',
    r'Colors\.black\.withOpacity\(0\.1\)': 'AppColors.blackWithOpacity10',
    r'Colors\.black\.withOpacity\(0\.2\)': 'AppColors.blackWithOpacity20',
    r'Colors\.black\.withOpacity\(0\.3\)': 'AppColors.blackWithOpacity30',
    r'Colors\.black\.withOpacity\(0\.4\)': 'AppColors.blackWithOpacity40',
    r'Colors\.black\.withOpacity\(0\.5\)': 'AppColors.blackWithOpacity50',
    r'Colors\.black\.withOpacity\(0\.6\)': 'AppColors.blackWithOpacity60',
    r'Colors\.black\.withOpacity\(0\.7\)': 'AppColors.blackWithOpacity70',
    r'Colors\.black\.withOpacity\(0\.8\)': 'AppColors.blackWithOpacity80',
    r'Colors\.black\.withOpacity\(0\.9\)': 'AppColors.blackWithOpacity90',
    
    # Theme colors
    r'Colors\.green': 'AppColors.green',
    r'Colors\.purple': 'AppColors.purple',
    r'Colors\.orange': 'AppColors.orange',
    r'Colors\.red': 'AppColors.red',
    r'Colors\.teal': 'AppColors.teal',
    r'Colors\.indigo': 'AppColors.indigo',
    r'Colors\.deepPurple': 'AppColors.deepPurple',
    r'Colors\.amber': 'AppColors.amber',
    r'Colors\.pink': 'AppColors.pink',
}

def add_app_colors_import(content, file_path):
    """Thêm import AppColors nếu chưa có"""
    if 'import' in content and 'app_colors.dart' not in content:
        # Tìm dòng import cuối cùng
        lines = content.split('\n')
        import_lines = []
        other_lines = []
        
        for line in lines:
            if line.strip().startswith('import'):
                import_lines.append(line)
            else:
                other_lines.append(line)
        
        # Thêm import AppColors
        relative_path = get_relative_path_to_app_colors(file_path)
        app_colors_import = f"import '{relative_path}';"
        
        if app_colors_import not in import_lines:
            import_lines.append(app_colors_import)
        
        # Ghép lại
        return '\n'.join(import_lines + [''] + other_lines)
    
    return content

def get_relative_path_to_app_colors(file_path):
    """Tính đường dẫn tương đối đến app_colors.dart"""
    file_dir = os.path.dirname(file_path)
    lib_dir = os.path.join(os.getcwd(), 'lib')
    
    # Đếm số thư mục cần đi lên
    rel_path = os.path.relpath(lib_dir, file_dir)
    return os.path.join(rel_path, 'constants', 'app_colors.dart').replace('\\', '/')

def process_file(file_path):
    """Xử lý một file Dart"""
    print(f"Đang xử lý: {file_path}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Thay thế các màu
        for pattern, replacement in COLOR_MAPPINGS.items():
            content = re.sub(pattern, replacement, content)
        
        # Thêm import AppColors nếu có thay đổi
        if content != original_content:
            content = add_app_colors_import(content, file_path)
            
            # Ghi lại file
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"  ✓ Đã cập nhật: {file_path}")
        else:
            print(f"  - Không có thay đổi: {file_path}")
            
    except Exception as e:
        print(f"  ✗ Lỗi khi xử lý {file_path}: {e}")

def main():
    """Hàm chính"""
    print("Bắt đầu thay thế màu sắc...")
    
    # Tìm tất cả file Dart trong thư mục lib
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    # Loại bỏ file app_colors.dart
    dart_files = [f for f in dart_files if 'app_colors.dart' not in f]
    
    print(f"Tìm thấy {len(dart_files)} file Dart để xử lý")
    
    for file_path in dart_files:
        process_file(file_path)
    
    print("\nHoàn thành thay thế màu sắc!")

if __name__ == "__main__":
    main() 