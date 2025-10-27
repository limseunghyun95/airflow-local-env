FROM base-alpine

COPY git-sync.sh /usr/local/bin/git-sync.sh
RUN chmod +x /usr/local/bin/git-sync.sh

ENTRYPOINT ["bash", "/usr/local/bin/git-sync.sh"]