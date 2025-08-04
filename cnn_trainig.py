import warnings
warnings.filterwarnings('ignore')
from resources.code.help_functions import ei_zeichnen
import torchvision
from torchvision import transforms
from torch.utils.data import DataLoader
import numpy as np
import matplotlib.pyplot as plt

import torch
import torch.nn as nn


# Implementiere in diesem Feld dein neuronales Netz.
# Wähle für die Bilder dabei eine passende Architektur.


class CNN(nn.Module):
    def __init__(self):
        super(CNN, self).__init__()
        self.conv1 = nn.Conv2d(1, 64, (15,15))
        self.bn1 = nn.BatchNorm2d(64)

        self.pool1 = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(64, 16, (4,4))
        self.bn2 = nn.BatchNorm2d(16)
        self.pool2 = nn.MaxPool2d(2, 2)
        self.fc1 = nn.Linear(16 * 11 * 11, 512)
        self.bn3 = nn.BatchNorm1d(512)

        self.fc2 = nn.Linear(512, 180)
        self.bn4 = nn.BatchNorm1d(180)

        self.fc3 = nn.Linear(180, 3)
        
        self.relu = torch.nn.ReLU()
        self.softmax = torch.nn.Softmax()
        

    def forward(self, x):
        x = self.pool1(self.relu(self.bn1(self.conv1(x))))
        x = self.pool2(self.relu(self.bn2(self.conv2(x))))
        x = x.view(-1, 16 * 11 * 11)
        x = self.relu(self.bn3(self.fc1(x)))
        x = self.relu(self.bn4(self.fc2(x)))
        x = self.fc3(x)
        x = self.softmax(x)
        return x



TRAIN_DATA_PATH = 'DataSet/train'
TEST_DATA_PATH = 'DataSet/test'



train_transforms = transforms.Compose([
  transforms.Resize([64,64]),
  transforms.ToTensor(),
  transforms.Grayscale()
])

train_dataset = torchvision.datasets.ImageFolder(root=TRAIN_DATA_PATH, transform=train_transforms)
train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)

cnn = CNN()
optimizer = torch.optim.SGD(cnn.parameters(), lr=0.01)
loss_func = torch.nn.CrossEntropyLoss()

from tqdm import tqdm

correct = 0
total = 0
for x,y in train_loader:
    output = cnn(x)
    preds = torch.argmax(output, dim=1)
    correct = sum(torch.eq(preds, y)).item()
    total += len(y)

print(correct, total)

for _ in tqdm(range(20)):
   loss_tot = 0
   for x,y in train_loader:
      output = cnn(x)
      loss = loss_func(output, y)
      loss_tot += loss.item()
      optimizer.zero_grad()
      loss.backward()
      optimizer.step()
   print(loss_tot)
   
   

correct = 0
total = 0
for x,y in train_loader:
    output = cnn(x)
    preds = torch.argmax(output, dim=1)
    correct = sum(torch.eq(preds, y)).item()
    total += len(y)
        
print(correct, total)