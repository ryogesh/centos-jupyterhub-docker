FROM centos:7.7.1908

LABEL maintainer="Yogesh Rajashekharaiah"

ARG JP_USER="jpuser"
ARG TMPDIR="/tmp"
ARG CONDA_DIR="/opt/anaconda3"
ARG CONDA_SITE_PKGS="${CONDA_DIR}/lib/python3.7/site-packages"
ARG JP_PORT=8888
ARG JPDOCK="https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook"

# Args for conda repo locations, in case you want to use local repo for conda install
# Similar to conda local repo, yum local repo can be used
ARG BASE_REPO="https://repo.anaconda.com"
ARG CONDA_FILE="Miniconda3-4.7.12.1-Linux-x86_64.sh"
ARG PY_REPO1="${BASE_REPO}/pkgs/main/"
ARG PY_REPO2="https://conda.anaconda.org/conda-forge/"
ARG R_REPO="${BASE_REPO}/pkgs/r/"

USER root

ENV LANG=en_US.UTF-8 \
    PATH=${CONDA_DIR}/bin:$PATH \
    USER=${JP_USER} \
    NB_USER=${JP_USER} \
    NB_UID=1000 \
    NB_GID=1000 \
    CONDA_DIR=${CONDA_DIR}

# Copy jupyter notebook conf
COPY jupyter/conf/ /etc/jupyter/
COPY jupyter/scripts/ /usr/local/bin/

# Download and install conda, java, crond, sudo, bzip2

# Edit /etc/pam.d/crond, /etc/cron.allow to avoid auth errors on cron
# Add /usr/local/bin, $CONDA_DIR to secure path for root to launch jupyter as sudo -u $JPUSER
# Change /var/spool/cron permissions to for direct edit of crontab file
# Don't edit scheduler using crontab -e, fails with fchown error on docker
# Instead edit cron file /var/spool/cron/jpuser directly

# Add JAVA_HOME to the spark-env.sh file
# Add a few properties to spark-defaults.conf file

RUN useradd -m -s /bin/bash ${JP_USER} && \
    cd ${TMPDIR} && \
    curl -L ${BASE_REPO}/miniconda/${CONDA_FILE} -o ${CONDA_FILE} && \
    yum install -y java-1.8.0-openjdk-1.8.0.222.b10-1.el7_7.x86_64 && \
    yum install -y bzip2 sudo cronie && \
    /bin/bash ./${CONDA_FILE} -f -b -p ${CONDA_DIR} && \
    conda config --system --set auto_update_conda false && \
    conda install -y -n base -c ${PY_REPO1} -c ${PY_REPO2} jupyterhub==1.1.0 jupyterlab==1.2.6 pyspark==2.3.2 scipy seaborn protobuf scikit-learn && \
    conda install -y -n base -c ${R_REPO} r-base r-caret r-randomforest r-plyr r-reshape2 r-irkernel && \
    conda clean --all --quiet --yes -f && \
    npm cache clean --force && \
    yum clean all && \
    sed -i '/account    required   pam_access.so/c\account    sufficient pam_succeed_if.so uid = 1000 quiet' /etc/pam.d/crond && \
    sed -i "s|^Defaults    secure_path = .*|&:/usr/local/bin:${CONDA_DIR}/bin|" /etc/sudoers && \
    chmod o+rx /var/spool/cron; echo ${JP_USER} > /etc/cron.allow && \
    touch /var/spool/cron/${JP_USER} ; chown ${JP_USER}:${JP_USER} /var/spool/cron/${JP_USER} && \
    mkdir $CONDA_SITE_PKGS/pyspark/conf && \
    chmod 0755 /usr/local/bin/* && \
    echo "JAVA_HOME=$(readlink -f /usr/bin/java |sed 's/\/bin\/java//')" >> $CONDA_SITE_PKGS/pyspark/conf/spark-env.sh  && \
    echo -e "spark.master local\nspark.submit.deployMode client\nspark.sql.session.timeZone UTC\n" > $CONDA_SITE_PKGS/pyspark/conf/spark-defaults.conf && \
    for fl in "start.sh" "start-notebook.sh" "start-singleuser.sh"; do curl -L "${JPDOCK}/$fl" -o /usr/local/bin/${fl}; done && \
    chmod 555 /usr/local/bin/start*.sh

WORKDIR /home/${JP_USER}

EXPOSE ${JP_PORT}

CMD ["start-processes.sh"]

# Do not change -l, login shell
ENTRYPOINT ["/bin/bash", "-l"]

