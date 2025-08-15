# Cấu hình chạy ứng dụng trên Port 3101

## Tổng quan

Tài liệu này hướng dẫn cách cấu hình và chạy ứng dụng Flutter "The Happiness Journey" trên port 3101.

## Các cách chạy ứng dụng trên Port 3101

### 1. Sử dụng Script (Khuyến nghị)

#### Windows
```bash
# Chạy script batch
scripts/run_on_port_3101.bat
```

#### Linux/Mac
```bash
# Cấp quyền thực thi cho script
chmod +x scripts/run_on_port_3101.sh

# Chạy script
./scripts/run_on_port_3101.sh
```

### 2. Sử dụng npm/yarn (nếu có)

```bash
# Cài đặt dependencies (nếu cần)
npm install

# Chạy ứng dụng
npm start

# Hoặc chạy với debug mode
npm run start:dev

# Hoặc chạy với release mode
npm run start:release
```

### 3. Sử dụng Flutter CLI trực tiếp

```bash
# Chạy với port 3101
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0

# Chạy với debug mode
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0 --debug

# Chạy với release mode
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0 --release
```

### 4. Sử dụng VS Code

1. Mở VS Code
2. Nhấn `F5` hoặc vào `Run and Debug`
3. Chọn `Flutter Web (Port 3101)` từ dropdown
4. Nhấn nút play để chạy

## Cấu hình môi trường

### Biến môi trường

Để đảm bảo ứng dụng luôn chạy trên port 3101, bạn có thể set biến môi trường:

#### Windows
```cmd
set FLUTTER_WEB_PORT=3101
```

#### Linux/Mac
```bash
export FLUTTER_WEB_PORT=3101
```

### Cấu hình VS Code

File `.vscode/launch.json` đã được cấu hình sẵn với:
- `Flutter Web (Port 3101)`: Chạy trên port 3101
- `Flutter Web (Default)`: Chạy trên port mặc định

## Truy cập ứng dụng

Sau khi chạy thành công, ứng dụng sẽ có thể truy cập tại:

- **Local**: http://localhost:3101
- **Network**: http://[your-ip]:3101

## Troubleshooting

### Port 3101 đã được sử dụng

Nếu port 3101 đã được sử dụng bởi ứng dụng khác:

1. **Tìm và dừng process đang sử dụng port 3101:**

   Windows:
   ```cmd
   netstat -ano | findstr :3101
   taskkill /PID [PID] /F
   ```

   Linux/Mac:
   ```bash
   lsof -i :3101
   kill -9 [PID]
   ```

2. **Hoặc sử dụng port khác:**
   ```bash
   flutter run -d web-server --web-port=3102 --web-hostname=0.0.0.0
   ```

### Lỗi kết nối

Nếu không thể kết nối:

1. Kiểm tra firewall
2. Đảm bảo `--web-hostname=0.0.0.0` được sử dụng
3. Kiểm tra quyền truy cập port

### Lỗi Flutter

```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter run -d web-server --web-port=3101 --web-hostname=0.0.0.0
```

## Cấu hình Production

Để build ứng dụng cho production:

```bash
# Build web app
flutter build web

# Serve với port 3101 (cần web server như nginx, apache)
# Ví dụ với Python
cd build/web
python -m http.server 3101
```

## Tích hợp với CI/CD

### GitHub Actions

```yaml
name: Deploy to Port 3101
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.1'
      - run: flutter build web
      - run: |
          cd build/web
          python -m http.server 3101 &
```

## Lưu ý

1. **Security**: Khi sử dụng `--web-hostname=0.0.0.0`, ứng dụng sẽ có thể truy cập từ network. Chỉ sử dụng trong môi trường development hoặc mạng nội bộ an toàn.

2. **Performance**: Port 3101 được chọn để tránh xung đột với các service phổ biến khác.

3. **Hot Reload**: Tính năng hot reload vẫn hoạt động bình thường khi chạy trên port 3101.

4. **Debugging**: Có thể debug ứng dụng thông qua DevTools của browser tại http://localhost:3101.

## Hỗ trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra logs trong terminal
2. Kiểm tra console của browser
3. Đảm bảo Flutter và Dart SDK được cài đặt đúng phiên bản
