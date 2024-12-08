FROM brainilab/timestamping

RUN apt-get -qq install python3-pip

RUN pip install fastapi[standard] --break-system-package

COPY app /app/

WORKDIR /app

CMD fastapi run app.py
