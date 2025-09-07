FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter pub get \
 && flutter build web --release --base-href=/app/

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html/app
EXPOSE 80

