FROM brainilab/timestamping

RUN apt-get -qq install python3-pip

RUN pip install fire google-cloud-firestore --break-system-package

COPY ./ /archiver/

WORKDIR /archiver

CMD ./archiver.sh
