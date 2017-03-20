FROM million12/nginx:latest

RUN \
  # Install ImageMagick & libxml
  rpm --rebuilddb && yum update -y && \
  yum install -y ImageMagick-devel libxml2 libxml2-devel libxml2-python libxslt libxslt-devel python-devel gcc && \
  # Install Gunicorn, Wand
  easy_install pip && \
  easy_install Wand && \
  easy_install gunicorn && \
  easy_install lxml && \
  yum remove -y gcc libxslt-devel python-devel libxml2-devel && \
  yum autoremove -y && \
  yum clean all && rm -rf /tmp/yum*

ADD container-files /
ADD vendor/kindlegen /opt/app/vendor/kindlegen
ADD https://github.com/janeczku/calibre-web/archive/master.tar.gz /tmp/calibre-cps.tar.gz

RUN \
  # Fix locale
  localedef -c -i en_US -f UTF-8 en_US.UTF-8 && \
  # Install calibre-web
  mkdir -p /opt/app && \
  tar zxf /tmp/calibre-cps.tar.gz -C /opt/app --strip-components=1 && \
  rm /tmp/calibre-cps.tar.gz && \
  mkdir -p /opt/app/cps/db && \
  pip install -r /opt/app/requirements.txt && \
  ln -s /opt/app/cps/db/app.db /opt/app/app.db && \
  chown -R www:www /opt/app

VOLUME ["/opt/app/cps/db/"]

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en
