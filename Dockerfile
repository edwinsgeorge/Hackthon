# Use a small, stable nginx image
FROM nginx:alpine

# Set working dir to nginx html folder
WORKDIR /usr/share/nginx/html

# Remove default nginx static files (clean image)
RUN rm -rf ./*

# Copy website files into nginx html folder
COPY . .

# Ensure site files are readable by arbitrary UID (files 644, dirs 755)
RUN find . -type f -exec chmod 644 {} \; \
 && find . -type d -exec chmod 755 {} \;

# Create nginx runtime/cache dirs and make them group-writable for OpenShift
# OpenShift runs container with arbitrary non-root UID which is typically in group 0,
# so we chown to group 0 and give group write/execute permission.
RUN mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/run /var/log/nginx \
 && chown -R 0:0 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html \
 && chmod -R g+rwX /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html

# Expose port 80 (nginx default)
EXPOSE 80

# Healthcheck (keep but increase start period so container has time to warm up)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]


