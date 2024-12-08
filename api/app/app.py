import pathlib
import tempfile
import subprocess
from fastapi import FastAPI

DIGEST_SIZE=256

app = FastAPI()

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

    with tempfile.TemporaryDirectory() as tmpDirName:

        pathTMP = pathlib.Path(tmpDirName)
        pathTSQ = pathTMP / 'request.tsq'

        # generate tsq
        subprocess.run(['openssl', 'ts', '-query', '-digest', h, f'-sha{DIGEST_SIZE}', '-cert', '-out', pathTSQ], cwd = pathTMP, check = True)

        # stamp
        subprocess.run(['ttsStamp', pathTSQ], cwd = pathTMP, check = True)

        # touch (used by packJSON)
        (pathTMP / f'tts.sha{DIGEST_SIZE}').touch()

        # generage JSON
        subprocess.run(['ttsPackJSON', pathTMP], cwd = pathTMP, check = True)

        with open(pathTMP / 'timestamps_tts.json', 'r') as fj:
            return fj.read()
