import os
import pathlib
import tempfile
import subprocess
import json

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
#from fastapi.middleware.cors import CORSMiddleware

from google.cloud import firestore

cfs = firestore.Client(database=os.getenv('FIRESTORE_DB'))
col_tts = cfs.collection("tts")
col_new = cfs.collection("new")

DIGEST_SIZE=256

app = FastAPI()

#app.add_middleware(
#    CORSMiddleware,
#    allow_origins=["*"],
#    allow_credentials=True,
#    allow_methods=["*"],
#    allow_headers=["*"],
#)

@app.get('/api/v1/timestamp')
async def timestamp(h: str):

    # valdiate hash length
    if len(h) != DIGEST_SIZE/4:
        return "ERROR: incorrect length"

    # validate hash characters
    try:
        int(h, 16)
    except:
        return "ERROR: invalid characters"

    db_hash = col_tts.document(h)
    db_hashSnap = db_hash.get()
    if db_hashSnap.exists:
        return db_hashSnap.to_dict()

    with tempfile.TemporaryDirectory() as tmpDirName:

        pathTMP = pathlib.Path(tmpDirName)
        pathTSQ = pathTMP / 'request.tsq'

        # generate tsq
        subprocess.run(['openssl', 'ts', '-query', '-digest', h, f'-sha{DIGEST_SIZE}', '-cert', '-out', pathTSQ], cwd = pathTMP, check = True)

        # save hash
        with open(pathTMP / f'sha{DIGEST_SIZE}.hash', 'w') as f:
            f.write(h)

        # stamp
        subprocess.run(['ttsStamp', pathTSQ], cwd = pathTMP, check = True)

        # touch (used by packJSON)
        (pathTMP / f'tts.sha{DIGEST_SIZE}').touch()

        # generage JSON
        subprocess.run(['ttsPackJSON', pathTMP], cwd = pathTMP, check = True)

        with open(pathTMP / 'timestamps_tts.json', 'r') as fj:
            ts_dict = json.load(fj)

        ts_dict.pop('name', None)
        ts_dict['hashfile'].pop('filename', None)
        ts_dict['hashfile'].pop('contents', None)

        db_hash.set(ts_dict)
        col_new.document(h).set({'exists' : True})
        return ts_dict

app.mount("/", StaticFiles(directory="static", html=True), name="static")
