# Use the official Nginx image which includes gettext-base for envsubst
FROM nginx:latest

# Set default values for environment variables, mainly for local testing
ENV PORT=8080
ENV SERVER_NAME=localhost
ENV GHOST_ROOT_URL="http://localhost:2368"

# Optional: Configure multiple additional Ghost instances.
# The format is a comma-separated list of path:url pairs.
# Example: ENV GHOST_INSTANCES="/fr:http://localhost:2369, /es:http://localhost:2370"

# Copy the Nginx configuration template
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template

# Copy and make the entrypoint script executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


# This command will be executed when the container starts
CMD ["/entrypoint.sh"]

# Expose the port Nginx will listen on
EXPOSE 8080
