# apachemysql-server

Relembrar:

* Para montar a imagem
docker build -t apache-fe .

* Para executar novo container
docker run -d -v /Users/fernandomendes/github/site:/var/www/html -p 80:80 apache-fe
