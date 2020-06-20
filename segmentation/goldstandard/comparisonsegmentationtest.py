#!/usr/bin/python
import numpy as np
import re

def find(s, ch):
    sentence = np.array(list(s))
    return [i for i, ltr in enumerate(s) if ltr == ch and sentence[i+1] == ch]

def findindexes(word, character):
    resultindexes = []
    letters = list(word)
    i = 0
    count = 0
    sentence = np.array(list(word))
    for letter in letters:
        if letter == character and sentence[i+1] == character:
            resultindexes.append(count-1)
        elif letter != character:
            count = count + 1
        i = i + 1
    return resultindexes

def intersection(lst1, lst2): 
    lst3 = [value for value in lst1 if value in lst2] 
    return lst3 

# Open a file with human annotation
npArraytesthumanaanotation = np.array([])
with open("sentences_pan-ashaninka_Jaime.txt.result", "rw+") as ftesthumanaanotation:
    linestesthumanaanotation = ftesthumanaanotation.readlines()
    for line in linestesthumanaanotation:
        npArraytesthumanaanotation = np.append(npArraytesthumanaanotation, line)
# segmentation made by a software        
npArraytestpanashaninka = np.array([])
with open("sentences.pan-ashaninka.test.ashaninkamorph", "rw+") as ftestpanashaninka:
    linestestpanashaninka = ftestpanashaninka.readlines()
    for line in linestestpanashaninka:
        npArraytestpanashaninka = np.append(npArraytestpanashaninka, line)

with open('rand.out.2') as f:
    lines=f.readlines()
    index = 0
    finalscore = 0
    for line in lines:
        outputhumanaanotation = npArraytesthumanaanotation[index]
        outputsoftware = npArraytestpanashaninka[int(line)]
        print("Machine segmentation: "+ npArraytestpanashaninka[int(line)]+"\nHuman segmentation: "+npArraytesthumanaanotation[index]+"\n")
        outputhumanaanotationlist = re.split('\s+', outputhumanaanotation)
        # split software output 
        outputsoftwarelist = re.split('\s+', outputsoftware)
        npArrayoutputsoftware = np.array([])
        for line in outputsoftwarelist:
            npArrayoutputsoftware = np.append(npArrayoutputsoftware, line)
        # comparing with human annotation 
        numberofoptions = 0
        sumwordscores = 0
        for idx, val in enumerate(outputhumanaanotationlist):
            if ("@@" in val):
                numberofoptions = numberofoptions + 1
                # compare indexes
                """
                          1111111
                01234567890123456
                m@@ap@@ip@@aye@@eni
                
                0123456789
                mapipayeeni
                 @@             0-1    1  1-1
                   @@           2-3    5  5-3            
                     @@         5-6    9  9-4
                        @@      7-8    14 14-7
                """
                # getting indexes from human annotation
                indexeswordhumanannotation = findindexes(val, "@")
                # getting indexes from software
                indexeswordoutputsoftware = findindexes(npArrayoutputsoftware[idx], "@")
                # getting the indexes that match 
                ncorrect = len(intersection(indexeswordhumanannotation, indexeswordoutputsoftware))
                # getting the total amount of correct indexes 
                ntotal = len(indexeswordhumanannotation)
                # calculating the score for a single word 
                wordscore = round(ncorrect / float(ntotal), 4) * 100
                sumwordscores = sumwordscores + wordscore
        index = index + 1
        # printing score for a single sentence 
        score = round(sumwordscores / float(numberofoptions), 4) 
        print("Score: " + str(score) +" % \n#------------------------------------------------------------")
        finalscore = finalscore + score 
    print("Average score: " + str(round(finalscore / float(index), 2)) + " % \n")
