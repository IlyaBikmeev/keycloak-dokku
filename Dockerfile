FROM quay.io/keycloak/keycloak:latest

COPY docker-entrypoint.sh /opt/jboss/tools

EXPOSE 80

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]
CMD ["-b", "0.0.0.0"]
