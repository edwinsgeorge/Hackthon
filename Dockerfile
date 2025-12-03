# Use a small, stable nginx image
FROM nginx:alpine

# Copy custom nginx configuration that works with OpenShift
COPY nginx.conf /etc/nginx/nginx.conf

# Set working dir to nginx html folder
WORKDIR /usr/share/nginx/html

# Remove default nginx static files (clean image)
RUN rm -rf ./*

# Copy website files into nginx html folder
COPY --chown=0:0 index.html .
COPY --chown=0:0 css ./css
COPY --chown=0:0 js ./js
COPY --chown=0:0 img ./img

# Ensure site files are readable by arbitrary UID (files 644, dirs 755)
RUN find . -type f -exec chmod 644 {} \; \
 && find . -type d -exec chmod 755 {} \;

# Create tmp directories for nginx temp files (OpenShift compatible)
# OpenShift runs container with arbitrary non-root UID which is typically in group 0
RUN mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
 && chown -R 0:0 /tmp /usr/share/nginx/html \
 && chmod -R g+rwX /tmp /usr/share/nginx/html

# Expose port 8080 (non-privileged port for OpenShift)
EXPOSE 8080

# Healthcheck (using port 8080)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -q --spider http://localhost:8080/ || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]


