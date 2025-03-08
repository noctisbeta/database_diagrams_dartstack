# Use latest stable channel SDK.
FROM dart:stable AS build

# Set base working directory
WORKDIR /app

# Copy the common package
COPY database_diagrams_common /app/database_diagrams_common/

# Copy the server package
COPY database_diagrams_server /app/database_diagrams_server/

# Move to server directory and get dependencies
WORKDIR /app/database_diagrams_server
RUN dart pub get

# Compile
RUN dart compile exe bin/server.dart -o bin/server

# Final stage
FROM debian:buster-slim

WORKDIR /app

# Copy compiled application
COPY --from=build /app/database_diagrams_server/bin/server /app/server
COPY --from=build /runtime/ /

# Copy .env file
COPY database_diagrams_server/.env /app/.env

# Set environment variables (fallbacks if .env is not present)
ENV POSTGRES_HOST=postgres
ENV POSTGRES_PORT=5432
ENV POSTGRES_DATABASE=database_diagrams
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

# Expose ports
EXPOSE 8080

CMD ["/app/server"]
