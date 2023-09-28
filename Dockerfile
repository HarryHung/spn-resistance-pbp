FROM ubuntu:18.04 as app

ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

RUN apt update \
      && apt install -y -q apt-transport-https software-properties-common \
      && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
      && apt update \
      && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' \
      && apt install -y -q \
        curl \
        perl \
        r-base \
        gcc \
        build-essential \
        libx11-dev \
      && rm -rf /var/lib/apt/lists/*

# Install BLAST
RUN  mkdir -p /tmp/blast \
      && mkdir /opt/blast \
      && curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.9.0/ncbi-blast-2.9.0+-x64-linux.tar.gz \
      | tar -zxC /tmp/blast --strip-components=1 \
      && cd /tmp/blast/bin \
      && mv blastn makeblastdb blastp /opt/blast/ \
      && cd .. \
      && rm -rf /tmp/blast

ENV PATH /opt/blast:$PATH

# Install BEDTools
RUN curl -L -O -J https://github.com/arq5x/bedtools2/releases/download/v2.28.0/bedtools \
      && chmod +x bedtools \
      && mv bedtools /usr/local/bin/

# Install R dependencies
COPY install_r_dependencies.R /install_r_dependencies.R

RUN Rscript /install_r_dependencies.R \
      && rm -f /install_r_dependencies.R

RUN curl -L -O -J https://cran.r-project.org/src/contrib/Archive/randomForest/randomForest_4.6-14.tar.gz \
      && R CMD INSTALL randomForest_4.6-14.tar.gz \
      && rm -rf randomForest_4.6-14.tar.gz

# Install Clustal Omega
RUN curl -L -O -J http://www.clustal.org/omega/clustalo-1.2.4-Ubuntu-x86_64 \
       && mv clustalo-1.2.4-Ubuntu-x86_64 clustalo \
       && chmod +x clustalo \
       && mv clustalo /usr/local/bin/

# Install CPAN dependencies
RUN cpan App::cpanminus \
      && cpan JSON

# Copy in scripts & libs
RUN mkdir -p /predictor/SPN_Reference_DB

RUN mkdir -p /predictor/bLactam_MIC_Rscripts

COPY SPN_Reference_DB/ /predictor/SPN_Reference_DB/

COPY bLactam_MIC_Rscripts /predictor/bLactam_MIC_Rscripts/

COPY ExtractGene.pl /predictor/

COPY PBP-Gene_Typer.pl /predictor/

COPY pw_wrapper.sh /predictor/

COPY to_json.pl /predictor/

COPY transeq.pl /predictor/

COPY spn_pbp_amr /predictor/

RUN cd /predictor \
      && chmod +x *.sh \
      && chmod +x *.pl \
      && chmod +x spn_pbp_amr

ENV PATH /predictor:$PATH

ENV PATH /predictor/bLactam_MIC_Rscripts/:$PATH


# new base for testing
FROM app as test

RUN mkdir -p /test_data

COPY test_data /test_data

RUN spn_pbp_amr /test_data/contigs.fasta > result.json

RUN apt update && apt install -y -q jq

RUN jq --sort-keys . result.json > sorted_result.json && jq --sort-keys . /test_data/expected_result.json > sorted_expected_result.json

RUN cmp sorted_result.json sorted_expected_result.json
