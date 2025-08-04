"""
Data-driven modeling in Python, winter term 2023/2024
Homework Chapter 2: Python Basics
"""
from numpy import exp

def return_weight(age, initial_weight, max_weight, grow_rate=0.3):
    w = max_weight - (max_weight - initial_weight) * exp(-grow_rate * age)
    return w

# Dog class definition
class dog():
    # Each class MUST have an __init__() method that is immediately executed while instancing
    # The __init__ method is used to define the default values of the attributes of the class
    # Each method should be passed the argument self, which references to the general class instance 
    # Make breed and name required arguments for creating an instance of the dog class!

    
    def __init__(self, breed, name):
        # Define general constants
        self.allowed_breeds = ['pug', 'frenchie', 'labrador', 'golden retriever', 'greyhound']
        self.breed_max_weight = {'pug': 9, 'frenchie': 12, 'labrador': 32, 
                                 'golden retriever': 32, 'greyhound': 37}
        self.breed_initial_weight = {'pug': 0.3, 'frenchie': 0.3, 'labrador': 0.6, 
                                     'golden retriever': 0.5, 'greyhound': 0.8}
        
        # Initialize dogs attributes
        # Start with the breed and immediately check if it is valid
        self.breed = breed      # Define the dog's breed
        self.check_breed()
        
        self.name = name        # Define it's name
        self.age = 0            # Start the dog's life at 0 years
        self.weight = self.breed_initial_weight[self.breed]
        
    # Let's define the method grow(years) that will add to the dog's age 
    def grow(self, years):
        # Add to the age of the dog
        self.age += years
        self.weight = return_weight(self.age, self.breed_initial_weight[self.breed], 
                                    self.breed_max_weight[self.breed])
        
    def check_breed(self):
        if self.breed in self.allowed_breeds:
            print(self.breed, 'is an allowed breed.')
        else:    
            raise ValueError(self.breed, 'is not allowed! It should be one of the following',self.allowed_breeds)
            
    def report(self):
        print(self.name, 'is a', self.breed, 'and is', self.age, 'years old. It currently weighs', f'{self.weight:.2f}', 'kg.')