import platform

print(platform.platform())
## just to get info on which python code is running on

import sys

print("Python", sys.version)
import numpy

print("NumPy", numpy.__version__)
import scipy

print("SciPy", scipy.__version__)

import os

import numpy as np
import pandas as pd
from joblib import load
from sklearn import preprocessing
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.neural_network import MLPClassifier


def inference():

    # Load directory paths for loading the model
    # MODEL_DIR = os.getenv(
    #     "MODEL_DIR", "./models"
    # )  # Default to './models' directory if not set

    MODEL_DIR = "./models"
    MODEL_FILE_LDA = os.getenv("MODEL_FILE_LDA", "lda_model.joblib")
    MODEL_FILE_NN = os.getenv("MODEL_FILE_NN", "nn_model.joblib")
    MODEL_PATH_LDA = os.path.join(MODEL_DIR, MODEL_FILE_LDA)
    MODEL_PATH_NN = os.path.join(MODEL_DIR, MODEL_FILE_NN)

    # Load the models
    lda_model = load(MODEL_PATH_LDA)
    nn_model = load(MODEL_PATH_NN)

    # Load, read and normalize training data
    testing = "test.csv"
    data_test = pd.read_csv(testing)

    y_test = data_test["# Letter"].values
    X_test = data_test.drop(data_test.loc[:, "Line":"# Letter"].columns, axis=1)

    print("Shape of the test data")
    print(X_test.shape)
    print(y_test.shape)

    # Data normalization (0,1)
    X_test = preprocessing.normalize(X_test, norm="l2")

    # Models training

    # Run model
    print(MODEL_PATH_LDA)
    clf_lda = load(MODEL_PATH_LDA)
    print("LDA score and classification:")
    print(clf_lda.score(X_test, y_test))
    print(clf_lda.predict(X_test))

    # Run model
    clf_nn = load(MODEL_PATH_NN)
    print("NN score and classification:")
    print(clf_nn.score(X_test, y_test))
    print(clf_nn.predict(X_test))


if __name__ == "__main__":
    inference()
