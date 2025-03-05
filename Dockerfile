# Usa a imagem oficial do Python 3.9
FROM python:3.9

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia primeiro os arquivos de dependências (boa prática para cache eficiente)
COPY requirements.txt /app/

# Instala as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Agora copia o restante dos arquivos
COPY app.py /app/

# Adiciona um healthcheck para verificar se o Flask está rodando
HEALTHCHECK --interval=5s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

# Define o comando padrão para rodar a aplicação
CMD ["python", "/app/app.py"]
