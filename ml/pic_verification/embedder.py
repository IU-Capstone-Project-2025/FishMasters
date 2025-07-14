from torchvision.models import resnet18, ResNet18_Weights
import torch.nn as nn
import torch

class Embedder:
    def __init__(self):
        self.encoder = resnet18(weights=ResNet18_Weights.IMAGENET1K_V1)
        self.encoder.fc = nn.Identity()

    def get_embedding(self, image):
        # img = torch.randn(1, 3, 224, 224)
        return self.encoder(image)

def pic_from_fishbase():
    #TODO to take picture of the fish from the fishbase
    #или как вариант не по одной фотке грузить а загрузить сразу в dataframe/series все фотки
    ...
    
def pic_embeddings_to_qdrant():
    #TODO to upload embeddings to qdrant
    ...
    
#XXX будет меняться относительно того как мы будем загружать фотки по одной или сразу все целиком
def pipeline():
    embedder = Embedder()
    pics = pic_from_fishbase()
    embeddings = embedder.get_embedding(pics)
    pic_embeddings_to_qdrant(embeddings)