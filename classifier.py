import math
import os
import re
import sys
from collections import Counter

import numpy as np

import nltk
nltk.download('stopwords')

def bowk(x, z, d=1.0, normalize=True):
    result = 0.0
    for word in x if len(x) < len(z) else z:
        result += x[word] * z[word]
    if normalize:
        kxx = bowk(x, x, d, normalize=False)
        kzz = bowk(z, z, d, normalize=False)
        result /= math.sqrt(kxx * kzz)

    return result ** d


def kmat(X, Y, k):
    n = len(X)
    m = len(Y)
    mat = np.empty((n, m), dtype=np.float128)
    for i in range(n):
        for j in range(m):
            xi = X[i]
            yj = Y[j]
            mat[i, j] = k(xi, yj)
    return mat


class Classifier:

    def __init__(self, k):
        self._k = k
        self._ham_n = None
        self._spam_n = None
        self._ham = None
        self._spam = None
        self._b_ham = None
        self._b_spam = None
        self._c_ham = None
        self._c_spam = None

    def train(self, ham, spam):
        self._ham_n = len(ham)
        self._spam_n = len(spam)

        self._ham = ham
        self._spam = spam

        self._c_ham = kmat(ham, ham, self._k).mean()
        self._c_spam = kmat(spam, spam, self._k).mean()

    def classify(self, message, mode='classic', threshold=0.0):
        if mode == 'classic':
            value = self._classic(message)
        elif mode == 'reverse':
            value = self._reverse(message)
        elif mode == 'simple':
            value = self._simple(message)
        else:
            raise RuntimeError()
        return ('ham' if value <= threshold else 'spam', value)

    def _classic(self, message):
        a = self._k(message, message)
        b = kmat([message], self._ham, self._k).mean()
        c = self._c_ham
        return a - (b + b) + c

    def _reverse(self, message):
        a = self._k(message, message)
        b = kmat([message], self._spam, self._k).mean()
        c = self._c_spam
        return -(a - (b + b) + c)

    def _simple(self, message):
        return self._classic(message) + self._reverse(message)


################################################################################
# Preprocessing
################################################################################

def word_filter(word):
    from nltk.corpus import stopwords
    return word not in stopwords.words('english')
    # return True


def read_ham_messages(directory):
    for filename in filter(lambda x: x.endswith('.ham.txt'), os.listdir(directory)):
        path = os.path.join(directory, filename)
        print("Loading message: {:s} ... ".format(path), file=sys.stderr)
        with open(path, encoding='latin-1') as f:
            message = f.read()
            X = Counter(filter(word_filter, re.split("\W+", message)))
            yield X


def read_spam_messages(directory):
    for filename in filter(lambda x: x.endswith('.spam.txt'), os.listdir(directory)):
        path = os.path.join(directory, filename)
        print("Loading message: {:s} ... ".format(path), file=sys.stderr)
        with open(path, encoding='latin-1') as f:
            message = f.read()
            X = Counter(filter(word_filter, re.split("\W+", message)))
            yield X


################################################################################
# Load data
################################################################################

ham_messages_train = list(read_ham_messages('./data/spam-train'))
spam_messages_train = list(read_spam_messages('./data/spam-train'))

ham_messages_test = list(read_ham_messages('./data/spam-test'))
spam_messages_test = list(read_spam_messages('./data/spam-test'))

# Swap data
# ham_messages_train, ham_messages_test = ham_messages_test, ham_messages_train
# spam_messages_train, spam_messages_test = spam_messages_test, spam_messages_train

nham = float(len(ham_messages_test))
nspam = float(len(spam_messages_test))

for d in [1, 2, 3, 4]:
# for d in [1]:

    def k(x, y):
        return bowk(x, y, d, True)


    classifier = Classifier(k)
    classifier.train(ham_messages_train, spam_messages_train)
    print(classifier._c_ham)
    print(classifier._c_spam)
    print(type(classifier._c_spam))
    for mode in ['classic', 'reverse', 'simple']:
    # for mode in ['simple']:

        labels = []
        scores = []
        for message in ham_messages_train:
            labels.append("ham")
            _, score = classifier.classify(message, mode=mode)
            scores.append(score)
        for message in spam_messages_train:
            labels.append("spam")
            _, score = classifier.classify(message, mode=mode)
            scores.append(score)

        TP = []
        FP = []

        for threshold in sorted(scores, reverse=True):
            tp, fp, tn, fn = 0, 0, 0, 0
            for score, label in zip(scores, labels):
                predicted_label = 'ham' if score <= threshold else 'spam'
                if (label, predicted_label) == ("ham", "ham"):
                    tn += 1
                if (label, predicted_label) == ("ham", "spam"):
                    fp += 1
                if (label, predicted_label) == ("spam", "ham"):
                    fn += 1
                if (label, predicted_label) == ("spam", "spam"):
                    tp += 1

            TP.append(tp / nspam)
            FP.append(fp / nham)

            fmt = "tp={:>5.3f}, fp={:>5.3f}, tn={:>5.3f}, fn={:>5.3f} mode={:s}, degree={:d}, threshold={:11.10f}"
            print(fmt.format(tp / nspam, fp / nham, tn / nham, fn / nspam, mode, d, threshold))

        import matplotlib.pyplot as plt

        title = "ROC (mode={:s}, d={:d})".format(mode, d)
        figname = "ROC_{:s}_{:d}.png".format(mode, d)
        plt.figure()
        plt.title(title)
        plt.plot(FP, TP, 'b')
        # plt.plot([0,1], [0,1], 'r--')
        plt.xlim([0,1])
        plt.ylim([0,1])
        plt.xlabel('false-positive rate')
        plt.ylabel('true-positive rate')
        # plt.show()
        plt.savefig(figname)
        plt.clf()
