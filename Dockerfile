FROM centos:7

# 1. 종료된 CentOS 7 리포지토리 주소를 Vault(보관소)로 자동 변경
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org/centos/$releasever|baseurl=http://vault.centos.org/7.9.2009|g' /etc/yum.repos.d/CentOS-Base.repo

# 2. 필수 패키지 및 Ansible 설치
RUN yum clean all && yum makecache && \
    yum install -y sudo vim wget python3 openssh-server openssh-clients epel-release && \
    # EPEL 리포지토리 주소도 가끔 에러나므로 정리 (선택사항)
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/epel.repo && \
    sed -i 's|#baseurl=http://download.fedoraproject.org/pub/epel/7|baseurl=https://archives.fedoraproject.org/pub/archive/epel/7|g' /etc/yum.repos.d/epel.repo && \
    yum install -y ansible

# 3. SSH 서비스 설정 (비밀번호 기반 접속 허용)
RUN ssh-keygen -A && \
    echo "root:1234" | chpasswd && \
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config

# 4. 컨테이너 시작 시 SSH 서비스 실행
CMD ["/usr/sbin/sshd", "-D"]