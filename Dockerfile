FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter pub get \
 && flutter build web --release --base-href=/app/

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html/app

# Create nginx config for Flutter web app
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen       80;' >> /etc/nginx/conf.d/default.conf && \
    echo '    listen  [::]:80;' >> /etc/nginx/conf.d/default.conf && \
    echo '    server_name  localhost;' >> /etc/nginx/conf.d/default.conf && \
    echo '' >> /etc/nginx/conf.d/default.conf && \
    echo '    location /app/ {' >> /etc/nginx/conf.d/default.conf && \
    echo '        root   /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '        try_files $uri $uri/ /app/index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '' >> /etc/nginx/conf.d/default.conf && \
    echo '    location / {' >> /etc/nginx/conf.d/default.conf && \
    echo '        root   /usr/share/nginx/html/app;' >> /etc/nginx/conf.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

EXPOSE 80

