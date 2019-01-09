# Version: 1.0

FROM 32bit/ubuntu:16.04

# ARGV

ARG ias=ias_linux_x86_101351.zip
ARG oracle_home=/opt/oracle
ARG oracle_lib=${oracle_home}/lib

ENV DEBIAN_FRONTEND noninteractive

# Prerequirements

RUN apt-get update
RUN apt-get install software-properties-common unzip make build-essential -y
RUN apt install -y libdb1-compat psmisc

RUN useradd -d ${oracle_home} -ms /bin/bash -g root -G sudo -p oracle oracle
USER oracle

# IAS 10.1.3.51

ADD ${ias} /tmp
RUN unzip /tmp/${ias} -d /tmp/Install
WORKDIR /tmp/Install/Disk1

ADD oraInst.loc /tmp/oraInst.loc

RUN /tmp/Install/Disk1/install/runInstaller \
         SHOW_CUSTOM_TREE_PAGE=false \ 
         -silent \
         -force \ 
	 	 -ignoreSysPrereqs \
	 	 -invPtrLoc /tmp/oraInst.loc \
         session:ORACLE_HOME_NAME=OraHome \
         session:ORACLE_HOME="${oracle_home}" && \
         sleep 5; \
         pgrep -f 'oracle.installer' | tail -n1 > /tmp/installer.pid; \
         while true; do sleep 5; pgrep -F /tmp/installer.pid; if [ $? != '0' ]; then break; fi; done
         
USER root
RUN ${oracle_home}/root.sh 
ADD httpd.conf ${oracle_home}/Apache/Apache/conf/httpd.conf
ADD oracle_apache.conf ${oracle_home}/Apache/Apache/conf/oracle_apache.conf
ADD system-jazn-data.xml ${oracle_home}/j2ee/home/config/system-jazn-data.xml
ADD run.sh /run.sh

# SSL

RUN ln -s ${oracle_lib}/libclntsh.so ${oracle_lib}/libclntsh.so.10.1

# Environment

ENV PATH ${oracle_home}/opmn/bin:$PATH
ENV LD_LIBRARY_PATH ${oracle_lib}:$LD_LIBRARY_PATH

# Clean

USER root
RUN rm -rf /tmp/Install; rm /tmp/${ias};
CMD ["/run.sh"]
