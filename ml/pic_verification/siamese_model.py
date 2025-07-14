import faiss
from embedder import Embedder


def from_qdrant_to_faiss():
    #TODO загрузить в faiss все embeddingи из qdrant
    ...
    
def get_user_pic():
    #TODO получить фотку от пользователя
    ...
    
def user_pic_embedding(pic):
    embedder = Embedder()
    return embedder.get_embedding(pic)

def search_picture():
    from_qdrant_to_faiss()
    ...
    
