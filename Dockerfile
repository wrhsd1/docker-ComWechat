FROM wrhsd/docker-wechat

USER root
WORKDIR /

ENV WINEPREFIX=/home/user/.wine \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DISPLAY=:5 \
    VNCPASS=YourSafeVNCPassword \
    COMWECHAT=https://github.com/ljc545w/ComWeChatRobot/releases/download/3.7.0.30-0.0.5/3.7.0.30-0.0.5.zip

# 提示 vnc 使用的端口， dll 的端口自行映射
EXPOSE 5905

RUN apt update && \
    apt --no-install-recommends install wget winbind samba tigervnc-standalone-server tigervnc-common openbox unzip -y && \
    wget --no-check-certificate -O /bin/dumb-init "https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_$(uname -m)"

COPY wine/simsun.ttc  /home/user/.wine/drive_c/windows/Fonts/simsun.ttc
COPY wine/微信.lnk /home/user/.wine/drive_c/users/Public/Desktop/微信.lnk
COPY wine/system.reg  /home/user/.wine/system.reg
COPY wine/user.reg  /home/user/.wine/user.reg
COPY wine/userdef.reg /home/user/.wine/userdef.reg

RUN wget --no-check-certificate -O /Tencent.zip "https://github.com/tom-snow/docker-ComWechat/releases/download/v0.2_wc3.7.0.30/Tencent.zip"

COPY WeChatHook.exe /WeChatHook.exe

COPY run.py /run.py

RUN chmod a+x /bin/dumb-init && \
    chmod a+x /run.py && \
    rm -rf "/home/user/.wine/drive_c/Program Files/Tencent/" && \
    unzip Tencent.zip && \
    cp -rf /wine/Tencent "/home/user/.wine/drive_c/Program Files/" && \
    chown root:root -R /home/user/.wine && \
    rm -rf /wine/Tencent Tencent.zip && \
    apt autoremove -y && \
    apt clean && \
    rm -fr /tmp/*

ENTRYPOINT [ "/bin/dumb-init" ]
CMD ["/run.py", "start"]
