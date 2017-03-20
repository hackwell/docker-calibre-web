FROM million12/nginx:latest

RUN \
  # Install ImageMagick & libxml
  rpm --rebuilddb && yum update -y && \
  yum install -y ImageMagick-devel libevent libxml2 libxml2-devel libxml2-python libxslt libxslt-devel python-devel gcc && \
  # Install Gunicorn, Wand
  easy_install -O2 pip && \
  pip install --compile --no-cache-dir Wand && \
  pip install --compile --no-cache-dir gunicorn && \
  pip install --compile --no-cache-dir lxml && \
  pip install --compile --no-cache-dir gevent google-api-python-client pydrive && \
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
  pip install --compile --no-cache-dir -r /opt/app/requirements.txt && \
  ln -s /data/app.db /opt/app/app.db && \
  chown -R www:www /opt/app

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en
