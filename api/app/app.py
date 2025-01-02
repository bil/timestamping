import os
import pathlib
import tempfile
import subprocess
import json

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from google.cloud import firestore

cfs = firestore.Client(database=os.getenv('FIRESTORE_DB'))
col_tts = cfs.collection("tts")
col_new = cfs.collection("new")

DIGEST_SIZE=256

app = FastAPI()

if os.getenv('DEPLOY_ENV') == 'dev':
    from fastapi.middleware.cors import CORSMiddleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

@app.get('/api/v0.0.2/timestamp')
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

    with tempfile.TemporaryDirectory() as tmpDirName:

        pathTMP = pathlib.Path(tmpDirName)
        tsfile = 'timestamps_tts.json'

        # save hash
        with open(pathTMP / f'sha{DIGEST_SIZE}.digest', 'w') as f:
            f.write(h)

        # check if hash exists
        if db_hashSnap.exists:
            # hash exists, grab it and verify
            ts_dict = db_hashSnap.to_dict()

            with open(pathTMP / tsfile, 'w') as fj:
                json.dump(ts_dict, fj)

            # unpack and verify timestamp
            subprocess.run(['ttsUnpackJSON', tsfile], cwd = pathTMP, check = True)
            subprocess.run(['ttsVerify', h], cwd = pathTMP, check = True)

            with open(pathTMP / 'tsVerify.json', 'r') as fj:
                verify = json.load(fj)

            return {'newTimestamp' : False, 'verification' : verify, 'timestamps' : db_hashSnap.to_dict()}

        else:
            # hash does not exist, create
            pathTSQ = pathTMP / 'request.tsq'

            # generate tsq
            subprocess.run(['openssl', 'ts', '-query', '-digest', h, f'-sha{DIGEST_SIZE}', '-cert', '-out', pathTSQ], cwd = pathTMP, check = True)

            # stamp
            subprocess.run(['ttsStamp', pathTSQ], cwd = pathTMP, check = True)

            # touch (used by packJSON)
            (pathTMP / f'tts.sha{DIGEST_SIZE}').touch()

            # generate JSON
            subprocess.run(['ttsPackJSON', pathTMP], cwd = pathTMP, check = True)

            with open(pathTMP / tsfile, 'r') as fj:
                ts_dict = json.load(fj)

            ts_dict.pop('name', None)
            ts_dict.pop('hashfile', None)

            # verify timestamp
            subprocess.run(['ttsVerify', h], cwd = pathTMP, check = True)

            with open(pathTMP / 'tsVerify.json', 'r') as fj:
                verify = json.load(fj)

            db_hash.set(ts_dict)
            col_new.document(h).set({'exists' : True})
            return {'newTimestamp' : True, 'verification' : verify, 'timestamps' : ts_dict}

app.mount("/", StaticFiles(directory="static", html=True), name="static")
