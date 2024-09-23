import os
import numpy as np
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.neural_network import MLPClassifier
import pandas as pd
from joblib import dump
from sklearn import preprocessing

# Print current working directory for debugging
cwd = os.getcwd()
print(f"Current working directory: {cwd}")

def train():
    # Load directory paths for persisting model
    MODEL_DIR = os.getenv("MODEL_DIR", "./models")  # Default to './models' directory if not set
    MODEL_FILE_LDA = os.getenv("MODEL_FILE_LDA", "lda_model.joblib")
    MODEL_FILE_NN = os.getenv("MODEL_FILE_NN", "nn_model.joblib")
    MODEL_PATH_LDA = os.path.join(MODEL_DIR, MODEL_FILE_LDA)
    MODEL_PATH_NN = os.path.join(MODEL_DIR, MODEL_FILE_NN)

    # Ensure the model directory exists
    if not os.path.exists(MODEL_DIR):
        os.makedirs(MODEL_DIR)

    # Load, read, and normalize training data
    # Use forward slashes for path compatibility
    training = "train.csv"
    data_train = pd.read_csv(training)
        
    y_train = data_train['# Letter'].values
    X_train = data_train.drop(data_train.loc[:, 'Line':'# Letter'].columns, axis=1)

    print("Shape of the training data")
    print(X_train.shape)
    print(y_train.shape)
        
    # Data normalization (0,1)
    X_train = preprocessing.normalize(X_train, norm='l2')
    
    # Models training
    
    # Linear Discriminant Analysis (Default parameters)
    clf_lda = LinearDiscriminantAnalysis()
    clf_lda.fit(X_train, y_train)
    
    # Save model
    dump(clf_lda, MODEL_PATH_LDA)
        
    # Neural Networks multi-layer perceptron (MLP) algorithm
    clf_NN = MLPClassifier(solver='adam', activation='relu', alpha=0.0001, hidden_layer_sizes=(500,), random_state=0, max_iter=1000)
    clf_NN.fit(X_train, y_train)
       
    # Save second model
    dump(clf_NN, MODEL_PATH_NN)
    
    print("We Good!")

if __name__ == '__main__':
    train()
