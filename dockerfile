# Use a small, stable nginx image
FROM nginx:alpine

# Set working dir to nginx html folder
WORKDIR /usr/share/nginx/html

# Remove default static files
RUN rm -rf ./*

# Copy website files into nginx html folder
# (Docker will copy everything from repo root; .dockerignore controls exclusions)
COPY . .

# Ensure permissions are open so OpenShift (arbitrary UID) can read files
# Files -> 644, Dirs -> 755
RUN find . -type f -exec chmod 644 {} \; \
 && find . -type d -exec chmod 755 {} \;

# Expose port 80 (nginx default)
EXPOSE 80

# Simple healthcheck (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

