FROM ollama/ollama:latest

# Descargar el modelo al arrancar y luego dejar el server arriba
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 11434
CMD ["/start.sh"]