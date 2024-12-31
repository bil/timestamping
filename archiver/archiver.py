import os
import pathlib
import json

import fire

from google.cloud import firestore

cfs = firestore.Client(project = os.getenv('GCP_PROJECT'), database=os.getenv('FIRESTORE_DB'))

col_tts = cfs.collection("tts")
col_new = cfs.collection("new")

def pullnew(out_path):

    p_out = pathlib.Path(out_path)
    p_out.mkdir(parents = True, exist_ok = True)

    for n in col_new.get():
    
        n_d = col_tts.document(n.id).get().to_dict()
    
        with open(p_out / f'{n.id}.json', 'w') as f:
            json.dump(n_d, f)

def clearnew():

    for d in col_new.list_documents():
        d.delete()

if __name__ == '__main__':
    fire.Fire()
