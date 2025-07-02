import time
import statistics
import pandas as pd
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

###XXX THE FOLLOWING CAN BE RAN ONLY WITH DOWNLOADED DATASET ON YOUR LOCAL MACHINE 

df = pd.read_csv('../datasets/db_fishbase.csv', usecols=lambda column: column != 'FullDescription_en' and column != 'Species')

target = pd.read_csv('../datasets/db_fishbase.csv', usecols=lambda column: column == 'FullDescription_en' or column == 'Species')

embeddings = df.values.astype('float32')

d = embeddings.shape[1]
top_k = 5

test_queries = [
    # --- Depth of Living ---
    "deep-sea fish with bioluminescent lures",
    "abyssal zone fish with oversized jaws",
    "mesopelagic fish that migrates vertically at night",
    "fish found below 1000 meters in the Mariana Trench",
    "surface-dwelling fish that feeds on plankton",
    "coral reef fish that lives at 10-30 meters depth",
    "hadal snailfish from extreme ocean depths",
    "intertidal fish that survives in tidal pools",
    "midwater fish with transparent body",
    "bathypelagic fish with reduced eyesight",

    # --- Body Shape ---
    "elongated eel-like fish with no scales",
    "flatfish with both eyes on one side",
    "globular-shaped fish like a pufferfish",
    "fish with a needle-like snout and slender body",
    "disk-shaped fish with tall dorsal fins",
    "fish with a serpentine body and sharp teeth",
    "box-shaped fish with hard carapace",
    "fish with a hammer-shaped head",
    "ribbon-like fish with long flowing fins",
    "fish with a triangular cross-section body",

    # --- Common & Scientific Names ---
    "Clownfish (Amphiprioninae)",
    "Tuna (Thunnus)",
    "Lionfish (Pterois)",
    "Anglerfish (Lophiiformes)",
    "Swordfish (Xiphias gladius)",
    "Seahorse (Hippocampus)",
    "Barracuda (Sphyraena)",
    "Manta ray (Mobula)",
    "Catfish (Siluriformes)",
    "Piranha (Pygocentrus)",

    # --- Danger to Humans ---
    "venomous fish with toxic spines",
    "fish that can deliver electric shocks",
    "aggressive fish known to attack humans",
    "fish with poisonous flesh if eaten",
    "shark species dangerous to humans",
    "fish that causes ciguatera poisoning",
    "stingray with venomous tail barb",
    "fish that bites with extreme force",
    "stonefish with lethal neurotoxins",
    "pufferfish containing tetrodotoxin",

    # --- Water Type (Salt/Brackish/Fresh) ---
    "saltwater fish that cannot survive in freshwater",
    "brackish water fish from mangrove swamps",
    "freshwater fish native to the Amazon River",
    "euryhaline fish that tolerates both fresh and saltwater",
    "fish found only in hypersaline lakes",
    "estuarine fish that migrates between rivers and sea",
    "cavefish adapted to underground freshwater",
    "fish that lives in Arctic saltwater",
    "desert fish endemic to freshwater springs",
    "fish thriving in polluted urban rivers",

    # --- Combinations of Traits ---
    "deep-sea venomous fish with bioluminescence",
    "freshwater eel-like fish with sharp teeth",
    "saltwater box-shaped fish with toxins",
    "brackish water fish that can walk on land",
    "small colorful reef fish with venomous spines",
    "large pelagic fish with high mercury levels",
    "transparent cavefish with no eyes",
    "bottom-dwelling saltwater fish with camouflage",
    "aggressive freshwater fish with powerful jaws",
    "slow-moving tropical fish with armor-like scales",

    # --- Simple Fish Names (General) ---
    "Salmon",
    "Bass",
    "Trout",
    "Cod",
    "Haddock",
    "Mackerel",
    "Sardine",
    "Anchovy",
    "Grouper",
    "Snapper",

    # --- Genus/Species Focus ---
    "Fish from the genus Carcharodon",
    "Species in the family Pomacentridae",
    "Fish of the genus Synanceia",
    "Members of the order Tetraodontiformes",
    "Fish classified under Serranidae",
    "Species of the genus Hippocampus",
    "Fish in the family Muraenidae",
    "Genus Latimeria (coelacanths)",
    "Species of the subfamily Corydoradinae",
    "Fish from the genus Electrophorus",

    # --- Extreme Adaptations ---
    "fish that breathes air with lungs",
    "fish that can survive out of water for days",
    "fish with antifreeze proteins in blood",
    "fish that changes color for camouflage",
    "fish that produces audible sounds",
    "fish that uses tools to crack shells",
    "fish with symbiotic bacteria for digestion",
    "fish that glides above water surface",
    "fish that parasitizes other fish",
    "fish with regenerative abilities"
]

embedder = SentenceTransformer(
    "Qwen/Qwen3-Embedding-0.6B",
    model_kwargs={"attn_implementation":"eager", "device_map": "auto"},
    tokenizer_kwargs={"padding_side": "left"}
)

metrics = {
    'IndexFlatIP': {
        'times': [],
        'avg_similarity':[],
        'indexes' : []
    },
    'IndexIVFFlat': {
        "model_1":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
        "model_2":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
        "model_3":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
        "model_4":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
        "model_5":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
    },
    'IndexLSH':{
        "model_1":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
        "model_2":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
        "model_3":{
            'times': [],
            'avg_similarity':[],
            'indexes': []
        },
    }
}

index_IP = faiss.IndexFlatIP(d)
index_IP.add(embeddings)

# params_ivf = [(64, 1), (64, 3), (64, 5), (64, 10),
#           (128, 1), (128, 3), (128, 5), (128, 10),
#           (256, 1), (256, 3), (256, 5), (256, 10),
#           (512, 1), (512, 3), (512, 5), (512, 10),
#           (1024, 1), (1024, 3), (1024, 5), (1024, 10)]

quantizer1 = faiss.IndexFlatIP(d)
index_IVF_64 = faiss.IndexIVFFlat(quantizer1, d, 64, faiss.METRIC_INNER_PRODUCT)
index_IVF_64.train(embeddings)
index_IVF_64.add(embeddings)
index_IVF_64.nprobe = 1

quantizer2 = faiss.IndexFlatIP(d)
index_IVF_128 = faiss.IndexIVFFlat(quantizer2, d, 128, faiss.METRIC_INNER_PRODUCT)
index_IVF_128.train(embeddings)
index_IVF_128.add(embeddings)
index_IVF_128.nprobe = 3

quantizer3 = faiss.IndexFlatIP(d)
index_IVF_256 = faiss.IndexIVFFlat(quantizer3, d, 256, faiss.METRIC_INNER_PRODUCT)
index_IVF_256.train(embeddings)
index_IVF_256.add(embeddings)
index_IVF_256.nprobe = 3

quantizer4 = faiss.IndexFlatIP(d)
index_IVF_512 = faiss.IndexIVFFlat(quantizer4, d, 512, faiss.METRIC_INNER_PRODUCT)
index_IVF_512.train(embeddings)
index_IVF_512.add(embeddings)
index_IVF_512.nprobe = 5

quantizer5 = faiss.IndexFlatIP(d)
index_IVF_1024 = faiss.IndexIVFFlat(quantizer5, d, 1024, faiss.METRIC_INNER_PRODUCT)
index_IVF_1024.train(embeddings)
index_IVF_1024.add(embeddings)
index_IVF_1024.nprobe = 10

dict_IVF = {1:index_IVF_64, 2:index_IVF_128, 3:index_IVF_256, 4:index_IVF_512, 5:index_IVF_1024}


index_LSH_2 = faiss.IndexLSH(d, d*2)
index_LSH_2.add(embeddings)

index_LSH_4 = faiss.IndexLSH(d, d*4)
index_LSH_4.add(embeddings)

index_LSH_6 = faiss.IndexLSH(d, d*6)
index_LSH_6.add(embeddings)

dict_LSH = {1:index_LSH_2, 2:index_LSH_4, 3:index_LSH_6}

c = 0
for query in test_queries:
    embedding = embedder.encode(query, convert_to_numpy=True)
    query_vec = np.expand_dims(embedding, axis=0)
    print(f"{c}) query: {query}")
    
    #indexIP
    time_start = time.time()
    D_IP, I_IP = index_IP.search(query_vec, top_k)
    metrics["IndexFlatIP"]['times'].append((time.time() - time_start) * 1000)
    metrics["IndexFlatIP"]['avg_similarity'].append(D_IP)
    metrics["IndexFlatIP"]['indexes'].append(I_IP)
    
    #all possible indexivf    
    for i in range(1, 6):
        time_IVF_start = time.time()
        D_IVF, I_IVF = dict_IVF.get(i).search(query_vec, top_k)
        metrics["IndexIVFFlat"][f'model_{i}']['times'].append((time.time() - time_IVF_start) * 1000)
        metrics["IndexIVFFlat"][f'model_{i}']['avg_similarity'].append(D_IVF)
        metrics["IndexIVFFlat"][f'model_{i}']['indexes'].append(I_IVF)
    
    for i in range(1, 4):
        time_LSH_start = time.time()
        D_LSH, I_LSH = dict_LSH.get(i).search(query_vec, top_k)
        metrics["IndexLSH"][f'model_{i}']['times'].append((time.time() - time_IVF_start) * 1000)
        metrics["IndexLSH"][f'model_{i}']['avg_similarity'].append(D_IVF)
        metrics["IndexLSH"][f'model_{i}']['indexes'].append(I_IVF)

    c+=1
    
IP_avg_prec = 0
baseline = []
for i in range(len(metrics['IndexFlatIP']['avg_similarity'])):
    IP_avg_prec += statistics.mean(metrics['IndexFlatIP']['avg_similarity'][i][0])
    baseline.append(metrics['IndexFlatIP']['indexes'][i][0])
IP_avg_prec = IP_avg_prec/len(metrics['IndexFlatIP']['avg_similarity'])



IVF_1_avg_prec = 0
IVF_1_avg_rec = 0
for i in range(len(metrics['IndexIVFFlat']['model_1']['avg_similarity'])):
    IVF_1_avg_prec += statistics.mean(metrics['IndexIVFFlat']['model_1']['avg_similarity'][i][0])
    IVF_1_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexIVFFlat']['model_1']['indexes'][i][0])) / len(metrics['IndexIVFFlat']['model_1']['indexes'][i][0])
    
IVF_1_avg_prec = IVF_1_avg_prec/len(metrics['IndexIVFFlat']['model_1']['avg_similarity'])
IVF_1_avg_rec = IVF_1_avg_rec/len(metrics['IndexIVFFlat']['model_1']['indexes'])




IVF_2_avg_prec = 0
IVF_2_avg_rec = 0
for i in range(len(metrics['IndexIVFFlat']['model_2']['avg_similarity'])):
    IVF_2_avg_prec += statistics.mean(metrics['IndexIVFFlat']['model_2']['avg_similarity'][i][0])
    IVF_2_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexIVFFlat']['model_2']['indexes'][i][0])) / len(metrics['IndexIVFFlat']['model_2']['indexes'][i][0])
    
IVF_2_avg_prec = IVF_2_avg_prec/len(metrics['IndexIVFFlat']['model_2']['avg_similarity'])
IVF_2_avg_rec = IVF_2_avg_rec/len(metrics['IndexIVFFlat']['model_2']['indexes'])




IVF_3_avg_prec = 0
IVF_3_avg_rec = 0
for i in range(len(metrics['IndexIVFFlat']['model_3']['avg_similarity'])):
    IVF_3_avg_prec += statistics.mean(metrics['IndexIVFFlat']['model_3']['avg_similarity'][i][0])
    IVF_3_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexIVFFlat']['model_3']['indexes'][i][0])) / len(metrics['IndexIVFFlat']['model_3']['indexes'][i][0])
    
IVF_3_avg_prec = IVF_3_avg_prec/len(metrics['IndexIVFFlat']['model_3']['avg_similarity'])
IVF_3_avg_rec = IVF_3_avg_rec/len(metrics['IndexIVFFlat']['model_3']['indexes'])




IVF_4_avg_prec = 0
IVF_4_avg_rec = 0
for i in range(len(metrics['IndexIVFFlat']['model_4']['avg_similarity'])):
    IVF_4_avg_prec += statistics.mean(metrics['IndexIVFFlat']['model_4']['avg_similarity'][i][0])
    IVF_4_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexIVFFlat']['model_4']['indexes'][i][0])) / len(metrics['IndexIVFFlat']['model_4']['indexes'][i][0])

IVF_4_avg_prec = IVF_4_avg_prec/len(metrics['IndexIVFFlat']['model_4']['avg_similarity'])
IVF_4_avg_rec = IVF_4_avg_rec/len(metrics['IndexIVFFlat']['model_4']['indexes'])




IVF_5_avg_prec = 0
IVF_5_avg_rec = 0
for i in range(len(metrics['IndexIVFFlat']['model_5']['avg_similarity'])):
    IVF_5_avg_prec += statistics.mean(metrics['IndexIVFFlat']['model_5']['avg_similarity'][i][0])
    IVF_5_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexIVFFlat']['model_5']['indexes'][i][0])) / len(metrics['IndexIVFFlat']['model_5']['indexes'][i][0])

IVF_5_avg_prec = IVF_5_avg_prec/len(metrics['IndexIVFFlat']['model_5']['avg_similarity'])
IVF_5_avg_rec = IVF_5_avg_rec/len(metrics['IndexIVFFlat']['model_5']['indexes'])



LSH_1_avg_prec = 0
LSH_1_avg_rec = 0
for i in range(len(metrics['IndexLSH']['model_1']['avg_similarity'])):
    LSH_1_avg_prec += statistics.mean(metrics['IndexLSH']['model_1']['avg_similarity'][i][0])
    LSH_1_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexLSH']['model_1']['indexes'][i][0])) / len(metrics['IndexLSH']['model_1']['indexes'][i][0])

LSH_1_avg_prec = LSH_1_avg_prec/len(metrics['IndexLSH']['model_1']['avg_similarity'])
LSH_1_avg_rec = LSH_1_avg_rec/len(metrics['IndexLSH']['model_1']['indexes'])



LSH_2_avg_prec = 0
LSH_2_avg_rec = 0
for i in range(len(metrics['IndexLSH']['model_2']['avg_similarity'])):
    LSH_2_avg_prec += statistics.mean(metrics['IndexLSH']['model_2']['avg_similarity'][i][0])
    LSH_2_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexLSH']['model_2']['indexes'][i][0])) / len(metrics['IndexLSH']['model_2']['indexes'][i][0])

LSH_2_avg_prec = LSH_2_avg_prec/len(metrics['IndexLSH']['model_2']['avg_similarity'])
LSH_2_avg_rec = LSH_2_avg_rec/len(metrics['IndexLSH']['model_2']['indexes'])





LSH_3_avg_prec = 0
LSH_3_avg_rec = 0
for i in range(len(metrics['IndexLSH']['model_3']['avg_similarity'])):
    LSH_3_avg_prec += statistics.mean(metrics['IndexLSH']['model_3']['avg_similarity'][i][0])
    LSH_3_avg_rec += np.count_nonzero(np.isin(baseline[i], metrics['IndexLSH']['model_3']['indexes'][i][0])) / len(metrics['IndexLSH']['model_3']['indexes'][i][0])

LSH_3_avg_prec = LSH_3_avg_prec/len(metrics['IndexLSH']['model_3']['avg_similarity'])
LSH_3_avg_rec = LSH_3_avg_rec/len(metrics['IndexLSH']['model_3']['indexes'])


print(f"""{'_'*50}
                                    Mean search time:       Mean precision:     Mean recall:
    IndexIP                          - {statistics.mean(metrics['IndexFlatIP']['times']):2.5f} ms           {IP_avg_prec:2.5f}          {1.00000:2.5f}
    IndexIVF (nlist=64, nprobe=1)    - {statistics.mean(metrics['IndexIVFFlat']['model_1']['times']):2.5f} ms           {IVF_1_avg_prec:2.5f}          {IVF_1_avg_rec:2.5f}
    IndexIVF (nlist=128, nprobe=3)   - {statistics.mean(metrics['IndexIVFFlat']['model_2']['times']):2.5f} ms           {IVF_2_avg_prec:2.5f}          {IVF_2_avg_rec:2.5f}
    IndexIVF (nlist=256, nprobe=3)   - {statistics.mean(metrics['IndexIVFFlat']['model_3']['times']):2.5f} ms           {IVF_3_avg_prec:2.5f}          {IVF_3_avg_rec:2.5f}
    IndexIVF (nlist=512, nprobe=5)   - {statistics.mean(metrics['IndexIVFFlat']['model_4']['times']):2.5f} ms           {IVF_4_avg_prec:2.5f}          {IVF_4_avg_rec:2.5f}
    IndexIVF (nlist=1024, nprobe=10) - {statistics.mean(metrics['IndexIVFFlat']['model_5']['times']):2.5f} ms           {IVF_5_avg_prec:2.5f}          {IVF_5_avg_rec:2.5f}  
    IndexLSH (nbits=2)               - {statistics.mean(metrics['IndexLSH']['model_1']['times']):2.5f} ms           {LSH_1_avg_prec:2.5f}          {LSH_1_avg_rec:2.5f}
    IndexLSH (nbits=4)               - {statistics.mean(metrics['IndexLSH']['model_2']['times']):2.5f} ms           {LSH_2_avg_prec:2.5f}          {LSH_1_avg_rec:2.5f}
    IndexLSH (nbits=6)               - {statistics.mean(metrics['IndexLSH']['model_3']['times']):2.5f} ms           {LSH_3_avg_prec:2.5f}          {LSH_1_avg_rec:2.5f}
""")

