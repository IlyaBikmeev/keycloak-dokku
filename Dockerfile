FROM quay.io/keycloak/keycloak:26.0.7

USER root
COPY docker-entrypoint.sh /opt/keycloak/bin/dokku-entrypoint.sh
RUN chmod +x /opt/keycloak/bin/dokku-entrypoint.sh \
  && chown keycloak:root /opt/keycloak/bin/dokku-entrypoint.sh

USER keycloak
ENTRYPOINT ["/opt/keycloak/bin/dokku-entrypoint.sh"]
