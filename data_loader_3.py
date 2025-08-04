"""
@author:    Ge Li, ge.li@kit.edu
@brief:     Defines data loaders of the CIFAR-10 dataset
@detail:    Modified and inspired by the official PyTorch Tutorial
"""

# Import Python libs
import torch
import torchvision
import torchvision.transforms as transforms

# Fix random seed to make sure the result in your computer is reproducible
torch.manual_seed(0)


def get_data_loader():
    # Define a composed transform of pre-processing the dataset
    transform = transforms.Compose([transforms.ToTensor(),
                                    transforms.Normalize((0.5, 0.5, 0.5),
                                                         (0.5, 0.5, 0.5))])

    # Load CIFAR-10 dataset
    train_set = torchvision.datasets.CIFAR10(root='./data', train=True,
                                             download=True, transform=transform)
    train_set, valid_set = torch.utils.data.random_split(train_set, [40000,
                                                                     10000])

    test_set = torchvision.datasets.CIFAR10(root='./data', train=False,
                                            download=True, transform=transform)

    # Construct data loaders
    train_loader = torch.utils.data.DataLoader(train_set, batch_size=512,
                                               shuffle=True, num_workers=2)
    valid_loader = torch.utils.data.DataLoader(test_set, batch_size=1024,
                                               shuffle=False, num_workers=2)
    test_loader = torch.utils.data.DataLoader(test_set, batch_size=512,
                                              shuffle=False, num_workers=2)

    return train_loader, valid_loader, test_loader
