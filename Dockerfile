FROM        debian
MAINTAINER  Fernando Mendes "fernando.mendes@webca.com.br"

# Update the package repository
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl locales

# Configure timezone and locale
RUN echo "America/Sao_Paulo" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=en_US.UTF-8 && \
	export LANG=en_US.UTF-8 && \
	export LC_ALL=en_US.UTF-8 && \
	locale-gen en_US.UTF-8 && \
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

RUN apt-get update;

# Install Apache + PHP
RUN apt-get install -y php5-cli php5 php5-mcrypt php5-curl php5-mysql php5-gd php-pear php-net-smtp php-net-socket php-mdb2-driver-mysql php-mdb2 php-mail-mimedecode php-mail-mime

# Install SSL
RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
RUN apt-get update;
RUN apt-get install -y libapache2-mod-gnutls

RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/Sao_Paulo/g' /etc/php5/cli/php.ini
RUN sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ America\/Sao_Paulo/g' /etc/php5/apache2/php.ini

# Activate a2enmod
RUN a2enmod rewrite

#ADD ./000-default.conf /etc/apache2/sites-available/
ADD ./001-web.conf /etc/apache2/sites-available/
ADD ./002-ssl.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-web.conf /etc/apache2/sites-enabled/
RUN ln -s /etc/apache2/sites-available/002-ssl.conf /etc/apache2/sites-enabled/
#RUN unlink /etc/apache2/sites-enabled/000-default.conf
#RUN ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/
RUN rm /etc/apache2/sites-enabled/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set Apache environment variables (can be changed on docker run with -e)
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN fernando.mendes@webca.com.br
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www/html


# Install Postfix.
# RUN echo "postfix postfix/main_mailer_type string Internet site" > preseed.txt
# RUN echo "postfix postfix/mailname string mail.webca.com.br" >> preseed.txt
# RUN apt-get install -y postfix


EXPOSE 80
EXPOSE 443
ADD start.sh /start.sh
RUN chmod 0755 /start.sh
CMD ["bash", "start.sh"]
