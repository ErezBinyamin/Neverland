FROM qmcgaw/latexdevcontainer
ARG TEXLIVE_VERSION=2025
ENV PATH=${PATH}:/usr/local/texlive/${TEXLIVE_VERSION}/bin/x86_64-linux

# Install basic utilities and the packages you need
RUN apt-get update --yes && \
    apt-get install --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-release \
    python3 \
    python3-pip \
    python3-pygments \
    graphviz \
    dot2tex \
    git \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN apt-get update --yes && \
    apt-get install --yes \
    texlive-full \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Add additional LaTeX packages
RUN apt-get update && apt-get install -y \
      texlive-latex-extra \
      texlive-pictures \
      texlive-fonts-recommended \
      texlive-science \
      texlive-fonts-extra \
      texlive-luatex \
      python3-pygments \
      graphviz \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

#RUN tlmgr update --self --all
#     tlmgr install scheme-full
#RUN tlmgr install \
#    minted \
#    fancyhdr \
#    pgf \
#    svg \
#    upquote \
#    lineno \
#    transparent \
#    booktabs \
#    siunitx \
#    graphviz && \
#    texhash && \
#    rm /usr/local/texlive/${TEXLIVE_VERSION}/texmf-var/web2c/*.log && \
#    rm /usr/local/texlive/${TEXLIVE_VERSION}/tlpkg/texlive.tlpdb.main.*
