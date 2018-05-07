FROM centos:7
MAINTAINER The CentOS Project <cloud-ops@centos.org>
LABEL Vendor="CentOS" \
      License=GPLv2 \
      Version=2.4.6-40


RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install httpd && \
    yum clean all

EXPOSE 80

#Install AWS CLI
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py --user
RUN /root/.local/bin/pip install awscli --upgrade --user

#Copy Web App
ADD src/index.php /var/www/html

# Simple startup script to avoid some issues observed with container restart
#ADD run-httpd.sh /usr/local/bin/
ADD src/entrypoint.sh /usr/local/bin/
#RUN chmod -v +x /usr/local/bin/run-httpd.sh
RUN chmod -v +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/bin/sh"]
CMD ["/usr/local/bin/entrypoint.sh"]
