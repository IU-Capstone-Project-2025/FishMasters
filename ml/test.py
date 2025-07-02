import pandas as pd
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

df = pd.read_csv('../datasets/db_fishbase.csv', usecols=lambda column: column != 'FullDescription_en' and column != 'Species')

target = pd.read_csv('../datasets/db_fishbase.csv', usecols=lambda column: column == 'FullDescription_en' or column == 'Species')

embeddings = df.values.astype('float32')

d = embeddings.shape[1]


#Creation of all necessary stuff
embedder = SentenceTransformer(
    "Qwen/Qwen3-Embedding-0.6B",
    model_kwargs={"attn_implementation":"eager", "device_map": "auto"},
    tokenizer_kwargs={"padding_side": "left"}
)

index_IP = faiss.IndexFlatIP(d)
index_IP.add(embeddings)

index_L2 = faiss.IndexFlatL2(d)
index_L2.add(embeddings)


quantizer = faiss.IndexFlatIP(d)
nlist = 596
index_IVF = faiss.IndexIVFFlat(quantizer, d, nlist, faiss.METRIC_INNER_PRODUCT)
index_IVF.train(embeddings)
index_IVF.add(embeddings)
index_IVF.nprobe = 25

query_text = input("Enter the query to search: ")
query_vec_1d = embedder.encode(query_text, convert_to_numpy=True)
query_vec_2d = np.expand_dims(query_vec_1d, axis=0)

k=5
print('-'*50)
print("Index_IP")
D_IP, I_IP = index_IP.search(query_vec_2d, k)
for i in range(k):
    print(f"{i}. {D_IP[0, i]}:\n{target['Species'].iloc[I_IP[0, i]]}")

print('-'*50)
print("Index_L2")
D_L2, I_L2 = index_L2.search(query_vec_2d, k)
for i in range(k):
    print(f"{i}. {D_L2[0, i]}:\n{target['Species'].iloc[I_L2[0, i]]}")

print('-'*50)
print("Index_IVF")
D_IVF, I_IVF = index_IVF.search(query_vec_2d, k)
for i in range(k):
    print(f"{i}. {D_IVF[0, i]}:\n{target['Species'].iloc[I_IVF[0, i]]}")

