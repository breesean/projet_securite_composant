"""
Projet sécurité des composants
Auteur : Antoine BREESE
Fichier de parsing dans le cadre du projet sécurité des composants
"""
#import

import numpy as np
import pandas as pd
import csv
import re
import os
from textwrap import wrap
import time

folder_path = "SECU8917"

regex = "key=(.+)_pti=(.+)_cto=(.+).csv"

item_columns_size = 16
number_files = 20000

len_item = 32

mat_pti = np.zeros((number_files,16)).astype(int)
mat_key = np.zeros((number_files,16)).astype(int)
mat_cto = np.zeros((number_files,16)).astype(int)
mat_traces = np.zeros((number_files,4000)).astype(float)

def to_int_array(item):
    """
    Retourne l'array d'entiers correspondant à l'item passé en paramètre.
    :param item:
    :return:
    """
    item_int_list = []
    for i in range(0, len_item, 2):
        item_int_list.append(int(item[i:i+2],16))
    return np.array(item_int_list, dtype=int)

def parsing(export = False):
    """
    Effectue le parsing des fichiers selon la nomenclature définie pour le projet. 
    Si export=True : la fonction exporte chacune des 4 matrices générées dans des fichiers csv.
    """
    i = 0
    for file_name in os.listdir(folder_path):
        with open(os.path.join(folder_path, file_name), 'r') as file:
            key, pti, cto = re.search(regex,file_name).groups()
            mat_pti[i] = to_int_array(pti)
            mat_key[i] = to_int_array(key)
            mat_cto[i] = to_int_array(cto)
            #gestion de la trace
            mat_traces[i] = np.fromiter(file.readline().split(','), dtype=float)
            i += 1
            if (i % 500) == 0:
                print("{}/{}".format(i, number_files))

    print("Matrices générées en {}s".format(time.time() - t0))
    print("mat_key : {}".format(mat_key.shape))
    print("mat_cto : {}".format(mat_cto.shape))
    print("mat_pti : {}".format(mat_pti.shape))
    print("mat_traces : {}".format(mat_traces.shape))
    if export:
        export_csv(mat_pti, "pti")
        export_csv(mat_key, "key")
        export_csv(mat_cto, "cto")
        export_csv(mat_traces, "traces")


        """pd.DataFrame(mat_pti).to_csv("pti.csv")
        pd.DataFrame(mat_cto).to_csv("cto.csv")
        pd.DataFrame(mat_key).to_csv("key.csv")
        pd.DataFrame(mat_traces).to_csv("traces.csv")
        """

        """np.savetxt('pti', mat_pti, delimiter=",")
        np.savetxt('key', mat_key, delimiter=",")
        np.savetxt('cto', mat_cto, delimiter=",")
        np.savetxt('traces', mat_traces, delimiter=",")"""

    print("Fichiers générés en {}s".format(time.time() - t0))
    return None

def export_csv(matrix, matrix_name):
    """
    Exporte la matrice matrix dans un fichier csv au nom "matrix_name.csv"
    """
    with open('{}.csv'.format(matrix_name), 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        for row in matrix:
            writer.writerow(row)

if __name__ == '__main__':
    global t0
    t0 = time.time()
    
    parsing(True)








